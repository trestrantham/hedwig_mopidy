defmodule HedwigMopidy.Responders.Mopidy do
  use Hedwig.Responder

  alias Mopidy.{Library,Tracklist,Playback}
  alias Mopidy.{Track,TlTrack,SearchResult}

  hear ~r/^mopidy$/i, message do
    response = "Hedwig Mopidy\n"
    
    response =
      if web_url = HedwigMopidy.web_url do
        response <> "Web URL: " <> web_url <> "\n"
      else
        response <> "Web URL: No web URL set\n"
      end

    response =
      if icecast_url = HedwigMopidy.icecast_url do
        response <> "Icecast URL: " <> icecast_url <> "\n"
      else
        response
      end

    send message, HedwigMopidy.playing_message(response)
  end

  hear ~r/play artist (?<artist>.*)/i, message do
    artist = message.matches["artist"]

    response = 
      with {:ok, %SearchResult{} = search_results} <- Library.search(%{artist: [artist]}),
           {:ok, :success} <- Tracklist.clear,
           {:ok, tracks} when is_list(tracks) <- Tracklist.add(search_results.tracks |> Enum.map(fn(%Track{} = track) -> track.uri end)),
           {:ok, :success} <- Playback.play do
        HedwigMopidy.currently_playing
      else
        {:error, error_message} -> error_message
        _ ->
          case Tracklist.get_length do
            {:ok, 0} -> HedwigMopidy.error_message("Couldn't find any music for that artist")
            _        -> HedwigMopidy.error_message("Couldn't play music by that artist")
          end
      end

    send message, response
  end

  hear ~r/^play album (?<album>.*) by (?<artist>.*)/i, message do
    album = message.matches["album"]
    artist = message.matches["artist"]

    response = 
      with {:ok, %SearchResult{} = search_results} <- Library.search(%{artist: [artist], album: [album]}),
           {:ok, :success} <- Tracklist.clear,
           {:ok, tracks} when is_list(tracks) <- Tracklist.add(search_results.tracks |> Enum.map(fn(%Track{} = track) -> track.uri end)),
           {:ok, :success} <- Playback.play do
        HedwigMopidy.currently_playing
      else
        {:error, error_message} -> error_message
        _ ->
          case Tracklist.get_length do
            {:ok, 0} -> HedwigMopidy.error_message("Couldn't find any music for that album")
            _        -> HedwigMopidy.error_message("Couldn't play music for that album")
          end
      end

    send message, response
  end

  # what's playing
  # who is playing
  hear ~r/^(what|who).* playing/i, message do
    response = HedwigMopidy.currently_playing

    send message, response
  end

  hear ~r/^(up|what).* next$/i, message do
    response =
      with {:ok, %TlTrack{} = next_track} <- Tracklist.next_track do
        next_track
        |> HedwigMopidy.track_string
        |> HedwigMopidy.notice_message
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.notice_message("No more songs are queued")
      end

    send message, response
  end

  hear ~r/^next (song|track)$/i, message do
    response =
      with {:ok, %TlTrack{} = next_track} <- Tracklist.next_track,
           {:ok, :success} <- Playback.next do
        HedwigMopidy.playing_string(next_track)
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.notice_message("No more songs are queued")
      end

    send message, response
  end

  hear ~r/^repeat (?<value>.{2,3})$/i, message do
    {string_value, value} = HedwigMopidy.parse_boolean(message.matches["value"])

    response =
      with {:ok, :success} <- Tracklist.set_repeat(value) do
        HedwigMopidy.notice_message("Repeat is " <> string_value)
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.error_message("Couldn't set repeat")
      end

    send message, response
  end

  hear ~r/^random (?<value>.{2,3})$/i, message do
    {string_value, value} = HedwigMopidy.parse_boolean(message.matches["value"])

    response =
      with {:ok, :success} <- Tracklist.set_random(value) do
        HedwigMopidy.notice_message("Random is " <> string_value)
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.error_message("Couldn't set random")
      end

    send message, response
  end

  hear ~r/^play$/i, message do
    response = 
      with {:ok, :success} <- Playback.play do
        HedwigMopidy.currently_playing
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.error_message("Couldn't play music")
      end

    send message, response
  end

  hear ~r/^stop$/i, message do
    response = 
      with {:ok, :success} <- Playback.stop do
        HedwigMopidy.notice_message("Stopped")
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.error_message("Couldn't stop music")
      end

    send message, response
  end

  hear ~r/^pause$/i, message do
    response = 
      with {:ok, :success} <- Playback.pause,
           {:ok, state} <- Playback.get_state,
           {:ok, current_track} <- Playback.get_current_track do
        case state do
          "playing" -> HedwigMopidy.playing_string(current_track)
          "stopped" -> HedwigMopidy.notice_message("Stopped")
          "paused"  -> HedwigMopidy.notice_message("Paused on " <> HedwigMopidy.track_string(current_track))
          _ -> HedwigMopidy.error_message("Couldn't pause music")
        end
      else
        {:error, error_message} -> error_message
        _ -> HedwigMopidy.error_message("Couldn't pause music")
      end

    send message, response
  end
end
