defmodule Test do
  defmacro test_runner(type, file, content) do
    quote do
      test("should return parsed json with Hello, world! from #{unquote(type)}") do
        {:ok, result} =
          Runner.run(%{
            "language" => unquote(type),
            "argv" => [],
            "files" => [
              %{"name" => unquote(file), "content" => unquote(content)}
            ]
          })

        assert result == %{"stdout" => "Hello, world!\n", "stderr" => "", "error" => nil}
      end
    end
  end
end

ExUnit.start()
