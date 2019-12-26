defmodule Rest.Router.DocumentTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router
  alias Database.Id

  @opts Router.init([])

  describe "GET /document/:id (when :id is a persistent topic id)" do
    setup do
      id = Id.new()
      id_str = to_string(id)

      # verifies the body parameter is an id,
      Database.TopicMock
      |> expect(:resolve_id, fn ^id_str -> id_str end)

      # then generates a document from the id,
      Database.DocumentMock
      |> expect(:fetch, fn ^id -> { :ok, :document } end)

      # and presents the document.
      Rest.Presenter.DocumentMock
      |> expect(:present, fn { :get, "/:id" }, :document ->
          { :ok, "presented document" }
        end)

      conn =
        conn(:get, "/document/#{to_string(id)}", nil)
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

  describe "GET /document/:id (when :id is not found)" do
    setup do
      id = Id.new()
      id_str = to_string(id)

      # verifies the body parameter is an id,
      Database.TopicMock
      |> expect(:resolve_id, fn ^id_str -> id_str end)

      # then fails to find a document,
      Database.DocumentMock
      |> expect(:fetch, fn ^id -> :enoent end)

      # and presents the error to the client.
      Rest.Presenter.DocumentMock
      |> expect(
        :present,
        fn { :get, "/:id" }, { :document_error, ^id, :enoent } ->
          { :ok, "presented error" }
        end)

      conn =
        conn(:get, "/document/#{to_string(id)}", nil)
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
