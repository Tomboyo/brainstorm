defmodule Rest.Router.Document do
  use Plug.Router
  require Logger
  alias Database.Id
  alias Rest.Util.Maybe

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
    Maybe.of(fn -> conn end)
      |> Maybe.map(&Map.fetch(&1, :params), :missing_params)
      |> Maybe.map(&Map.fetch(&1, "id"),    :missing_id)
      |> Maybe.replace(&@topic_db.resolve_id(&1))
      |> Maybe.replace(&Id.from(&1))
      |> Maybe.map(&@document_db.fetch(&1), :document_error)
      |> Maybe.map(&@presenter.present({ :get, "/:id" }, &1), :presenter_error)
      |> Maybe.produce()
    |> case do
      { :ok, body } ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, body)
      { :error, { :document_error, id, :enoent }} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(404, Jason.encode!(%{
            "error" => "No document with id `#{id}` was found."
          }))
      { :error, any } -> any # unhandled match -- bublle up to the router
    end
  end

end
