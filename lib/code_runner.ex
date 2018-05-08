defmodule CodeRunner do
  alias CodeRunner.Docker
  alias CodeRunner.Docker.Attach

  @default_build_timeout 60_000
  @default_timeout 60_000

  def run(%{lang: lang, tag: tag, files: files, inputs: inputs} = input) do
    image = lang_to_image(String.downcase(lang))

    build_timeout =
      min(Map.get(input, :build_timeout, @default_build_timeout), @default_build_timeout)

    timeout = min(Map.get(input, :timeout, @default_timeout), @default_timeout)

    name = "code_runner-#{image}-#{tag}"

    Docker.post!(
      "containers/create?name=#{name}",
      create_config("code_runner/#{image}:#{tag}")
    )

    %HTTPoison.Response{status_code: 204} = Docker.post!("containers/#{name}/start")

    pid = Attach.attach!(name)

    compile_result =
      Attach.send!(
        pid,
        Poison.encode!(%{
          "lang" => lang,
          "files" => files
        }),
        build_timeout
      )

    run_results =
      Enum.map(inputs, fn argv ->
        Attach.send!(
          pid,
          Poison.encode!(argv),
          timeout
        )
      end)

    Attach.detach!(pid)

    Docker.post!("containers/#{name}/stop")

    %{
      compile: compile_result,
      results: run_results
    }
  end

  def run(%{lang: _lang, files: _files} = input) do
    run(
      input
      |> Map.put(:tag, Map.get(input, :tag, "latest"))
      |> Map.put(:inputs, Map.get(input, :inputs, [[]]))
    )
  end

  def lang_to_image("ecmascript"), do: "node"
  def lang_to_image("javascript"), do: "node"
  def lang_to_image("gcc"), do: "c"
  def lang_to_image("g++"), do: "cpp"
  def lang_to_image("clang"), do: "c"
  def lang_to_image("clang++"), do: "cpp"

  def lang_to_image(lang) do
    lang
  end

  defp create_config(image) do
    %{
      Image: image,
      AttachStdin: true,
      AttachStdout: true,
      AttachStderr: true,
      Tty: false,
      OpenStdin: true
    }
  end
end
