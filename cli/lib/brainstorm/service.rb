require 'brainstorm'
require 'brainstorm/logging'
require 'brainstorm/model/document'

require 'http'
require 'json'

# A simple HTTP client for the brainstorm service.
class Brainstorm::Service
  include Brainstorm::Logging

  def initialize(options)
    host = options["host"]
    port = options["port"]
    @base = "http://#{host}:#{port}"
  end

  def create_topic(label)
    HTTP.post("#{@base}/topic", { json: { "label" => label }})
      .body
      .to_s
  rescue Exception => e
    log_error("Failed to create topic with label `#{label}`", e)
  end

  def fetch_document(id)
    HTTP.get("#{@base}/document/#{id}")
      .body
      .to_s
      .yield_self { |x| JSON.parse(x) }
      .yield_self { |x| Brainstorm::Model::Document.from_hash(x) }
  rescue Exception => e
    log_error("Failed to fetch id `#{id}`", e)
  end

  def create_fact(ids, content)
    HTTP.post("#{@base}/fact", {
        json: { 'topics' => ids, 'content' => content }})
      .body
      .to_s
  rescue Exception => e
    log_error("Failed to create fact", e)
  end

  def find_topics(search_term)
    HTTP.get("#{@base}/topic", { params: { 'search' => search_term }})
      .body
      .to_s
      .yield_self { |x| JSON.parse(x) }
      .map { |x| Brainstorm::Model::Topic.from_hash(x) }
      .yield_self { |x| Set.new(x) }
  rescue Exception => e
    log_error("Failed to search for topics", e)
  end

end