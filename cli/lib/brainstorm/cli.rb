require 'brainstorm'
require 'brainstorm/service'

require 'tomlrb'

class Brainstorm::Cli

  Service = Brainstorm::Service

  def initialize(service, editor, presenter)
    @service = service
    @editor = editor
    @presenter = presenter
  end

  def call(args)
    command = args.shift

    case command
    when 'version'
      Brainstorm::VERSION
    when 'create-topic'
      create_topic(args)
    when 'fetch-document'
      fetch_document(args)
    when 'create-fact'
      create_fact(args)
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

  def fetch_document(args)
    if args.length != 1
      error('Invalid arguments')
    else
      id = args.first
      document = @service.fetch_document(id)
      @presenter.present(document)
    end
  end

  def create_fact(args)
    if 1 > args.length
      error('Invalid arguments')
    else
      ids = args
      content = @editor.get_content()
      @service.create_fact(ids, content)
    end
  end
end