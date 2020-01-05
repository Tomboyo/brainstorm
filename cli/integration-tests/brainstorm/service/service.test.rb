require "brainstorm"
require 'brainstorm/service'
require 'brainstorm/model/document'
require 'brainstorm/model/fact'
require 'brainstorm/model/id'
require 'brainstorm/model/topic'

require 'minitest/autorun'

module Brainstorm::CliTest
  Response = Brainstorm::Service::Response
  Document = Brainstorm::Model::Document
  Fact     = Brainstorm::Model::Fact
  Id       = Brainstorm::Model::Id
  Topic    = Brainstorm::Model::Topic

  describe Brainstorm::Service do
    before do
      @service = Brainstorm::Service.new(
        "host" => 'localhost',
        "port" => 8080)
    end

    # TODO: verify side-effects with get_topic
    describe '#create_topic' do
      before do
        @subject = @service.create_topic("topic label")
      end

      after do
        @service.delete_topic(@subject)
      end

      it 'returns the id of the newly-created topic' do
        assert Id.is_id?(@subject)
      end
    end

    describe '#create_fact' do

      # TODO: Response.new(:id, id) case

      describe 'given a term which matches nothing' do
        it 'returns an empty match response' do
          expected = Response.new(:match, { "term" => Set.new() })

          actual = @service.create_fact([ 'term' ], 'content')

          assert_equal expected, actual
        end
      end

      describe 'given a term which matches several topics' do
        before do
          @topic_a_id = @service.create_topic('Topic A')
          @topic_b_id = @service.create_topic('Topic B')
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

          actual = @service.create_fact([ 'Topic' ], 'content')
          
          assert_equal expected, actual
        end
      end
    end

    describe '#find_topics' do
      describe 'given a search term which matches nothing' do
        it 'returns the empty set' do
          assert_equal Set.new(), @service.find_topics('notopic')
        end
      end

      describe 'given a search term which matches topics' do
        before do
          @topic_a_id = @service.create_topic('Topic A')
          @topic_b_id = @service.create_topic('Topic B')
          @topic_a = Topic.new(@topic_a_id, 'Topic A')
          @topic_b = Topic.new(@topic_b_id, 'Topic B')
        end
  
        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end
  
        it 'returns a set of those topics' do
          expected = Set.new([ @topic_a, @topic_b ])
          actual = @service.find_topics('Topic')
          assert_equal expected, actual
        end
      end
    end

    describe '#delete_topic' do
      describe 'given the id of a topic' do
        before do
          @topic_a_id = @service.create_topic('Topic A')
        end

        it 'deletes the topic' do
          @service.delete_topic(@topic_a_id)
          expected = Set.new()
          actual = @service.find_topics('Topic A')
          assert_equal expected, actual
        end
      end
    end

    describe '#fetch_document' do
      describe 'given a topic id which identifies a missing topic' do
        it 'generates an error indicating that no topic exists' do
          # we must pass a string with a valid id structure so that the rest
          # service does not interpret this as a search term.
          fake_uuid = '88888888-4444-4444-4444-121212121212'
          actual = @service.fetch_document(fake_uuid)
          expected = Response.new(:enoent, nil)
          assert_equal expected, actual
        end
      end

      describe 'given topics A and B related by fact F' do
        before do
          @topic_a_id = @service.create_topic('Topic A')
          @topic_b_id = @service.create_topic('Topic B')
          @topic_a = Topic.new(@topic_a_id, 'Topic A')
          @topic_b = Topic.new(@topic_b_id, 'Topic B')

          @fact_f_id = @service.create_fact(
              [ @topic_a_id, @topic_b_id ],
              'fact content')
            .value

          @fact = Fact.new(@fact_f_id, 'fact content', [ @topic_a, @topic_b ])
        end

        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end

        it 'generates a document from topic A related to B by F' do
          actual = @service.fetch_document(@topic_a_id)
          expected = Response.new(:document, Document.new(@topic_a, [ @fact ]))
          assert_equal expected, actual
        end

        it 'generates a document from topic B related to A by F' do
          actual = @service.fetch_document(@topic_b_id)
          expected = Response.new(:document, Document.new(@topic_b, [ @fact ]))
          assert_equal expected, actual
        end
      end

      describe 'given a term which matches zero topics' do
        it 'returns a mapping from the term to the empty set' do
          actual = @service.fetch_document('none')
          expected = Response.new(:match, { 'none' => Set.new() })
          assert_equal expected, actual
        end
      end

      describe 'given a term which matches many topics' do
        before do
          @topic_a_id = @service.create_topic('Topic A')
          @topic_b_id = @service.create_topic('Topic B')
          @topic_a = Topic.new(@topic_a_id, 'Topic A')
          @topic_b = Topic.new(@topic_b_id, 'Topic B')
        end

        after do
          @service.delete_topic(@topic_a_id)
          @service.delete_topic(@topic_b_id)
        end

        it 'returns a mapping from the term to the set of matched topics' do
          actual = @service.fetch_document('Topic')
          expected = Response.new(
            :match,
            { 'Topic' => Set.new([ @topic_a, @topic_b ]) })
          
          assert_equal expected, actual
        end
      end
    end
  end
end