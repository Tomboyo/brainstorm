defmodule Rest.Router.Topic do
  use Plug.Router
  alias Database.Id

  @topic_db Application.get_env(:rest, :topic_database, Database.Topic)
  @presenter Application.get_env(:rest, :topic_presenter, Rest.Presenter.Topic)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/" do
    with { :ok, params } <- Map.fetch(conn, :body_params),
         { :ok, label  } <- Map.fetch(params, "label"),
         topic           <- @topic_db.new(label),
         :ok             <- @topic_db.persist(topic),
         { :ok, body }   <- @presenter.present({ :post, "/" }, topic)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(201, body)
    end
  end

  get "/" do
    with { :ok, params } <- param(conn, :params),
         { :ok, search } <- param(params, "search"),
         topics          <- @topic_db.find(search),
         { :ok, body }   <- @presenter.present({ :get, "/" }, topics)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)
    end
  end

  delete "/:id" do
    with { :ok, params } <- param(conn, :params),
         { :ok, id     } <- param(params, "id"),
         id              <- Id.from(id)
    do
      # Should go through a presenter to get the body, at which point we may
      # introduce a TopicException to differentiate the end-states.
      case @topic_db.delete(id) do
        :ok               -> send_resp(conn, 204, "")
        :enoent           -> send_resp(conn, 404, "")
      end
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

end
