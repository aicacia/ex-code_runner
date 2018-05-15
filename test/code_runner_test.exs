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
end
