defmodule HedwigMopidy.Responders.Playback do
  use Hedwig.Responder

  hear ~r/play artist (?<artist>.*)/i, message do
    artist = message.matches["artist"]

    response = 
      with {:ok, %Mopidy.SearchResult{} = search_results} <- Mopidy.Library.search(%{artist: [artist]}),
           {:ok, :success} <- Mopidy.Tracklist.clear,
           {:ok, tracks} when is_list(tracks) <- Mopidy.Tracklist.add(search_results.tracks |> Enum.map(fn(%Mopidy.Track{} = track) -> track.uri end)),
           {:ok, :success} <- Mopidy.Playback.play do
        "Playing music by " <> String.capitalize(artist)
      else
        {:error, error_message} -> error_message
        _                       -> "Couldn't play music by that artist"
      end

    send message, response
  end
end
