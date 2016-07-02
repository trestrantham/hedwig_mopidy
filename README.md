# HedwigMopidy

A Mopidy responder for [Hedwig](https://github.com/hedwig-im/hedwig).

## Installation

After you [create a Hedwig robot](https://github.com/hedwig-im/hedwig#create-a-robot-module),
add hedwig_mopidy to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:hedwig_mopidy, "~> 0.0.2"}]
end
```

Ensure `hedwig_mopidy` is started before your application. Note that
[mopidy](https://github.com/trestrantham/mopidy) is a dependency that will be
started automatically when hedwig_mopidy is started.

```elixir
def application do
  [applications: [:hedwig_mopidy]]
end
```

Within your application you will need to configure the Mopidy API URL, web URL,
and optionally, the Icecast URL (see below). You do *not* want to put this
information in your `config.exs` file! Either put it in a
`{prod,dev,test}.secret.exs` file which is sourced by `config.exs`, or read the
values in from the environment:

The Mopidy API URL is a configuration option for
[mopidy](https://github.com/trestrantham/mopidy):

```elixir
config :mopidy,
  api_url: System.get_env("MOPIDY_API_URL")
```

While the web and Icecast URLs are configuration options for hedwig_mopidy
itself:

```elixir
config :hedwig_mopidy,
  web_url: Regex.replace(~r/\/rpc/, System.get_env("MOPIDY_API_URL"), "")
  icecast_url: System.get_env("HEDWIG_MOPIDY_ICECAST_URL")
```

Lastly, add `HedwigMopidy.Responders.Mopidy` as a responder to your robot in
`mix.exs`.

## License

MIT License, see [LICENSE](LICENSE) for details.
