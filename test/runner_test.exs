defmodule RunnerTest do
  use ExUnit.Case
  require Test
  doctest Runner

  Test.test_runner("java", "Main.java", "test/snippets/Main.java")
  Test.test_runner("c", "main.c", "test/snippets/main.c")
  Test.test_runner("cpp", "main.cpp", "test/snippets/main.cpp")
  Test.test_runner("elixir", "main.ex", "test/snippets/main.ex")
  Test.test_runner("ecmascript", "main.js", "test/snippets/main.js")
  Test.test_runner("python", "main.py", "test/snippets/main.py")
  Test.test_runner("ruby", "main.rb", "test/snippets/main.rb")
  Test.test_runner("rust", "main.rs", "test/snippets/main.rs")
end
