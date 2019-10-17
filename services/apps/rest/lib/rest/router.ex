defmodule Rest.Router do
  use Plug.Router

  alias Database.{ Id, Topic }

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/topic" do
    topic_db = Map.get(conn.assigns, :topic_database, Database.Topic)

    with { :ok, params } <- Map.fetch(conn, :body_params),
         { :ok, label  } <- Map.fetch(params, "label"),
         topic           <- topic_db.new(label),
         :ok             <- topic_db.persist(topic)
    do
      send_resp(conn, 201, topic.id |> to_string())
    else
      error ->
        IO.inspect(error)
        send_resp(conn, 503, "TODO: real error handling")
    end
  end

  get "/topic/:id" do
    topic_db = Map.get(conn.assigns, :topic_database, Database.Topic)

    with { :ok, params } <- Map.fetch(conn, :params),
         { :ok, id     } <- Map.fetch(params, "id"),
         id              <- Id.new(id),
         # TODO: Needs to be { :ok, value } tuple or else we can bleed an error.
         topic_or_nil    <- topic_db.fetch(id),
         { :ok, body }   <- encode(topic_or_nil)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)
    else
      error ->
        IO.inspect(error)
        send_resp(conn, 503, "TODO: real error handling!")
    end
  end

  defp encode(nil) do
    raise "not yet implemented!"
  end

  defp encode(%Topic{} = topic) do
    Jason.encode(topic)
  end
end
