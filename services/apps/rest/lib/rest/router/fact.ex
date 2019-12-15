defmodule Rest.Router.Fact do
  use Plug.Router

  @topic_db  Application.get_env(:rest, :topic_database, Database.Topic)
  @fact_db   Application.get_env(:rest, :fact_database, Database.Fact)
  @presenter Application.get_env(:rest, :presenter, Rest.Presenter.Json)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/" do
    with { :ok, params }  <- Map.fetch(conn, :params),
         { :ok, topics }  <- Map.fetch(params, "topics"),
         { :ok, content } <- Map.fetch(params, "content"),
         { :total, ids }  <- @topic_db.resolve_ids(topics),
         fact             <- @fact_db.new(content, ids),
         :ok              <- @fact_db.persist(fact),
         { :ok, body }    <- @presenter.present_id(fact)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(201, body)
    else
      { :partial, map } ->
        { :ok, body } = @presenter.present(map)

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, body)
      error -> todo_real_error_handling(conn, error)
    end
  end

  defp todo_real_error_handling(conn, error) do
    IO.inspect(error)
    send_resp(conn, 503, "TODO: real error handling!")
  end

end
