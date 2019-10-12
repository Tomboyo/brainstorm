defmodule Rest.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias Rest.Router
  alias Database.Id

  @opts Router.init([])

  defmodule MockDatabase do
    def create_topic(label) do
      send(self(), { MockDatabase, label })
      Id.new("mock id")
    end
  end

  describe "successful POST /topic" do

    setup do
      label = "my label"

      conn =
        conn(:post, "/topic", "{ \"label\": \"#{label}\" }")
        |> put_req_header("content-type", "application/json")
        |> Plug.Conn.assign(:database, MockDatabase)
        |> Router.call(@opts)

      [ conn: conn, label: label ]
    end

    test "it invokes database.create_topic with the given label", %{
      label: label
    } do
      assert_received { MockDatabase, ^label }
    end

    test "it responds with the stringified data layer id", %{
      conn: conn
    } do
      assert "mock id" == conn.resp_body
    end

    test "it responds with a 201", %{ conn: conn } do
      assert 201 == conn.status
    end
  end
end
