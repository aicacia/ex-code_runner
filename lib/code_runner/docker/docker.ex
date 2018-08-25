defmodule CodeRunner.Docker do
  @default_timeout 60_000
  @default_recv_timeout 60_000

  def http_host do
    "#{Application.get_env(:code_runner, :http_host)}"
  end

  def tcp_host do
    "#{Application.get_env(:code_runner, :tcp_host)}"
  end

  def get!(url) do
    "#{http_host()}/#{url}"
    |> HTTPoison.get!(headers(), options())
    |> decode_body()
  end

  def post!(url, body \\ "") do
    body = Poison.encode!(body)

    "#{http_host()}/#{url}"
    |> HTTPoison.post!(body, headers(), options())
    |> decode_body()
  end

  def delete!(url) do
    "#{http_host()}/#{url}"
    |> HTTPoison.delete!(headers(), options())
    |> decode_body()
  end

  defp headers do
    {:ok, hostname} = :inet.gethostname()
    ["Content-Type": "application/json", Host: hostname]
  end

  defp options do
    [timeout: @default_timeout, recv_timeout: @default_recv_timeout]
  end

  defp decode_body(%HTTPoison.Response{body: ""} = response) do
    Map.put(response, :body, %{})
  end

  defp decode_body(%HTTPoison.Response{body: body} = response) do
    case Poison.decode(body) do
      {:ok, body} ->
        Map.put(response, :body, body)
    end
  end
end
