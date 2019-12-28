defmodule Rest.Router.FactTest do
  use ExUnit.Case
  use Plug.Test
  use Database.Case
  import Mox
  alias Rest.Router

  @opts Router.init([])

  describe "POST /fact" do
    setup do
      topics = [ "id", "search term" ]
      content = "fact content"

      # resolves all search terms to topic ids
      Database.TopicMock
      |> expect(:resolve_ids, fn ^topics ->
          %{ id: :mock_topic_ids, match: %{} }
        end)

      # then uses those topic ids to create a new fact,
      Database.FactMock
      |> expect(:new, fn ^content, :mock_topic_ids -> :mock_fact end)
      |> expect(:persist, fn :mock_fact -> :ok end)

      # and finally presents the fact id to the client.
      Rest.Presenter.FactMock
      |> expect(:present, fn { :post, "/" }, :mock_fact ->
          { :ok, "presented id" }
        end)

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

    test "returns the presented new fact id in the response body", %{
      conn: conn
    } do
      assert "presented id" == conn.resp_body
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

  describe "POST /fact (given search terms that match zero or many topics)" do
    setup do
      topics = [ "search term" ]
      content = "fact content"

      # maps search terms to matched topics
      Database.TopicMock
      |> expect(:resolve_ids, fn ^topics ->
        %{ id: MapSet.new(), match: :mock_matches }
      end)

      # and presents the matches to the client
      Rest.Presenter.FactMock
      |> expect(:present, fn { :post, "/" }, :mock_matches ->
          { :ok, "presented matches" }
        end)

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

    test "identifies and presents search term matches" do
      Mox.verify!()
    end

    test "returns the presented matches", %{
      conn: conn
    } do
      assert "presented matches" == conn.resp_body
    end

    test "responds with a 200 status code", %{
      conn: conn
    } do
      assert 200 == conn.status
    end

    test "responds with a application/json content type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
