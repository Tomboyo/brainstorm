require 'brainstorm'
require 'brainstorm/service'

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
    when 'find-topics'
      find_topics(args)
    when 'delete-topic'
      delete_topic(args)
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
      @presenter.fetch_document(document)
    end
  end

  def create_fact(args)
    if 1 > args.length
      error('Invalid arguments')
    else
      ids_or_search_terms = args
      content = @editor.get_content()
      @service.create_fact(ids_or_search_terms, content)
    end
  end

  def find_topics(args)
    unless args.length == 1
      error('Invalid arguments')
    else
      search_term = args.first
      topics = @service.find_topics(search_term)
      @presenter.find_topics(topics)
    end
  end

  def delete_topic(args)
    unless args.length == 1
      error('Invalid arguments')
    else
      id = args.first
      response = @service.delete_topic(id)
      @presenter.delete_topic(response)
    end
  end
end