defmodule CodeRunner.Docker.Attach do
  use GenServer

  alias CodeRunner.Docker

  def initial_state(cid) do
    %{cid: cid, socket: nil, from: nil, state: nil, buffer: []}
  end

  def start_link([], state) do
    start_link(state)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    %{host: host, port: port} = URI.parse(Docker.tcp_host())

    {:ok, socket} =
      :gen_tcp.connect(String.to_charlist(host), port, [
        :binary,
        active: true,
        packet: :line,
        keepalive: true
      ])

    {:ok, state |> Map.put(:socket, socket)}
  end

  defp attach_headers(cid) do
    "POST /containers/#{cid}/attach?stream=true&stdin=true&stdout=true&stderr=true HTTP/1.1\r\n" <>
      "Content-Type: application/vnd.docker.raw-stream\r\n" <>
      "Connection: Upgrade\r\n" <> "Upgrade: tcp\r\n" <> "Host: 127.0.0.1\r\n" <> "\r\n"
  end

  def handle_call({:attach}, from, %{cid: cid, socket: socket} = state) do
    state = state |> Map.put(:from, from) |> Map.put(:state, :attach)

    :ok = :gen_tcp.send(socket, attach_headers(cid))

    {:noreply, state}
  end

  def handle_call({:send, payload}, from, %{socket: socket} = state) do
    state = state |> Map.put(:from, from) |> Map.put(:state, :send) |> Map.put(:buffer, [])

    :ok = :gen_tcp.send(socket, payload <> "\n")

    {:noreply, state}
  end

  def handle_call({:detach}, _from, %{socket: socket} = state) do
    :gen_tcp.close(socket)
    {:reply, :ok, state}
  end

  def handle_info({:tcp, _, "HTTP/1.1 101 UPGRADED\r\n"}, %{state: :attach} = state) do
    {:noreply, state}
  end

  def handle_info({:tcp, _, "\r\n"}, %{from: from, state: :attach} = state) do
    GenServer.reply(from, :ok)
    {:noreply, state}
  end

  def handle_info({:tcp, _, _header}, %{state: :attach} = state) do
    {:noreply, state}
  end

  def handle_info({:tcp, _, msg}, %{buffer: buffer, state: :send} = state) do
    state = state |> Map.put(:buffer, buffer ++ msg)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, %{from: from, buffer: buffer, state: :send} = state) do
    GenServer.reply(from, parse_buffer(buffer))
    state = state |> Map.put(:buffer, [])
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, %{from: from} = state) do
    GenServer.reply(from, {:error, "TCP Socket Closed Unexpectedly"})
    {:noreply, state}
  end

  def handle_info({:tcp_error, _, reason}, %{from: from} = state) do
    GenServer.reply(from, {:error, reason})
    {:noreply, state}
  end

  def type_to_atom(1), do: :stdout
  def type_to_atom(_), do: :stderr

  def parse_buffer(buffer) do
    parse_buffer(buffer, [])
  end

  def parse_buffer(<<>>, bodies) do
    format_bodies(bodies)
  end

  def parse_buffer(buffer, bodies) do
    <<type::size(8), 0, 0, 0, body_size::size(32), rest::binary>> = buffer

    case rest do
      <<body::size(body_size), next::binary>> ->
        parse_buffer(next, [{type, body} | bodies])

      <<body::size(body_size)>> ->
        parse_buffer(<<>>, [{type, body} | bodies])

      body ->
        parse_buffer(<<>>, [{type, body} | bodies])
    end
  end

  def format_bodies(bodies) do
    std =
      bodies
      |> Enum.reduce([], fn {type, out}, acc ->
        stdname = type_to_atom(type)

        if Keyword.has_key?(acc, stdname) do
          Keyword.update!(acc, stdname, fn prev_out ->
            "#{prev_out}#{to_string(out)}"
          end)
        else
          Keyword.put(acc, stdname, out)
        end
      end)
      |> Keyword.put_new(:stderr, "")
      |> Keyword.put_new(:stdout, "")

    format_response(std[:stderr], std[:stdout])
  end

  def format_response(stderr, "") do
    %{"stdout" => "", "stderr" => stderr, "error" => nil}
  end

  def format_response("", stdout) do
    Poison.decode!(stdout)
  end

  def format_response(stderr, stdout) do
    %{"stdout" => stdout, "stderr" => stderr, "error" => nil}
  end

  def attach!(cid) do
    {:ok, pid} = CodeRunner.Docker.Supervisor.start_child(cid)
    :ok = GenServer.call(pid, {:attach})
    pid
  end

  def send!(pid, payload, timeout) do
    try do
      GenServer.call(pid, {:send, payload}, timeout)
    catch
      :exit, _ ->
        %{"stdout" => "", "stderr" => "", "error" => "Timeout"}
    end
  end

  def detach!(pid) do
    :ok = GenServer.call(pid, {:detach})
  end
end
