defmodule Mix.Tasks.Runner.Build do
  use Mix.Task

  defp pull_runner() do
    IO.puts("Pull runner from https://gitlab.com/nathanfaucett/rs-runner/raw/master/bin/runner")

    %HTTPoison.Response{body: body} =
      HTTPoison.get!("https://gitlab.com/nathanfaucett/rs-runner/raw/master/bin/runner")

    IO.puts("Pulled runner")
    body
  end

  defp build_all() do
    runner = pull_runner()
    containers = File.ls!(containers_root())

    Enum.each(containers, fn container ->
      tags = File.ls!(container_root(container))

      Enum.each(tags, fn tag ->
        build(container, tag, runner)
      end)
    end)
  end

  defp build(container, tag, runner) do
    root = container_tag_root(container, tag)

    File.write!("#{root}/runner", runner)

    System.cmd(
      "docker",
      ["build", ".", "--no-cache", "--tag", "runner/#{container}:#{tag}"],
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
