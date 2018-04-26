defmodule Mix.Tasks.CodeRunner.Build do
  use Mix.Task

  defp pull_code_runner() do
    IO.puts("Pull code_runner from https://gitlab.com/nathanfaucett/rs-code_runner/raw/master/bin/code_runner")

    %HTTPoison.Response{body: body} =
      HTTPoison.get!("https://gitlab.com/nathanfaucett/rs-code_runner/raw/master/bin/code_runner")

    IO.puts("Pulled code_runner")
    body
  end

  defp build_all() do
    code_runner = pull_code_runner()
    containers = File.ls!(containers_root())

    Enum.each(containers, fn container ->
      tags = File.ls!(container_root(container))

      Enum.each(tags, fn tag ->
        build(container, tag, code_runner)
      end)
    end)
  end

  defp build(container, tag, code_runner) do
    root = container_tag_root(container, tag)

    File.write!("#{root}/code_runner", code_runner)

    System.cmd(
      "docker",
      ["build", ".", "--no-cache", "--tag", "code_runner/#{container}:#{tag}"],
      into: IO.stream(:stdio, :line),
      parallelism: true,
      cd: root
    )
  end

  defp containers_root() do
    "#{File.cwd!()}/priv/containers"
  end

  defp container_root(container) do
    "#{containers_root()}/#{container}"
  end

  defp container_tag_root(container, tag) do
    "#{container_root(container)}/#{tag}"
  end

  def run(_args) do
    HTTPoison.start()
    build_all()
  end
end
