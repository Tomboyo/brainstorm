defmodule Rest.Router.TopicTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router
  alias Database.Id

  @opts Router.init([])

  describe "DELETE /:id (given an existing topic id)" do
    setup do
      expected_id = Id.from("topic-id")
      Database.TopicMock
      |> expect(:delete, fn ^expected_id -> :ok end)

      conn =
        conn(:delete, "/topic/topic-id", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "deletes the topic with the given id" do
      Mox.verify!
    end

    test "returns 204", %{ conn: conn } do
      assert 204 == conn.status
    end
  end

  describe "DELETE /:id (given a nonexistant topic id)" do
    setup do
      expected_id = Id.from("topic-id")
      Database.TopicMock
      |> expect(:delete, fn ^expected_id -> :enoent end)

      conn =
        conn(:delete, "/topic/topic-id", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "finds no topics to delete" do
      Mox.verify!
    end

    test "returns 404", %{ conn: conn } do
      assert 404 == conn.status
    end
  end

  describe "POST / (given a JSON request containing a topic label)" do
    setup do
      request_body = %{ "label" => "topic label" } |> Jason.encode!

      # creates and persists a new topic with the given label
      Database.TopicMock
      |> expect(:new, fn "topic label" -> :mock_topic end)
      |> expect(:persist, fn :mock_topic -> :ok end)

      # then presents that topic to the client
      Rest.Presenter.TopicMock
      |> expect(:present, fn { :post, "/" }, :mock_topic ->
          { :ok, "presented topic" }
        end)

      conn =
        conn(:post, "/topic", request_body)
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "creates, persists, and presents a new topic" do
      Mox.verify!
    end

    test "returns the presented new topic", %{
      conn: conn
    } do
      assert "presented topic" == conn.resp_body
    end

    test "responds with a 201", %{
      conn: conn
    } do
      assert 201 == conn.status
    end

    test "responds with an application/json content type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end

  describe "GET /" do
    setup do
      request_url = "topic?search=search%20term"

      # finds topics which match the given search term by label
      Database.TopicMock
      |> expect(:find, fn "search term" -> { :ok, :mock_topics } end)

      # then presents those topics to the client
      Rest.Presenter.TopicMock
      |> expect(:present, fn { :get, "/" }, :mock_topics ->
          { :ok, "presented topics" }
        end)

      conn =
        conn(:get, request_url, nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "finds and presents topics that match the given search term" do
      Mox.verify!
    end

    test "returns a 200", %{ conn: conn } do
      assert 200 == conn.status
    end

    test "returns the presented topics", %{
      conn: conn,
    } do
      assert "presented topics" == conn.resp_body
    end

    test "responds with an application/json content type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
