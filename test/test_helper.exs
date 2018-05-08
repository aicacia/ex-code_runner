defmodule Test do
  defmacro test_code_runner(type, file) do
    quote do
      test("should return parsed json with Hello, world! from #{unquote(type)}") do
        content = File.read!("#{File.cwd!()}/test/snippets/#{unquote(file)}")

        files = Map.put(%{}, unquote(file), content)

        %{results: [result]} =
          CodeRunner.run(%{
            lang: unquote(type),
            files: files
          })

        assert result == %{"stdout" => "Hello, world!\n", "stderr" => "", "error" => nil}
      end
    end
  end
end

ExUnit.start()
