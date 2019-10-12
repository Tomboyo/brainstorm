defmodule Rest.Router do
  use Plug.Router

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
end
