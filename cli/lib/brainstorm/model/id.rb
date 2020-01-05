require 'brainstorm'
require 'brainstorm/model'

module Brainstorm::Model::Id
  def self.is_id?(id)
    id.match(/.{8}-.{4}-.{4}-.{4}-.{12}/)
  end
end
