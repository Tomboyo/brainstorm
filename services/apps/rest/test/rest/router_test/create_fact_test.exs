defmodule Rest.RouterTest.CreateFactTest do
  use ExUnit.Case
  use Plug.Test
  use Database.Case

  import Mox

  alias Rest.Router
  alias Database.{ Fact, Id }

  @opts Router.init([])

  describe "given a well-formed JSON request to POST /fact" do
    setup do
      topics = [ "id-1", "id-2" ]
      content = "content of the fact"
      json_request = """
      {
        "topics":  [ "id-1", "id-2" ],
        "content": "#{content}"
      }
      """

      mock_fact = %Fact{
        id: Id.new("fact-id"),
        topics: topics,
        content: content
      }
      Database.FactMock
      |> expect(:new, fn ^topics, ^content -> mock_fact end)
      |> expect(:persist, fn ^mock_fact -> :ok end)

      conn =
        conn(:post, "/fact", json_request)
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      [ conn: conn, mock_fact: mock_fact ]
    end

    test "it creates and persists a new fact" do
      Mox.verify!()
    end

    test "it responds with the new fact id", %{
      conn: conn,
      mock_fact: mock_fact
    } do
      assert mock_fact.id |> to_string() == conn.resp_body
    end

    test "it responds with a 201 status code", %{
      conn: conn
    } do
      assert 201 == conn.status
    end

    test "it responds with a text/plain content type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "text/plain" })
    end
  end
end
