require "brainstorm"
require 'brainstorm/adoc_presenter'
require 'brainstorm/model/document'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'

require "minitest/autorun"
require 'minitest/mock'

module Brainstorm::AdocPresenterTest
  Document = Brainstorm::Model::Document
  Fact     = Brainstorm::Model::Fact
  Topic    = Brainstorm::Model::Topic

  describe Brainstorm::AdocPresenter do
    before do
      @presenter = Brainstorm::AdocPresenter.new
    end

    describe '#present_topics' do
      before do
        topic_a = Topic.new('topic-a-id', 'Topic A')
        topic_b = Topic.new('topic-b-id', 'Topic B')
        topics = [ topic_a, topic_b ]

        @subject = @presenter.present_topics(topics)
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

    describe '#present_document' do
      before do
        topic_a  = Topic.new('topic-a-id', 'Topic A')
        topic_b  = Topic.new('topic-b-id', 'Topic B')
        fact_1   = Fact.new('fact-1-id', 'fact 1 content', [ topic_a ])
        fact_2   = Fact.new('fact-2-id', 'fact 2 content', [ topic_a, topic_b ])
        document = Document.new(topic_a, [ fact_1, fact_2 ])

        @subject = @presenter.present_document(document)
      end

      # Characterization test for simplicity.
      # Note that order is imposed alphabetically.
      # ( Topics are orderd alphabetically by label, paragraphs are organized
      # alphabetically by heading.)
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