defmodule HedwigMopidy.Responders.Playback do
  use Hedwig.Responder

  hear ~r/play artist/i, msg do
    send msg, "play artist"
  end
end
