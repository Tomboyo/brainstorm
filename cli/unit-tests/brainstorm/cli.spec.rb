require "brainstorm"
require 'brainstorm/cli'

require 'minitest/autorun'

module Brainstorm::CliTest
  describe Brainstorm::Cli do
    before do
      @service = Minitest::Mock.new
      @presenter = Minitest::Mock.new
      @editor = Minitest::Mock.new
      @cli = Brainstorm::Cli.new(@service, @editor, @presenter)
    end

    describe 'version' do
      it 'returns the cli version' do
        assert_equal Brainstorm::VERSION, @cli.call([ 'version' ])
      end
    end

    describe 'create-topic' do
      before do
        # Creates a topic with the given label
        @service.expect(:create_topic, :expected, [ 'label' ])

        @subject = @cli.call([ 'create-topic', 'label' ])
      end

      it 'creates a topic with the given label' do
        assert_mock @service
      end

      it 'returns the service response' do
        assert_equal :expected, @subject
      end
    end

    describe 'create-fact' do
      before do
        # Reads fact content from the user's editor,
        @editor.expect(:get_content, :content)
        # then creates a fact with that content and the given terms,
        @service.expect(:create_fact, :service_response, [ [ :term ], :content ])
        # and finally presents the new fact to the user.
        @presenter.expect(:create_fact, :presented_response, [ :service_response ])

        @subject = @cli.call([ 'create-fact', :term ])
      end

      it 'creates and presents facts' do
        assert_mock @editor
        assert_mock @service
        assert_mock @presenter
      end

      it 'returns the presented fact' do
        assert_equal :presented_response, @subject
      end
    end

    describe 'find-topics' do
      before do
        # Searches for topics matching the given term by their label
        @service.expect(:find_topics, :service_response, [ :term ])
        # then presents those matches to the user.
        @presenter.expect(:find_topics, :presented_topics, [ :service_response ])

        @subject = @cli.call([ 'find-topics', :term ])
      end

      it 'finds and presents topics by the given search term' do
        assert_mock @service
        assert_mock @presenter
      end

      it 'returns the presented topics' do
        assert_equal :presented_topics, @subject
      end
    end

    describe 'delete-topic' do
      before do
        # Attempts to delete the indicated topic
        @service.expect(:delete_topic, :service_response, [ :term ])
        # then returns a message to the user
        @presenter.expect(:delete_topic, :presenter_response, [ :service_response ])

        @subject = @cli.call([ 'delete-topic', :term ])
      end

      it 'deletes the indicated topic and informs the user' do
        assert_mock @service
        assert_mock @presenter
      end

      it 'returns a message from the presenter' do
        assert_equal :presenter_response, @subject
      end
    end

    describe 'fetch-document' do
      before do
        # Attempts to fetch a document based on the given term
        @service.expect(:fetch_document, :service_response, [ :term ])
        # then presents that document to the user
        @presenter.expect(:fetch_document, :presented_document, [ :service_response ])

        @subject = @cli.call([ 'fetch-document', :term ])
      end

      it 'fetches and presents a document' do
        assert_mock @service
        assert_mock @presenter
      end

      it 'returns the presented document' do
        assert_equal @subject, :presented_document
      end
    end
  end
end
