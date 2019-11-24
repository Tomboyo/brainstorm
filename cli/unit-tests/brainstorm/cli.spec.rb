require "brainstorm"
require 'brainstorm/cli'

require "minitest/autorun"
require 'minitest/mock'

module Brainstorm::CliTest

  Cli = Brainstorm::Cli

  describe Brainstorm::Cli do
    before do
      @mock_service = Minitest::Mock.new
      @mock_editor = Minitest::Mock.new
      @cli = Cli.new(@mock_service, @mock_editor)
    end

    describe 'version' do
      before do
        @subject = @cli.call([ 'version' ])
      end

      it 'returns the gem version' do
        assert_equal Brainstorm::VERSION, @subject
      end
    end

    describe 'create-topic' do
      describe 'when given a label argument' do
        before do
          @label = 'my label'
          
          @new_topic_id = 'new topic id'
          @mock_service.expect :create_topic, @new_topic_id, [ @label ]

          @subject = @cli.call([ 'create-topic', @label ])
        end

        it 'invokes Service#create_topic' do
          @mock_service.verify
        end

        it 'returns the id from Service#create_topic' do
          assert_equal @new_topic_id, @subject
        end
      end

      describe 'when given too few arguments' do
        before do
          @subject = @cli.call([ 'create-topic' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end

      describe 'when given too many arguments' do
        before do
          @subject = @cli.call([ 'create-topic', 'a', 'b' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end
    end

    describe 'fetch-document' do
      describe 'when given the id of a topic with no facts' do
        before do
          @id = 'given id'

          @topic = { 'topic' => 'topic label' }
          @facts = []
          @document = { 'topic' => @topic, 'facts' => @facts }
          @mock_service.expect :fetch_document, @document, [ @id ]

          @subject = @cli.call([ 'fetch-document', @id ])
        end

        it 'invokes Service#fetch_document' do
          @mock_service.verify
        end

        it 'returns an adoc with the topic label as a title' do
          assert_includes @subject, "= #{@topic['label']}"
        end

        it 'returns an adoc with an empty list of facts' do
          assert_includes @subject,
            "(No facts are associated with this topic.)"
        end
      end

      describe 'when given the id of a topic with associated facts' do
        before do
          @id = 'given id'
          @topic = { 'id' => @id, 'label' => 'topic label' }
          @other_topic = { 'id' => 'other id', 'label' => 'other topic label' }
          @fact = {
            'id' => 'fact id',
            'content' => 'fact content',
            'topics' => [ @topic, @other_topic ]
          }
          @document = {
            'topic' => @topic,
            'facts' => [ @fact ]
          }

          @mock_service.expect :fetch_document, @document, [ @id ]

          @subject = @cli.call([ 'fetch-document', @id ])
        end

        it 'invokes Service#fetch_document' do
          @mock_service.verify
        end

        it 'returns an adoc with the topic label as a title' do
          assert_includes @subject, "= #{@topic['label']}"
        end

        it 'returns an adoc with the content of each fact' do
          assert_includes @subject, @fact['content']
        end

        it 'returns an adoc with the id of each other related topic' do
          assert_includes @subject, @other_topic['id']
        end

        it 'returns an adoc with the label of each other related topic' do
          assert_includes @subject, @other_topic['label']
        end
      end

      describe 'when given too few arguments' do
        before do
          @subject = @cli.call([ 'fetch-document' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end

      describe 'when given too many arguments' do
        before do
          @subject = @cli.call([ 'fetch-document', 'a', 'b' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end
    end

    describe 'create-fact' do
      describe 'given topic ids and content from an editor' do
        before do
          @ids = [ 'id-1', 'id-2' ]

          @content = "mock content from the editor"
          @mock_editor.expect :get_content, @content, []

          @id = 'mock fact id returned by service'
          @mock_service.expect :create_fact, @id, [ @ids, @content ]

          @subject = @cli.call([ 'create-fact', *@ids ])
        end

        it 'invokes Service#create_fact' do
          @mock_service.verify
        end

        it 'invokes Editor#get_content' do
          @mock_editor.verify
        end

        it 'returns the new fact id from Service' do
          assert_equal @id, @subject
        end
      end
    
      describe 'given too few arguments' do
        before do
          @subject = @cli.call([ 'create-fact' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end
    end
  end
end