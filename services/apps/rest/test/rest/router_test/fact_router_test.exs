defmodule Rest.FactRouterTest do
  use ExUnit.Case
  use Plug.Test
  use Database.Case
  import Mox
  alias Rest.Router

  @opts Router.init([])

  describe "When a request body is well-formed, POST /fact" do
    setup do
      topics = [ "id-1", "id-2" ]
      content = "fact content"

      Database.FactMock
      |> expect(:new, fn ^content, ^topics -> :mock_fact end)
      |> expect(:persist, fn :mock_fact -> :ok end)

      Rest.PresenterMock
      |> expect(:present_id, fn :mock_fact -> { :ok, "mock id" } end)

      { :ok, json_request } = Jason.encode(%{
        "topics" => topics,
        "content" => content
      })
      conn =
        conn(:post, "/fact", json_request)
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "creates and persists a new fact" do
      Mox.verify!()
    end

    test "returns the new fact id in the response body", %{
      conn: conn
    } do
      assert "mock id" == conn.resp_body
    end

    test "responds with a 201 status code", %{
      conn: conn
    } do
      assert 201 == conn.status
    end

    test "responds with a application/json content type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
