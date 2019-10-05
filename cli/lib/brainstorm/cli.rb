class Brainstorm::Cli

  def initialize(service)
    @service = service
  end

  def call(args)
    command = args.shift

    case command
    when 'version'
      Brainstorm::VERSION
    when 'create-topic'
      create_topic(args)
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
  
end