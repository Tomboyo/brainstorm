require "brainstorm"
require 'brainstorm/service'
require 'brainstorm/cli'
require 'brainstorm/logging'
require 'brainstorm/model/document'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'

require 'minitest/autorun'

module Brainstorm::CliTest
  Document = Brainstorm::Model::Document
  Fact     = Brainstorm::Model::Fact
  Topic    = Brainstorm::Model::Topic

  # Allows this suite to operate on the data structures instead of renderings
  # of those structures.
  class NoopPresenter
    def present_document(document) ; document ; end
    def present_topics(topics) ; topics ; end
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
      describe 'given topics A and B related by fact F' do
        before do
          @topic_a_id = @cli.call([ 'create-topic', 'Topic A' ])
          @topic_b_id = @cli.call([ 'create-topic', 'Topic B' ])

          @mock_editor.expect :get_content, 'fact content'
          @fact_f_id = @cli.call([ 'create-fact', @topic_a_id, @topic_b_id ])
        end

        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end

        it 'generates a document from topic A' do
          document = @cli.call([ 'fetch-document', @topic_a_id ])

          # The document is rooted on A and includes fact F (and associated topic B)
          topic_a  = Topic.new(@topic_a_id, 'Topic A')
          topic_b  = Topic.new(@topic_b_id, 'Topic B')
          fact     = Fact.new(@fact_f_id, 'fact content', [ topic_a, topic_b ])
          expected = Document.new(topic_a, [ fact ])

          assert_equal expected, document
        end
      end
    end
  end
end