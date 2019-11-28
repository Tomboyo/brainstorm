require 'brainstorm'
require 'brainstorm/model'

Brainstorm::Model::Topic = Struct.new(:id, :label) do
  def self.from_hash(hash)
    self.new(hash['id'], hash['label'])
  end
end
