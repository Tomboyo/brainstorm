defmodule Rest.Router do
  require Logger
  use Plug.Router
  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  forward "/topic",    to: Rest.Router.Topic
  forward "/fact",     to: Rest.Router.Fact
  forward "/document", to: Rest.Router.Document

  def handle_errors(conn, error) do
    Logger.log(:error, IO.inspect(error))
    send_resp(conn, 500, "Internal server error.")
  end

end
