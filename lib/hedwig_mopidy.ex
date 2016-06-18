defmodule HedwigMopidy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: HedwigMopidy.Supervisor]
    Supervisor.start_link([], opts)
  end

  def current_playing do
    with {:ok, current_track} <- Mopidy.Playback.get_current_track do
      case current_track do
        %Mopidy.Track{} = track -> playing_string(track)
        _ -> notice_message("Nothing is playing")
      end
    else
      {:error, error_message} -> error_message
      _ -> error_message("Couldn't find who's playing")
    end
  end

  def notice_message(message) do
    "♮ " <> to_string(message)
  end

  def error_message(message) do
    "✗ " <> to_string(message)
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
