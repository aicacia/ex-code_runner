defmodule Mix.Tasks.CodeRunner.Build do
  use Mix.Task

  defp root() do
    :code.priv_dir(:code_runner)
  end

  defp containers_root() do
    "#{root()}/containers"
  end

  defp container_root(container) do
    "#{containers_root()}/#{container}"
  end

  defp container_tag_root(container, tag) do
    "#{container_root(container)}/#{tag}"
  end

  defp pull_code_runner() do
    if !File.exists?("#{root()}/rs-code_runner") do
      System.cmd(
        "git",
        ["clone", "https://gitlab.com/nathanfaucett/rs-code_runner.git"],
        into: IO.stream(:stdio, :line),
        parallelism: true,
        cd: "#{root()}"
      )
    end

    System.cmd(
      "git",
      ["pull"],
      into: IO.stream(:stdio, :line),
      parallelism: true,
      cd: "#{root()}/rs-code_runner"
    )
  end

  defp build_all() do
    pull_code_runner()
    containers = File.ls!(containers_root())

    Enum.each(containers, fn container ->
      tags = File.ls!(container_root(container))

      Enum.each(tags, fn tag ->
        build(container, tag)
      end)
    end)
  end

  defp build(container, tag) do
    image_root = container_tag_root(container, tag)

    File.cp!("#{root()}/rs-code_runner/bin/code_runner", "#{image_root}/code_runner")

    System.cmd(
      "docker",
      ["build", ".", "--no-cache", "--tag", "code_runner/#{container}:#{tag}"],
      into: IO.stream(:stdio, :line),
      parallelism: true,
      cd: image_root
    )
  end

  def run(args) do
    image = Enum.at(args, 0, nil)
    tag = Enum.at(args, 1, "latest")

    HTTPoison.start()

    if image == nil do
      build_all()
    else
      pull_code_runner()
      build(image, tag)
    end
  end
end
