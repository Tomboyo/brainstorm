require 'brainstorm'
require 'brainstorm/logging'
require 'brainstorm/model/document'
require 'brainstorm/service/response'

require 'http'
require 'json'

# A simple HTTP client for the brainstorm service.
class Brainstorm::Service

  class ServiceError < RuntimeError ; end

  def initialize(options)
    host = options["host"]
    port = options["port"]
    @base = "http://#{host}:#{port}"
  end

  def create_topic(label)
    HTTP.post("#{@base}/topic", { json: { "label" => label }})
      .body
      .to_s
      .yield_self { |x| JSON.parse(x) }
  rescue Exception
    raise ServiceError, "Failed to create topic with label `#{label}`"
  end

  def fetch_document(id)
    response = HTTP.get("#{@base}/document/#{id}")

    case response.code
    when 200
      json = JSON.parse(response.body.to_s)
      unless json["document"].nil?
        Response.new(
          :document,
          Brainstorm::Model::Document.from_hash(json["document"]))
      else
        Response.new(:match, get_matches(json))
      end
    when 404
      Response.new(:enoent, nil)
    else
      unexpected_response_code(response.code)
    end
  rescue Exception
    raise ServiceError, "Failed to fetch document `#{id}`"
  end

  def create_fact(terms, content)
    payload = { 'topics' => terms, 'content' => content }
    response = HTTP.post("#{@base}/fact", { json: payload})

    case response.code
    when 201
      json = JSON.parse(response.body.to_s)
      Response.new(:id, json)
    when 200
      json = JSON.parse(response.body.to_s)
      Response.new(:match, get_matches(json))
    else
      unexpected_response_code(response.code)
    end
  rescue Exception => e
    puts e
    raise ServiceError, "Failed to create fact `#{payload}`"
  end

  def find_topics(term)
    HTTP.get("#{@base}/topic", { params: { 'search' => term }})
      .body
      .to_s
      .yield_self { |x| JSON.parse(x) }
      .map { |x| Brainstorm::Model::Topic.from_hash(x) }
      .yield_self { |x| Set.new(x) }
  rescue Exception
    raise ServiceError, "Failed to find topics by term `#{term}``"
  end

  def delete_topic(id)
    response = HTTP.delete("#{@base}/topic/#{id}")
    case response.code
    when 204
      :ok
    when 404
      :enoent
    else
      unexpected_response_code(response.code)
    end
  rescue Exception
    raise ServiceError, "Failed to delete topic by term `#{id}`"
  end

  private

  def unexpected_response_code(code)
    raise "Unexpected response code `#{code}`"
  end

  def get_matches(json)
    json['match'].transform_values do |list|
      Set.new(list.map { |x| Brainstorm::Model::Topic.from_hash(x) })
    end
  end
end