require "brainstorm"
require 'brainstorm/adoc_presenter'
require 'brainstorm/model/document'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'
require 'brainstorm/service/response'

require "minitest/autorun"
require 'minitest/mock'

module Brainstorm::AdocPresenterTest
  Response = Brainstorm::Service::Response
  Document = Brainstorm::Model::Document
  Fact     = Brainstorm::Model::Fact
  Topic    = Brainstorm::Model::Topic

  describe Brainstorm::AdocPresenter do
    before do
      @presenter = Brainstorm::AdocPresenter.new
    end

    describe '#delete_topic' do
      it 'Confirms successful deletion' do
        assert_equal 'Topic deleted.', @presenter.delete_topic(:ok)
      end

      it 'Informs the user when the topic was not found' do
        assert_equal 'Topic not found.', @presenter.delete_topic(:enoent)
      end

      it 'Renders errors' do
        assert_includes @presenter.delete_topic(StandardError.new("message")),
          "message"
      end

      it 'Renders a default error for unexpected values' do
        assert_equal 'Unexpected error: unexpected service response `woops`.',
          @presenter.delete_topic("woops")
      end
    end

    describe '#find_topics' do
      before do
        topic_a = Topic.new('topic-a-id', 'Topic A')
        topic_b = Topic.new('topic-b-id', 'Topic B')
        topics = [ topic_a, topic_b ]

        @subject = @presenter.find_topics(topics)
      end

      it 'renders topics alphabetiaclly as a list' do
        expected =
          <<~ADOC
          Topic A <topic-a-id>
          Topic B <topic-b-id>
          ADOC
        
        assert_equal expected, @subject
      end
    end

    describe '#fetch_document' do
      describe 'given an enoent response' do
        it 'indicates that the document was not found' do
          response = Response.new(:enoent, nil)
          assert_equal(
            "Could not generate document: No topic with the given id exists.",
            @presenter.fetch_document(response))
        end
      end

      describe 'given a match response' do
        it 'indicates when no topics were found by the search term' do
          response = Response.new(:match, { "none" => Set.new() })
          actual = @presenter.fetch_document(response)
          expected = "No topics could be found for the search term \"none\"."

          assert_equal expected, actual
        end

        it 'renders matched topics' do
          topic_a  = Topic.new('topic-a-id', 'Topic A')
          topic_b  = Topic.new('topic-b-id', 'Topic B')
          response = Response.new(:match, {
            "topic" => Set.new([ topic_b, topic_a ])
          })
          actual = @presenter.fetch_document(response)

          # Characterization test.
          # The list is sorted by topic label.
          expected =
            <<~MESSAGE
            The term "topic" matched the following topics:
            * Topic A (topic-a-id)
            * Topic B (topic-b-id)
            Please refine your request to match a specific topic.
            MESSAGE
          .strip()

          assert_equal expected, actual
        end
      end

      describe 'given a document' do
        before do
          topic_a  = Topic.new('topic-a-id', 'Topic A')
          topic_b  = Topic.new('topic-b-id', 'Topic B')
          fact_1   = Fact.new('fact-1-id', 'fact 1 content', [ topic_a ])
          fact_2   = Fact.new('fact-2-id', 'fact 2 content', [ topic_a, topic_b ])
          document = Document.new(topic_a, [ fact_1, fact_2 ])

          response = Response.new(:document, document)
          @subject = @presenter.fetch_document(response)
        end

        # Characterization test.
        # Paragraphs are ordered alphabetically by their heading.
        # Headings are generated alphabetically by topic label.
        it 'renders the document in ADOC' do
          expected =
            <<~ADOC
            = Topic A
            
            == 1. Topic A
            fact 1 content

            == 2. Topic A - Topic B
            fact 2 content

            == Referenced Facts
            1. fact-1-id
            * Topic A: topic-a-id

            2. fact-2-id
            * Topic A: topic-a-id
            * Topic B: topic-b-id
            ADOC

          assert_equal expected, @subject
        end
      end
    end
  end
end