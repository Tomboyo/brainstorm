require "brainstorm"
require 'brainstorm/service'

require 'minitest/autorun'

class Brainstorm::ServiceTest < Minitest::Test
  def setup
    @service = Brainstorm::Service.new(
      "host" => 'localhost',
      "port" => 8080)
  end

  def test_create_and_fetch_a_document
    # After I create a new topic
    label = 'my topic label'
    id = @service.create_topic(label)

    # When I fetch the returned id
    document = @service.fetch_document(id)

    # Then I get a document for that topic
    assert_equal label, document['topic']['label']
  end
end