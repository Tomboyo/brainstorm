require "brainstorm"
require 'brainstorm/cli'

require "minitest/autorun"

module Brainstorm::CliTest

  Cli = Brainstorm::Cli

  MOCK_ID = "mock topic id"
  MOCK_TOPIC = { "label" => "mock label" }

  class MockService
    attr_reader :called

    def initialize()
      @called = []
    end

    def create_topic(label)
      @called << { method: :create_topic, label: label }
      MOCK_ID
    end

    def fetch_topic(id)
      @called << { method: :fetch_topic, id: id }
      MOCK_TOPIC
    end
  end

  describe 'create-topic' do
    before do
      @mock_service = MockService.new
      @cli = Cli.new(@mock_service)
    end

    describe 'when given a label argument' do
      before do
        @label = 'my label'
        @subject = @cli.call([ 'create-topic', @label ])
      end

      it 'invokes Service#create_topic' do
        assert_equal [{ method: :create_topic, label: @label }],
          @mock_service.called
      end

      it 'returns the id from Service#create_topic' do
        assert_equal MOCK_ID, @subject
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
    before do
      @mock_service = MockService.new
      @cli = Cli.new(@mock_service)
    end

    describe 'when given an id argument' do
      before do
        @id = 'some-id'
        @subject = @cli.call([ 'fetch-topic', @id ])
      end

      it 'invokes Service#fetch_topic' do
        assert_equal [{ method: :fetch_topic, id: @id }],
          @mock_service.called
      end

      it 'returns the topic hash from Service#fetch_topic' do
        assert_equal MOCK_TOPIC, @subject
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