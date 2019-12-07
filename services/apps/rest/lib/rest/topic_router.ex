defmodule Rest.TopicRouter do
  use Plug.Router
  alias Database.Id

  @topic_db Application.get_env(
    :rest, :topic_database, Database.Topic)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/" do
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

  get "/" do
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

  delete "/:id" do
    with { :ok, params } <- param(conn, :params),
         { :ok, id     } <- param(params, "id"),
         id              <- Id.from(id)
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

  # TODO: incorporate into real error handling.
  # Useful for figuring out what parameters were missing.
  def param(map, key) do
    case Map.fetch(map, key) do
      { :ok, value } -> { :ok, value }
      :error         -> { :error, "#{key} not found" }
    end
  end

  def todo_real_error_handling(conn, error) do
    IO.inspect(error)
    send_resp(conn, 503, "TODO: real error handling!")
  end

end
