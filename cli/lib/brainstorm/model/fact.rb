require 'brainstorm'
require 'brainstorm/model'
require 'brainstorm/model/topic'

Brainstorm::Model::Fact = Struct.new(:id, :content, :topics) do
  def self.from_hash(hash)
    self.new(
      hash['id'],
      hash['content'],
      hash['topics'].map { |x| Brainstorm::Model::Topic.from_hash(x) })
  end

  class << self
    alias_method :super_new, :new
    def new(id, content, topics)
      topics = Set.new(topics)
      super_new(id, content, topics)
    end
  end
end
