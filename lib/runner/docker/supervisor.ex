defmodule Runner.Docker.Supervisor do
  use DynamicSupervisor

  alias Runner.Docker.Attach

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(cid) do
    child_spec = {Attach, Attach.initial_state(cid)}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
