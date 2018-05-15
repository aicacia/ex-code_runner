defmodule CodeRunner do
  alias CodeRunner.Docker
  alias CodeRunner.Docker.Attach

  @default_timeout 300_000
  @default_run_timeout 10_000

  def run(%{lang: lang, tag: tag, files: files, inputs: inputs} = input) do
    image = lang_to_image(String.downcase(lang))

    timeout = min(Map.get(input, :timeout, @default_timeout), @default_timeout)

    %HTTPoison.Response{body: %{"Id" => cid}} =
      Docker.post!(
        "containers/create",
        create_config("code_runner/#{image}:#{tag}")
      )

    %HTTPoison.Response{status_code: 204} = Docker.post!("containers/#{cid}/start")

    pid = Attach.attach!(cid)

    compile_result =
      Attach.send!(
        pid,
        Poison.encode!(%{
          "timeout" => timeout,
          "lang" => lang,
          "files" => files
        }),
        @default_timeout
      )

    run_results =
      Enum.map(inputs, fn input ->
        Attach.send!(
          pid,
          Poison.encode!(%{
            timeout: min(Map.get(input, :timeout, @default_run_timeout), @default_run_timeout),
            argv: Map.get(input, :argv, [])
          }),
          @default_timeout
        )
      end)

    Attach.detach!(pid)

    Docker.post!("containers/#{cid}/stop")
    Docker.post!("containers/#{cid}/remove")

    %{
      compile: compile_result,
      results: run_results
    }
  end

  def run(%{lang: _lang, files: _files} = input) do
    run(
      input
      |> Map.put(:tag, Map.get(input, :tag, "latest"))
      |> Map.put(:inputs, Map.get(input, :inputs, [%{timeout: 5.0, argv: []}]))
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
