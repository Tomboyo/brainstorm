defmodule Service.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  plug :dispatch

  post "/topic" do
    with { :ok, database } <- fetch(Map, conn.assigns, :database),
         { :ok, params   } <- fetch(Map, conn, :body_params),
         { :ok, label    } <- fetch(Map, params, "label")
    do
      id = database.create_topic(label)
      send_resp(conn, 201, id)
    else
      # TODO: UNTESTED
      error ->
        IO.inspect(error)
        send_resp(conn, 503, "TODO: real error handling")
    end
  end

  defp fetch(module, fetchable, key) do
    case module.fetch(fetchable, key) do
      { :ok, value } -> { :ok, value }
      :error -> { :error, "Key `#{key}` not found in `#{inspect(fetchable)}`" }
    end
  end
end
