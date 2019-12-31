require "brainstorm"
require 'brainstorm/service'
require 'brainstorm/cli'
require 'brainstorm/logging'
require 'brainstorm/model/document'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'

require 'minitest/autorun'

# A (mostly) end-to-end test of CLI integration with the REST service.
#
# We exercise the Cli class directly, which exercises unit integrations within
# the client code.
#
# We mock the presentation logic so that Service return values come back
# directly. This lets us validate the integration without also performing
# characterization tests of the presentation logic.
#
# Thus, we passively confirm that units integrate correctly while concentrating
# on client-service integration without being bogged down by output formatting.
# Hence, this is _mostly_ an end-to-end test.
module Brainstorm::CliTest
  Response = Brainstorm::Service::Response
  Document = Brainstorm::Model::Document
  Fact     = Brainstorm::Model::Fact
  Topic    = Brainstorm::Model::Topic

  # Allows this suite to operate on the data structures instead of renderings
  # of those structures.
  class NoopPresenter
    def fetch_document(document) ; document ; end
    def find_topics(topics) ; topics ; end
    def delete_topic(signal) ; signal ; end
  end

  describe Brainstorm::Cli do
    before do
      @service = Brainstorm::Service.new(
        "host" => 'localhost',
        "port" => 8080)
      presenter = NoopPresenter.new
      @mock_editor = Minitest::Mock.new
      @cli = Brainstorm::Cli.new(@service, @mock_editor, presenter)
    end

    describe '`version`' do
      it 'returns the cli version' do
        assert_equal Brainstorm::VERSION, @cli.call([ 'version' ])
      end
    end

    describe '`create-fact`' do
      describe 'given a term which matches nothing' do
        it 'returns an empty match response' do
          expected = Response.new(:match, { "term" => Set.new() })

          @mock_editor.expect(:get_content, "content")
          actual = @cli.call([ 'create-fact', 'term' ])

          assert_equal expected, actual
        end
      end

      describe 'given a term which matches several topics' do
        before do
          @topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
          @topic_b_id = @cli.call([ 'create-topic', 'Topic B' ])
          @topic_a = Topic.new(@topic_a_id, 'Topic A')
          @topic_b = Topic.new(@topic_b_id, 'Topic B')
        end
  
        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end

        it 'returns a match response' do
          expected = Response.new(:match, {
            "Topic" => Set.new([ @topic_a, @topic_b ])
          })

          @mock_editor.expect(:get_content, "content")
          actual = @cli.call([ 'create-fact', 'Topic' ])
          
          assert_equal expected, actual
        end
      end
    end

    describe '`find-topics` <term>' do
      describe 'given a search term which matches nothing' do
        it 'returns the empty set' do
          assert_equal Set.new(), @cli.call([ 'find-topics', 'notopic' ])
        end
      end

      describe 'given a search term which matches topics' do
        before do
          @topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
          @topic_b_id = @cli.call([ 'create-topic', 'Topic B' ])
        end
  
        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end
  
        it 'returns a set of those topics' do
          assert_equal(
            Set.new([
              Topic.new(@topic_a_id, 'Topic A'),
              Topic.new(@topic_b_id, 'Topic B')
            ]),
            @cli.call([ 'find-topics', 'Topic' ])
          )
        end
      end
    end

    describe 'delete-topic <topic-id>' do
      describe 'given the id of a topic' do
        before do
          @topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
        end

        it 'deletes the topic' do
          @cli.call([ 'delete-topic', @topic_a_id ])
          assert_equal Set.new(), @cli.call([ 'find-topics', 'Topic A' ])
        end
      end
    end

    describe '`fetch-document <topic-id>`' do
      describe 'given a topic id which identifies a missing topic' do
        it 'generates an error indicating that no topic exists' do
          # we must pass a string with a valid id structure so that the rest
          # service does not interpret this as a search term.
          fake_uuid = '88888888-4444-4444-4444-121212121212'
          actual = @cli.call([ 'fetch-document', fake_uuid ])
          expected = Response.new(:enoent, nil)
          assert_equal expected, actual
        end
      end

      describe 'given topics A and B related by fact F' do
        before do
          @topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
          @topic_b_id = @cli.call([ 'create-topic', 'Topic B' ])

          @mock_editor.expect :get_content, 'fact content'
          @fact_f_id = @cli.call([ 'create-fact', @topic_a_id, @topic_b_id ])

          @topic_a = Topic.new(@topic_a_id, 'Topic A')
          @topic_b = Topic.new(@topic_b_id, 'Topic B')
          @fact = Fact.new(@fact_f_id, 'fact content', [ @topic_a, @topic_b ])
        end

        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end

        it 'generates a document from topic A related to B by F' do
          actual = @cli.call([ 'fetch-document', @topic_a_id ])
          expected = Response.new(:document, Document.new(@topic_a, [ @fact ]))
          assert_equal expected, actual
        end

        it 'generates documents from topic B related to A by F' do
          actual = @cli.call([ 'fetch-document', @topic_b_id ])
          expected = Response.new(:document, Document.new(@topic_b, [ @fact ]))
          assert_equal expected, actual
        end
      end

      describe 'given a term which matches zero topics' do
        it 'returns a mapping from the term to the empty set' do
          actual = @cli.call([ 'fetch-document', 'none' ])
          expected = Response.new(:match, { 'none' => Set.new() })
          assert_equal expected, actual
        end
      end

      describe 'given a term which matches many topics' do
        before do
          @topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
          @topic_b_id = @cli.call([ 'create-topic', 'Topic B' ])
          @topic_a = Topic.new(@topic_a_id, 'Topic A')
          @topic_b = Topic.new(@topic_b_id, 'Topic B')
        end

        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end

        it 'returns a mapping from the term to the set of matched topics' do
          actual = @cli.call([ 'fetch-document', 'Topic' ])
          expected = Response.new(
            :match,
            { 'Topic' => Set.new([ @topic_a, @topic_b ]) })
          
          assert_equal expected, actual
        end
      end
    end
  end
end