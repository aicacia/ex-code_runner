defmodule CodeRunnerTest do
  use ExUnit.Case
  require Test
  doctest CodeRunner

  Test.test_code_runner("java", "Main.java", "test/snippets/Main.java")
  Test.test_code_runner("c", "main.c", "test/snippets/main.c")
  Test.test_code_runner("cpp", "main.cpp", "test/snippets/main.cpp")
  Test.test_code_runner("elixir", "main.ex", "test/snippets/main.ex")
  Test.test_code_runner("go", "main.go", "test/snippets/main.go")
  Test.test_code_runner("ecmascript", "main.js", "test/snippets/main.js")
  Test.test_code_runner("lua", "main.lua", "test/snippets/main.lua")
  Test.test_code_runner("python", "main.py", "test/snippets/main.py")
  Test.test_code_runner("ruby", "main.rb", "test/snippets/main.rb")
  Test.test_code_runner("rust", "main.rs", "test/snippets/main.rs")

  test "should send timeout error" do
    result =
      CodeRunner.run(%{
        timeout: 0,
        language: "node",
        files: [
          %{name: "main.js", content: "console.log(\"Hello, world!\");"}
        ]
      })

    assert result == %{"stdout" => "", "stderr" => "", "error" => "Timeout"}
  end
end
