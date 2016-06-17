defmodule HedwigMopidy.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end
end
