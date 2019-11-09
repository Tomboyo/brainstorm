defmodule Rest.Router do
  use Plug.Router

  alias Database.{ Id, Topic }

  @topic_db Application.get_env(
    :rest, :topic_database, Database.Topic)
  @fact_db Application.get_env(
    :rest, :fact_database, Database.Fact)

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

  get "/topic/:id" do
    with { :ok, params } <- Map.fetch(conn, :params),
         { :ok, id     } <- Map.fetch(params, "id"),
         id              <- Id.new(id),
         # TODO: Needs to be { :ok, value } tuple or else we can bleed an error.
         topic_or_nil    <- @topic_db.fetch(id),
         { :ok, body }   <- encode(topic_or_nil)
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

  defp encode(%Topic{} = topic) do
    Jason.encode(topic)
  end

  post "/fact" do
    with { :ok, params }  <- Map.fetch(conn, :params),
         { :ok, topics }  <- Map.fetch(params, "topics"),
         { :ok, content } <- Map.fetch(params, "content"),
         { :ok, fact }    <- @fact_db.new(topics, content),
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
