defmodule HedwigMopidy do
  use Application

  def start(_type, _args) do
    HedwigMopidy.Supervisor.start_link
  end
end
