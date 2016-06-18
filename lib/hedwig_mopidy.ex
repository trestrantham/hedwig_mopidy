defmodule HedwigMopidy do
  use Application

  alias Mopidy.{Track,TlTrack,Playback}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: HedwigMopidy.Supervisor]
    Supervisor.start_link([], opts)
  end

  # lookups

  def currently_playing do
    with {:ok, "playing"} <- Playback.get_state,
         {:ok, %Track{} = current_track} <- Playback.get_current_track do
      playing_string(current_track)
    else
      {:ok, _} -> notice_message("Nothing is playing")
      {:error, error_message} -> error_message
      _ -> error_message("Couldn't find what's playing")
    end
  end

  # parsing

  def parse_boolean("off"), do: {"off", false}
  def parse_boolean(_),     do: {"on", true}

  # messages

  def playing_message(message) do
    "♫ " <> to_string(message)
  end

  def notice_message(message) do
    "♮ " <> to_string(message)
  end

  def error_message(message) do
    "✗ " <> to_string(message)
  end

  def playing_string(%Track{} = track) do
    playing_message("Playing " <> HedwigMopidy.track_string(track))
  end
  def playing_string(%TlTrack{} = tl_track) do
    playing_string(tl_track.track)
  end

  def track_string(%Track{} = track) do
    track.name <> " by " <> artists_string(track.artists)
  end
  def track_string(%TlTrack{} = tl_track) do
    track_string(tl_track.track)
  end
  def track_string(_) do
    "No track"
  end

  def artists_string(artists) do
    artists
    |> Enum.map(fn artist -> artist.name end)
    |> Enum.join(", ")
  end

  # system

  def web_url do
    if api_url = Mopidy.mopidy_api_url do
      Regex.replace(~r/\/rpc/, api_url, "")
    else
      "No web URL set"
    end
  end

  @doc """
  Gets the Icecast URL from :hedwig_mopidy, :icecast_url application env
  Returns binary
  """
  def icecast_url do
    Application.get_env(:hedwig_mopidy, :icecast_url)
  end
end
