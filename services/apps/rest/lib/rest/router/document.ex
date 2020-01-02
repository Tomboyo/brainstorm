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

    Maybe.of(conn)
      |> Maybe.map(&Map.get(&1, :params), :missing_params)
      |> Maybe.map(&Map.get(&1, "id"),    :missing_id)
      |> Maybe.flat_map(&resolve_id/1,    :id_error)
      |> Maybe.flat_map(&fetch/1,         :document_error)
      |> case do
        { :ok, document } -> send_resp(conn, 200, present!.(document))
        { :error, e = { :document_error, _id, :enoent }} ->
          send_resp(conn, 404, present!.(e))
        { :error, { :id_error, _term, { :match, matches }}} ->
          body = present!.({ :matched_search_terms, matches })
          send_resp(conn, 200, body)
    end
  end

  defp resolve_id(id) do
    case @topic_db.resolve_id(id) do
      { :id, id } -> { :ok, id }
      e = _       -> { :error, e }
    end
  end

  defp fetch(id) do
    case @document_db.fetch(id) do
      :enoent -> { :error, :enoent }
      ok = { :ok, _ } -> ok
    end
  end

end
