defmodule Rest.Router.Document do
  use Plug.Router
  require Logger
  alias Database.Id

  @document_db Application.get_env(
    :rest, :document_database, Database.Document)
  @topic_db Application.get_env(
    :rest, :topic_database, Database.Topic)
  @presenter Application.get_env(
    :rest, :document_presenter, Rest.Presenter.Document)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  get "/:id" do
    with { :ok, params }   <- Map.fetch(conn, :params),
         { :ok, id     }   <- Map.fetch(params, "id"),
         id                <- @topic_db.resolve_id(id),
         id                <- Id.from(id),
         { :ok, document } <- @document_db.fetch(id),
         { :ok, body }     <- @presenter.present({ :get, "/:id" }, document)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)
    end
  end

end
