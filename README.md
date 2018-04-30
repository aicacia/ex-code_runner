# CodeRunner

code runner using [https://gitlab.com/nathanfaucett/rs-code_runner](https://gitlab.com/nathanfaucett/rs-code_runner)

## Config

docker must be accessible over tcp and http

```elixir
# config/config.exs

config :code_runner,
  tcp_host: "tcp://localhost:9876",
  http_host: "http+unix://%2Fvar%2Frun%2Fdocker.sock"
```

## Build

build the docker containers

```bash
$ mix code_runner.build
```

## Usage

```elixir
CodeRunner.run(%{
  language: "elixir",
  argv: [],
  files: [%{
    file: "main.ex",
    contents: "IO.puts(\"Hello, world!\")"
  }]
})
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `code_runner` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:code_runner, git: "git@github.com:nathanfaucett/ex-code_runner.git"}
    # or if I push it
    {:code_runner, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/code_runner](https://hexdocs.pm/code_runner).
