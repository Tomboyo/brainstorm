require "brainstorm"
require 'brainstorm/cli'

require "minitest/autorun"
require 'minitest/mock'

module Brainstorm::CliTest

  Cli = Brainstorm::Cli

  describe Brainstorm::Cli do
    before do
      @mock_service = Minitest::Mock.new
      @cli = Cli.new(@mock_service)
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

    describe 'fetch-topic' do
      describe 'when given an id argument' do
        before do
          @id = 'given id'

          @topic = { 'label' => 'topic label' }
          @mock_service.expect :fetch_topic, @topic, [ @id ]

          @subject = @cli.call([ 'fetch-topic', @id ])
        end

        it 'invokes Service#fetch_topic' do
          @mock_service.verify
        end

        it 'returns returns an adoc with the topic label as a title' do
          assert_includes @subject, "= #{@topic['label']}"
        end
      end

      describe 'when given too few arguments' do
        before do
          @subject = @cli.call([ 'fetch-topic' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end

      describe 'when given too many arguments' do
        before do
          @subject = @cli.call([ 'fetch-topic', 'a', 'b' ])
        end

        it 'returns an error' do
          assert @subject.start_with?('Error: ')
        end
      end
    end

  end
end