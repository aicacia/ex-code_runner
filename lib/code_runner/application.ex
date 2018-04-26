defmodule CodeRunner.Application do
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: CodeRunner.Docker.Supervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: CodeRunner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
