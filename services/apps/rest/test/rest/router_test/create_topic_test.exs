defmodule Rest.RouterTest.CreateTopicTest do
  use ExUnit.Case
  use Plug.Test

  import Mox

  alias Rest.Router
  alias Database.{ Id, Topic }

  @opts Router.init([])

  setup :verify_on_exit!

  describe "given a JSON request containing a topic label to POST /topic" do
    setup do
      label = "my label"

      topic = %Topic{ id: Id.new("mock topic id"), label: label }
      Database.TopicMock
      |> expect(:new, fn ^label -> topic end)
      |> expect(:persist, fn ^topic -> :ok end)

      conn =
        conn(:post, "/topic", "{ \"label\": \"#{label}\" }")
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      [ conn: conn, topic: topic ]
    end

    test "it returns the topic id as a string", %{
      conn: conn,
      topic: topic
    } do
      assert topic.id |> to_string() == conn.resp_body
    end

    test "it responds with a 201", %{
      conn: conn
    } do
      assert 201 == conn.status
    end
  end
end
