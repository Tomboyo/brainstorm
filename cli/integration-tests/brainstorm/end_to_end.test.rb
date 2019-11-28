require "brainstorm"
require 'brainstorm/service'
require 'brainstorm/cli'

require 'minitest/autorun'

class Brainstorm::CliTest < Minitest::Test

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
    assert_equal document, {
      'topic' => { 'id' => topic_a_id, 'label' => 'Topic A' },
      'facts' => [{
        'id' => fact_id,
        'content' => 'fact content',
        'topics' => [
          { 'id' => topic_a_id, 'label' => 'Topic A' },
          { 'id' => topic_b_id, 'label' => 'Topic B' }
        ]
      }]
    }
  end
end