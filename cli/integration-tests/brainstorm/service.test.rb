require "brainstorm"
require 'brainstorm/service'

require 'minitest/autorun'

class Brainstorm::ServiceTest < Minitest::Test
  def setup
    @service = Brainstorm::Service.new(
      "host" => 'localhost',
      "port" => 8080)
  end

  def test_create_and_fetch_a_topic
    # After I create a new topic
    label = 'my topic label'
    id = @service.create_topic(label)

    # When I fetch the returned id
    topic = @service.fetch_topic(id)

    # Then I get the topic I created
    assert_equal label, topic['label']
  end
end