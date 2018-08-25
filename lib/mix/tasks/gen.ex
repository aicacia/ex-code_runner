defmodule Mix.Tasks.CodeRunner.Gen do
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

  defp dockerfile(image, tag) do
    "FROM #{image}:#{tag}
MAINTAINER Nathan Faucett \"nathanfaucett@gmail.com\"

# Install code_runner
COPY code_runner /home/code_runner/code_runner
RUN chmod +x /home/code_runner/code_runner

WORKDIR /home/code_runner/
ENTRYPOINT \"/home/code_runner/code_runner\"
CMD [\"/home/code_runner/code_runner\"]"
  end

  defp build(name, image, tag) do
    root = container_tag_root(name, tag)

    File.mkdir_p!(root)

    if !File.exists?("#{root}/Dockerfile") do
      File.write!("#{root}/Dockerfile", dockerfile(image, tag))
    end
  end

  def run(args) do
    name = Enum.at(args, 0, "node")
    image = Enum.at(args, 1, name)
    tag = Enum.at(args, 2, "latest")

    build(name, image, tag)
  end
end
