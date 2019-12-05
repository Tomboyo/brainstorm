defmodule Rest.Router do
  use Plug.Router

  alias Database.{ Id }

  @topic_db Application.get_env(
    :rest, :topic_database, Database.Topic)
  @fact_db Application.get_env(
    :rest, :fact_database, Database.Fact)
  @document_db Application.get_env(
    :rest, :document_database, Database.Document)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/topic" do
    with { :ok, params } <- Map.fetch(conn, :body_params),
         { :ok, label  } <- Map.fetch(params, "label"),
         topic           <- @topic_db.new(label),
         :ok             <- @topic_db.persist(topic)
    do
      send_resp(conn, 201, topic.id |> to_string())
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  get "/topic" do
    with { :ok, params } <- param(conn, :params),
         { :ok, search } <- param(params, "search"),
         topics          <- @topic_db.find(search),
         { :ok, json }   <- Jason.encode(topics)
    do
      send_resp(conn, 200, json)
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  # TODO: incorporate into real error handling.
  # Useful for figuring out what parameters were missing.
  defp param(map, key) do
    case Map.fetch(map, key) do
      { :ok, value } -> { :ok, value }
      :error         -> { :error, "#{key} not found" }
    end
  end

  delete "/topic/:id" do
    with { :ok, params } <- param(conn, :params),
         { :ok, id     } <- param(params, "id"),
         id              <- Id.new(id)
    do
      case @topic_db.delete(id) do
        :ok               -> send_resp(conn, 204, "")
        :enoent           -> send_resp(conn, 404, "")
        { :error, error } -> todo_real_error_handling(conn, error)
      end
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  get "/document/:id" do
    with { :ok, params } <- Map.fetch(conn, :params),
         { :ok, id     } <- Map.fetch(params, "id"),
         id              <- Id.new(id),
         # TODO: Needs to be { :ok, value } tuple or else we can bleed an error.
         document_or_nil <- @document_db.fetch(id),
         { :ok, body }   <- encode(document_or_nil)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  defp encode(nil) do
    raise "not yet implemented!"
  end

  defp encode(%Database.Document{} = document) do
    Jason.encode(document)
  end

  post "/fact" do
    with { :ok, params }  <- Map.fetch(conn, :params),
         { :ok, topics }  <- Map.fetch(params, "topics"),
         { :ok, content } <- Map.fetch(params, "content"),
         fact             <- @fact_db.new(content, topics),
         :ok              <- @fact_db.persist(fact)
    do
      conn
      |> put_resp_header("content-type", "text/plain")
      |> send_resp(201, fact.id |> to_string())
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  defp todo_real_error_handling(conn, error) do
    IO.inspect(error)
    send_resp(conn, 503, "TODO: real error handling!")
  end
end
