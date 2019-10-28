import Config

config :database,
  default_config_path: "~/.brainstorm/config"

import_config "#{Mix.env()}.exs"
