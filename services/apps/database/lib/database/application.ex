defmodule Database.Application do
  use Application

  @spec start(any, any) ::
      { :ok, pid }
    | { :error, reason :: String.t }
  def start(_type, args) do
    with { :ok, config } <- get_configuration(args)
    do
      Database.start_link(config)
    else
      { :error, message } -> { :error, message }
    end
  end

  defp get_configuration(args) do
    with { :ok, config    } <- get_config(args),
         { :ok, url       } <- get_key(config, "url"),
         { :ok, ssl       } <- get_key(config, "ssl", true),
         { :ok, username  } <- get_key(config, "username"),
         { :ok, password  } <- get_key(config, "password"),
         { :ok, pool_size } <- get_key(config, "pool_size", 1)
    do
      {
        :ok,
        [
          url: url,
          ssl: ssl,
          basic_auth: [
            username: username,
            password: password
          ],
          pool_size: pool_size
        ]
      }
    else
      { :error, message } -> { :error, "Unable to start database: #{message}" }
    end
  end

  defp get_config(args) do
    with { :ok, path   } <- get_path(args),
         { :ok, toml   } <- Toml.decode_file(path)
    do
      get_key(toml, "database")
    end
  end

  @path Application.fetch_env!(:database, :default_config_path)
  defp get_path(args) do
    case args do
      [ path ] -> { :ok, Path.expand(path) }
      []       -> { :ok, Path.expand(@path) }
      _        -> { :error, "Invalid arguments (expected `[ path ]`): #{args}" }
    end
  end

  defp get_key(map, key, default \\ nil) do
    case Map.fetch(map, key) do
      :error ->
        if default == nil do
          { :error, "Config for key `#{key}` not found" }
        else
          { :ok, default }
        end
      { :ok, value } -> { :ok, value }
    end
  end
end
