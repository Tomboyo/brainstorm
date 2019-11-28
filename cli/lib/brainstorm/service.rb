require 'brainstorm'
require 'brainstorm/logging'

require 'cgi/util'
require 'json'
require 'net/http'

# A simple HTTP client for the brainstorm service.
#
# This is only exercised by the end-to-end tests because of the complexity in
# setting up a mock service to test against.
class Brainstorm::Service
  include Brainstorm::Logging

  def initialize(options)
    @host = options["host"]
    @port = options["port"]
  end

  def create_topic(label)
    post('/topic', { "label" => label }).body
  rescue Exception => e
    log_error("Failed to create topic with label `#{label}`", e)
  end

  def fetch_document(id)
    json = get("/document/#{CGI::escape(id)}")
    JSON.parse(json)
  rescue Exception => e
    log_error("Failed to fetch id `#{id}`", e)
  end

  def create_fact(ids, content)
    post('/fact', { 'topics' => ids, 'content' => content }).body
  rescue Exception => e
    log_error("Failed to create fact", e)
  end

  private
  
  def post(path, hash)
    uri = uri(path)
    data = hash.to_json
    Net::HTTP.post(uri, data, "Content-Type" => "application/json")
  end

  def uri(path)
    URI::HTTP.build(host: @host, port: @port, path: path)
  end

  def get(path)
    uri = uri(path)
    Net::HTTP.get(uri)
  end

end