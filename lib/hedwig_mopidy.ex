defmodule HedwigMopidy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: HedwigMopidy.Supervisor]
    Supervisor.start_link([], opts)
  end

  def playing_string(%Mopidy.Track{} = track) do
    "♫ Playing " <> HedwigMopidy.track_string(track)
  end

  def track_string(%Mopidy.Track{} = track) do
    track.name <> " by " <> artists_string(track.artists)
  end

  def artists_string(artists) do
    artists
    |> Enum.map(fn artist -> artist.name end)
    |> Enum.join(", ")
  end
end
