defmodule Runner.Docker do
  def http_host do
    "#{Application.get_env(:runner, :http_host)}"
  end

  def tcp_host do
    "#{Application.get_env(:runner, :tcp_host)}"
  end

  defp headers do
    {:ok, hostname} = :inet.gethostname()
    ["Content-Type": "application/json", Host: hostname]
  end

  def get!(url) do
    "#{http_host()}/#{url}"
    |> HTTPoison.get!(headers())
    |> decode_body()
  end

  def post!(url, body \\ "") do
    body = Poison.encode!(body)

    "#{http_host()}/#{url}"
    |> HTTPoison.post!(body, headers())
    |> decode_body()
  end

  def delete!(url) do
    "#{http_host()}/#{url}"
    |> HTTPoison.delete!(headers())
    |> decode_body()
  end

  defp decode_body(%HTTPoison.Response{body: ""}) do
    nil
  end

  defp decode_body(%HTTPoison.Response{body: body}) do
    case Poison.decode(body) do
      {:ok, map} -> map
      {:error, _} -> body
    end
  end
end
