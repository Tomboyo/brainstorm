require "test_helper.rb"

describe 'brainstorm version' do
  it 'returns the gem version' do
    assert_equal BrainstormCli::VERSION, BrainstormCli.main(%w(version))
  end
end