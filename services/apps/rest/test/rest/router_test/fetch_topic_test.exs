defmodule Rest.RouterTest.FetchTopicTest do
  use ExUnit.Case
  use Plug.Test

  alias Rest.Router
  alias Database.{ Id, Topic }

  @opts Router.init([])

  @mock_id    Id.new("mock id string")
  @mock_label "mock label"
  @mock_topic %Topic{ id: @mock_id, label: @mock_label }
  def mock_topic(), do: @mock_topic

  defmodule Mock.Database.Topic do
    def fetch(%Id{} = id) do
      send(self(), { __MODULE__, :fetch, id })
      Rest.RouterTest.FetchTopicTest.mock_topic()
    end
  end

  describe "given a request to GET /topic/:id for an existing topic" do

    setup do
      conn =
        conn(:get, "/topic/#{@mock_id}", nil)
        |> Plug.Conn.assign(:topic_database, Mock.Database.Topic)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "it fetches the topic from the data layer" do
      assert_received { Mock.Database.Topic, :fetch, @mock_id }
    end

    # TODO: facts
    test "it returns the topic as json", %{
      conn: conn
    } do
      { :ok, expected } = Jason.decode("""
        {
          "label": "#{@mock_label}"
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
