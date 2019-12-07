defmodule Rest.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/topic",    to: Rest.TopicRouter
  forward "/fact",     to: Rest.FactRouter
  forward "/document", to: Rest.DocumentRouter

end
