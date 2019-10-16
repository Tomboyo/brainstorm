require 'brainstorm'
require 'brainstorm/service'

require 'tomlrb'

class Brainstorm::Cli

  Service = Brainstorm::Service

  CONFIG_PATH = '~/.brainstorm/config'

  def initialize(service = nil)
    if service != nil
      @service = service
    else
      file_path = File.expand_path(CONFIG_PATH)
      configuration = Tomlrb.load_file(file_path)["rest"]
      @service = Service.new(configuration)
    end
  end

  def call(args)
    command = args.shift

    case command
    when 'version'
      Brainstorm::VERSION
    when 'create-topic'
      create_topic(args)
    when 'fetch-topic'
      fetch_topic(args)
    end
  end

  private
  
  def create_topic(args)
    if args.length != 1
      error('Invalid arguments')
    else
      label = args.first
      @service.create_topic(label)
    end
  end

  def error(message)
    "Error: #{message}"
  end

  def fetch_topic(args)
    if args.length != 1
      error('Invalid arguments')
    else
      id = args.first
      @service.fetch_topic(id)
    end
  end
  
end