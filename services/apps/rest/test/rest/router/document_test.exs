defmodule Rest.Router.DocumentTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router
  alias Database.{ Document, Fact, Id, Topic }

  @opts Router.init([])

  describe "GET /document/:id (when :id is a persistent topic id)" do
    setup do
      id = Id.new()

      Database.DocumentMock
      |> expect(:fetch, fn ^id -> :document end)

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
end
