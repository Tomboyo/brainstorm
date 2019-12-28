defmodule Rest.Router.DocumentTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router

  @opts Router.init([])

  describe "GET /document/:term (when :term resolves to an id)" do
    setup do
      # resolves the term to an id,
      Database.TopicMock
      |> expect(:resolve_id, fn "mock term" -> { :id, :mock_id } end)

      # then generates a document from the id,
      Database.DocumentMock
      |> expect(:fetch, fn :mock_id -> { :ok, :document } end)

      # then presents the document.
      Rest.Presenter.DocumentMock
      |> expect(:present, fn { :get, "/:id" }, :document ->
          { :ok, "presented document" }
        end)

      conn =
        conn(:get, "/document/mock%20term", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "generates and presents a document from the indicated topic" do
      Mox.verify!()
    end

    test "returns the presented document", %{
      conn: conn
    } do
      assert "presented document" == conn.resp_body
    end

    test "responds with a 200 status code", %{
      conn: conn
    } do
      assert 200 == conn.status
    end

    test "responds with an application/json content-type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end

  describe "GET /document/:term (when :term resolves to a missing id)" do
    setup do
      # resolves the term to an id,
      Database.TopicMock
      |> expect(:resolve_id, fn "mock term" -> { :id, :mock_id } end)

      # then fails to find a document,
      Database.DocumentMock
      |> expect(:fetch, fn :mock_id -> :enoent end)

      # and presents the error to the client.
      Rest.Presenter.DocumentMock
      |> expect(
        :present,
        fn { :get, "/:id" }, { :document_error, :mock_id, :enoent } ->
          { :ok, "presented error" }
        end)

      conn =
        conn(:get, "/document/mock%20term", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "fails to find a document and presents an error to the client" do
      Mox.verify!()
    end

    test "returns the presented error", %{
      conn: conn
    } do
      assert "presented error" == conn.resp_body
    end

    test "responds with a 404 status code", %{
      conn: conn
    } do
      assert 404 == conn.status
    end

    test "responds with an application/json content-type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
