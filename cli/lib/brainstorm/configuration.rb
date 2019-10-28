require 'brainstorm'

module Brainstorm::Configuration
  CONFIG_PATH = '~/.brainstorm/config'
  def self.get_config(path = CONFIG_PATH)
    file_path = File.expand_path(path)
    configuration = Tomlrb.load_file(file_path)
  end
end