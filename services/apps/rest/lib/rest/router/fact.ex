defmodule Rest.Router.Fact do
  import Database.Sets, only: [ empty_set: 0 ]
  use Plug.Router

  @topic_db  Application.get_env(:rest, :topic_database, Database.Topic)
  @fact_db   Application.get_env(:rest, :fact_database, Database.Fact)
  @presenter Application.get_env(:rest, :fact_presenter, Rest.Presenter.Fact)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/" do
    with { :ok, params }  <- Map.fetch(conn, :params),
         { :ok, topics }  <- Map.fetch(params, "topics"),
         { :ok, content } <- Map.fetch(params, "content"),
         %{ id: ids, match: %{}} <- @topic_db.resolve_ids(topics),
         fact             <- @fact_db.new(content, ids),
         :ok              <- @fact_db.persist(fact),
         { :ok, body }    <- @presenter.present({ :post, "/" }, fact)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(201, body)
    else
      %{ id: empty_set(), match: map } ->
        { :ok, body } = @presenter.present({ :post, "/" }, map)

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, body)
    end
  end

end
