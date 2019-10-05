require "test_helper.rb"
require 'brainstorm'
require 'brainstorm/cli'

module Brainstorm::VersionTest

  Cli = Brainstorm::Cli

  describe 'brainstorm version' do

    before do
      cli = Cli.new(nil)
      @subject = cli.call([ 'version' ])
    end

    it 'returns the gem version' do
      assert_equal Brainstorm::VERSION, @subject
    end
  end

end