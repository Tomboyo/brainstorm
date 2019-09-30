require 'test_helper'
require 'brainstorm/cli'

module Brainstorm::CliTest

  Cli = Brainstorm::Cli

  class MockService
    def initialize(id)
      @id = id
    end

    def create_topic(args)
      @id
    end
  end

  describe 'create-topic' do

    describe 'when given a label argument' do
      before do
        @id = 'arbitrary topic id'
        cli = Cli.new(MockService.new(@id))
        @subject = cli.call([ 'create-topic', 'my label' ])
      end

      it 'returns an id' do
        assert_equal @id, @subject
      end
    end

    describe 'when given too few arguments' do
      before do
        cli = Cli.new(nil)
        @subject = cli.call([ 'create-topic' ])
      end

      it 'returns an error' do
        assert @subject.start_with?('Error: ')
      end
    end

    describe 'when given too many arguments' do
      before do
        cli = Cli.new(nil)
        @subject = cli.call([ 'create-topic', 'a', 'b' ])
      end

      it 'returns an error' do
        assert @subject.start_with?('Error: ')
      end
    end

  end

end