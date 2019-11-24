require 'brainstorm'
require 'brainstorm/service'

require 'tomlrb'

class Brainstorm::Cli

  Service = Brainstorm::Service

  def initialize(service, editor)
    @service = service
    @editor = editor
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
      topic = @service.fetch_document(id)
      format_topic(topic)
    end
  end

  def format_topic(topic)
    <<~ADOC
    = #{topic["label"]}
    #{format_facts(topic["facts"])}
    ADOC
  end

  def format_facts(facts)
  '(No facts are associated with this topic.)'
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