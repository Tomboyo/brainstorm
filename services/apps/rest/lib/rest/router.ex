defmodule Rest.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/topic",    to: Rest.Router.Topic
  forward "/fact",     to: Rest.Router.Fact
  forward "/document", to: Rest.Router.Document

end
