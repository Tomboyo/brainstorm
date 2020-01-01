defmodule Rest.Router.Fact do
  use Plug.Router
  alias Rest.Util.Maybe

  @topic_db  Application.get_env(:rest, :topic_database, Database.Topic)
  @fact_db   Application.get_env(:rest, :fact_database, Database.Fact)
  @presenter Application.get_env(:rest, :fact_presenter, Rest.Presenter.Fact)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/" do
    present! = &Rest.Presenter.present!(@presenter, { :post, "/" }, &1)
    conn = put_resp_header(conn, "content-type", "application/json")

    Maybe.of(fn -> conn end)
    |> Maybe.map(&Map.fetch(&1, :params), :missing_params)
    |> Maybe.map(&get_params/1,           :missing_param)
    |> Maybe.map(&resolve_ids/1,          :unresolved_ids)
    |> Maybe.replace(&persist_new_fact/1)
    |> Maybe.produce()
    |> case do
      { :ok, fact } -> conn
        |> send_resp(201, present!.(fact))
      { :error, { :unresolved_ids, _params, e = { :match, _match }}} -> conn
        |> send_resp(200, present!.(e))

    end
  end

  defp get_params(params) do
    topics = Map.get(params, "topics", :error)
    content = Map.get(params, "content", :error)
    value = %{ topics: topics, content: content }
    if topics == :error or content == :error,
      do:   { :error, value },
      else: { :ok,    value }
  end

  defp resolve_ids(params) do
    case @topic_db.resolve_ids(params.topics) do
      %{ id: ids, match: %{} } -> { :ok, %{ params | topics: ids }}
      %{ id: _, match: match } -> { :match, match }
    end
  end

  defp persist_new_fact(%{ topics: topics, content: content }) do
    fact = @fact_db.new(content, topics)
    @fact_db.persist(fact)
    fact
  end

end
