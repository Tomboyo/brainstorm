require 'brainstorm'
require 'brainstorm/logging'

require 'cgi/util'
require 'json'
require 'net/http'

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

  def fetch_topic(id)
    json = get("/topic/#{CGI::escape(id)}")
    JSON.parse(json)
  rescue Exception => e
    log_error("Failed to fetch id `#{id}`", e)
  end

  def create_fact(ids, content)
    "create_fact stub"
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