defmodule Rest.FactRouterTest do
  use ExUnit.Case
  use Plug.Test
  use Database.Case
  import Mox
  alias Rest.Router
  alias Database.{ Fact, Id }

  @opts Router.init([])

  describe "When a request body is well-formed, POST /fact" do
    setup do
      topics = [ "id-1", "id-2" ]
      content = "fact content"
      { :ok, json_request } = Jason.encode(%{
        "topics" => topics,
        "content" => content
      })

      mock_fact = %Fact{
        id: Id.from("fact-id") ,
        content: topics,
        topics: content
      }

      Database.FactMock
      |> expect(:new, fn ^content, ^topics -> mock_fact end)
      |> expect(:persist, fn ^mock_fact -> :ok end)

      conn =
        conn(:post, "/fact", json_request)
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      [ conn: conn, mock_fact: mock_fact ]
    end

    test "creates and persists a new fact" do
      Mox.verify!()
    end

    test "returns the new fact id in the response body", %{
      conn: conn,
      mock_fact: mock_fact
    } do
      assert to_string(mock_fact.id) == conn.resp_body
    end

    test "responds with a 201 status code", %{
      conn: conn
    } do
      assert 201 == conn.status
    end

    test "responds with a text/plain content type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "text/plain" })
    end
  end
end
