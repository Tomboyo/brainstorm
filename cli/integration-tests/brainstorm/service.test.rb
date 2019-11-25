require "brainstorm"
require 'brainstorm/service'

require 'minitest/autorun'

class Brainstorm::ServiceTest < Minitest::Test
  def setup
    @service = Brainstorm::Service.new(
      "host" => 'localhost',
      "port" => 8080)
  end

  def test_create_and_fetch_document_without_facts
    # Given I have a persistent topic
    label = 'my topic label'
    id = @service.create_topic(label)

    # When I fetch the returned id
    document = @service.fetch_document(id)

    # Then I get a document for that topic
    assert_equal label, document['topic']['label']

    # And that document has no facts
    assert_equal [], document['facts']
  end

  def test_create_and_fetch_document_with_facts
    # Given I have a persistent topic with associated facts
    label = 'my topic label'
    topic_id = @service.create_topic(label)
    content = 'my fact content'
    fact_id = @service.create_fact([ topic_id ], content)

    # When I fetch the document by topic id
    document = @service.fetch_document(topic_id)

    # Then I get a document with the topic label
    assert_equal label, document['topic']['label']

    # And that document has my fact
    assert_includes document['facts'], {
      'id' => fact_id,
      'content' => content,
      'topics' => [{ 'id' => topic_id, 'label' => label }]
    }
  end
end