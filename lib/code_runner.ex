defmodule CodeRunner do
  alias CodeRunner.Docker
  alias CodeRunner.Docker.Attach

  # max timeout 5 minutes 60_000 * 5
  @default_timeout 300_000

  def run(%{language: language, tag: tag, files: files, argv: argv} = input) do
    image = language_to_image(String.downcase(language))
    timeout = min(Map.get(input, :timeout, @default_timeout), @default_timeout)

    %{"Id" => cid} =
      Docker.post!(
        "containers/create",
        create_config("code_runner/#{image}:#{tag}")
      )

    Docker.post!("containers/#{cid}/start")

    pid = Attach.attach!(cid)

    result =
      Attach.send!(
        pid,
        Poison.encode!(%{
          "language" => language,
          "argv" => argv,
          "files" => files
        }),
        timeout
      )

    Attach.detach!(pid)

    Docker.post!("containers/#{cid}/end")

    Docker.delete!("containers/#{cid}")

    result
  end

  def run(%{language: _language, files: _files} = input) do
    run(
      input
      |> Map.put(:tag, Map.get(input, :tag, "latest"))
      |> Map.put(:argv, Map.get(input, :argv, []))
    )
  end

  def language_to_image("ecmascript"), do: "node"
  def language_to_image("javascript"), do: "node"
  def language_to_image("gcc"), do: "c"
  def language_to_image("g++"), do: "cpp"
  def language_to_image("clang"), do: "c"
  def language_to_image("clang++"), do: "cpp"

  def language_to_image(language) do
    language
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
