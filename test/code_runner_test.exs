defmodule CodeRunnerTest do
  use ExUnit.Case
  require Test
  doctest CodeRunner

  Test.test_code_runner("java", "Main.java")
  Test.test_code_runner("c", "main.c")
  Test.test_code_runner("cpp", "main.cpp")
  Test.test_code_runner("elixir", "main.ex")
  Test.test_code_runner("go", "main.go")
  Test.test_code_runner("ecmascript", "main.js")
  Test.test_code_runner("lua", "main.lua")
  Test.test_code_runner("python", "main.py")
  Test.test_code_runner("ruby", "main.rb")
  Test.test_code_runner("rust", "main.rs")

  test "should send timeout error" do
    %{results: [result]} =
      CodeRunner.run(%{
        timeout: 0,
        lang: "node",
        files: %{
          "main.js": "console.log(\"Hello, world!\");"
        }
      })

    assert result == %{"stdout" => "", "stderr" => "", "error" => "timed_out"}
  end

  @moduledoc """
  test "run while already running" do
    task0 =
      Task.async(fn ->
        CodeRunner.run(%{
          lang: "node",
          files: %{
            "main.js": "console.log(\"Hello, world!\");"
          }
        })
      end)

    task1 =
      Task.async(fn ->
        CodeRunner.run(%{
          lang: "node",
          files: %{
            "main.js": "console.log(\"Hello, world!\");"
          }
        })
      end)

    Task.await(task0)
    Task.await(task1)
  end
  """
end
