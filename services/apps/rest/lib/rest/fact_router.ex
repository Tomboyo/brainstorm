defmodule Rest.FactRouter do
  use Plug.Router

  @fact_db Application.get_env(
    :rest, :fact_database, Database.Fact)
  @presenter Application.get_env(
    :rest, :presenter, Rest.Presenter.Json)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/" do
    with { :ok, params }  <- Map.fetch(conn, :params),
         { :ok, topics }  <- Map.fetch(params, "topics"),
         { :ok, content } <- Map.fetch(params, "content"),
         fact             <- @fact_db.new(content, topics),
         :ok              <- @fact_db.persist(fact),
         { :ok, body }    <- @presenter.present_id(fact)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(201, body)
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  defp todo_real_error_handling(conn, error) do
    IO.inspect(error)
    send_resp(conn, 503, "TODO: real error handling!")
  end

end
