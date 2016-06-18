defmodule HedwigMopidy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: HedwigMopidy.Supervisor]
    Supervisor.start_link([], opts)
  end

  # lookups

  def current_playing do
    with {:ok, current_track} <- Mopidy.Playback.get_current_track do
      case current_track do
        %Mopidy.Track{} = track -> playing_string(track)
        _ -> notice_message("Add some music to play")
      end
    else
      {:error, error_message} -> error_message
      _ -> error_message("Couldn't find who's playing")
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

  def playing_string(%Mopidy.Track{} = track) do
    playing_message("Playing " <> HedwigMopidy.track_string(track))
  end
  def playing_string(%Mopidy.TlTrack{} = tl_track) do
    playing_string(tl_track.track)
  end

  def track_string(%Mopidy.Track{} = track) do
    track.name <> " by " <> artists_string(track.artists)
  end
  def track_string(%Mopidy.TlTrack{} = tl_track) do
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
