defmodule Rest.Router.Document do
  use Plug.Router
  alias Database.Id

  @document_db Application.get_env(
    :rest, :document_database, Database.Document)

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  get "/:id" do
    with { :ok, params } <- Map.fetch(conn, :params),
         { :ok, id     } <- Map.fetch(params, "id"),
         id              <- Id.from(id) ,
         # TODO: Needs to be { :ok, value } tuple or else we can bleed an error.
         document_or_nil <- @document_db.fetch(id),
         { :ok, body }   <- encode(document_or_nil)
    do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)
    else
      error -> todo_real_error_handling(conn, error)
    end
  end

  defp encode(nil) do
    raise "not yet implemented!"
  end

  defp encode(%Database.Document{} = document) do
    Jason.encode(document)
  end

  defp todo_real_error_handling(conn, error) do
    IO.inspect(error)
    send_resp(conn, 503, "TODO: real error handling!")
  end

end
