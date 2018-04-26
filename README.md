# CodeRunner

code code_runner

## Config

docker should be accessable from tcp and http

```elixir
# config/config.exs

config :code_runner,
  tcp_host: "tcp://localhost:9876",
  http_host: "http+unix://%2Fvar%2Frun%2Fdocker.sock"
```

## Build

create the docker containers first

```bash
$ mix code_runner.build
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `code_runner` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:code_runner, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/code_runner](https://hexdocs.pm/code_runner).
