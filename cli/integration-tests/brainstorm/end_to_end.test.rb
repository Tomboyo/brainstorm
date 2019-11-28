require "brainstorm"
require 'brainstorm/service'
require 'brainstorm/cli'
require 'brainstorm/model/document'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'

require 'minitest/autorun'

class Brainstorm::CliTest < Minitest::Test
  Document = Brainstorm::Model::Document
  Fact     = Brainstorm::Model::Fact
  Topic    = Brainstorm::Model::Topic

  # Allows this suite to operate on the data structures instead of renderings
  # of those structures.
  class NoopPresenter
    def present(document) 
      document
    end
  end

  def setup
    service = Brainstorm::Service.new(
      "host" => 'localhost',
      "port" => 8080)
    presenter = NoopPresenter.new

    @mock_editor = Minitest::Mock.new

    @cli = Brainstorm::Cli.new(service, @mock_editor, presenter)
  end

  def test_create_and_fetch_a_document
    # When I create two topis
    topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
    topic_b_id = @cli.call([ 'create-topic', 'Topic B' ])

    # And attach a fact between them
    @mock_editor.expect :get_content, 'fact content'
    fact_id = @cli.call([ 'create-fact', topic_a_id, topic_b_id ])

    # And fetch a document for one of the topics,
    document = @cli.call([ 'fetch-document', topic_a_id ])

    # Then I get a document for the fetched topic
    topic_a  = Topic.new(topic_a_id, 'Topic A')
    topic_b  = Topic.new(topic_b_id, 'Topic B')
    fact     = Fact.new(fact_id, 'fact content', [ topic_a, topic_b ])
    expected = Document.new(topic_a, [ fact ])

    assert_equal expected, document
  end
end