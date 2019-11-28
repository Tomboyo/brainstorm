require 'brainstorm'
require 'brainstorm/model'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'

Brainstorm::Model::Document = Struct.new(:topic, :facts) do
  def self.from_hash(hash)
    topic = Brainstorm::Model::Topic.from_hash(hash['topic'])
    facts = hash['facts'].map { |x| Brainstorm::Model::Fact.from_hash(x) }
    self.new(topic, facts)
  end

  class << self
    alias_method :super_new, :new
    def new(topic, facts)
      facts = Set.new(facts)
      super_new(topic, facts)
    end
  end
end
