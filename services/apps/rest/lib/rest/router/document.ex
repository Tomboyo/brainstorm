defmodule Rest.Router.Document do
  use Plug.Router
  require Logger
  alias Rest.Presenter
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
    present! = &Presenter.present!(@presenter, { :get, "/:id" }, &1)
    conn = put_resp_header(conn, "content-type", "application/json")

    Maybe.of(fn -> conn end)
      |> Maybe.map(&Map.fetch(&1, :params),        :missing_params)
      |> Maybe.map(&Map.fetch(&1, "id"),           :missing_id)
      |> Maybe.map(:id, &@topic_db.resolve_id(&1), :id_error)
      |> Maybe.map(&@document_db.fetch(&1),        :document_error)
      |> Maybe.produce()
      |> case do
        { :ok, document } -> send_resp(conn, 200, present!.(document))
        { :error, e = { :document_error, _id, :enoent }} ->
          send_resp(conn, 404, present!.(e))
        { :error, { :id_error, _term, { :match, matches }}} ->
          body = present!.({ :matched_search_terms, matches })
          send_resp(conn, 200, body)
    end
  end

end
