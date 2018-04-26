defmodule Test do
  defmacro test_runner(type, file, filepath) do
    quote do
      test("should return parsed json with Hello, world! from #{unquote(type)}") do
        content = File.read!("#{File.cwd!()}/#{unquote(filepath)}")

        {:ok, result} =
          Runner.run(%{
            language: unquote(type),
            files: [
              %{name: unquote(file), content: content}
            ]
          })

        assert result == %{"stdout" => "Hello, world!\n", "stderr" => "", "error" => nil}
      end
    end
  end
end

ExUnit.start()
