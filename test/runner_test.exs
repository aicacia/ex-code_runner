defmodule RunnerTest do
  use ExUnit.Case
  require Test
  doctest Runner

  Test.test_runner("rust", "main.rs", "fn main() { println!(\"Hello, world!\"); }")
end
