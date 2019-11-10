defmodule Rest.RouterTest.FetchTopicTest do
  use ExUnit.Case
  use Plug.Test

  import Mox

  alias Rest.Router
  alias Database.{ Id }

  @opts Router.init([])

  setup :verify_on_exit!

  describe "given a request to GET /topic/:id for an existing topic" do
    setup do
      id = Id.new("mock id string")

      fragment = %{
        label: "topic label",
        facts: []
      }
      Database.TopicMock
      |> expect(:fetch, fn ^id -> fragment end)

      conn =
        conn(:get, "/topic/#{id}", nil)
        |> Router.call(@opts)

      [ conn: conn, fragment: fragment ]
    end

    test "it returns the topic as json", %{
      conn: conn,
      fragment: fragment
    } do
      { :ok, expected } = Jason.decode("""
        {
          "label": "#{fragment.label}",
          "facts": []
        }
      """)

      assert expected == Jason.decode!(conn.resp_body)
    end

    test "the response has a 200 status code", %{
      conn: conn
    } do
      assert 200 == conn.status
    end

    test "the response sets the content-header to application/json", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
