defmodule Rest.RouterTest.CreateTopic do
  use ExUnit.Case
  use Plug.Test

  alias Rest.Router
  alias Database.{ Id, Topic }

  @opts Router.init([])

  @mock_id_string "mock id"
  @mock_topic     %Topic{ id: Id.new(@mock_id_string), label: "mock label" }
  def mock_topic(), do: @mock_topic

  defmodule Mock.Database.Topic do
    def new(label) do
      send(self(), { __MODULE__, :new, label })
      Rest.RouterTest.mock_topic()
    end

    def persist(topic) do
      send(self(), { __MODULE__, :persist, topic })
      :ok
    end
  end

  describe "given a JSON request containing a topic label to POST /topic" do

    setup do
      label = "my label"

      conn =
        conn(:post, "/topic", "{ \"label\": \"#{label}\" }")
        |> put_req_header("content-type", "application/json")
        |> Plug.Conn.assign(:topic_database, Mock.Database.Topic)
        |> Router.call(@opts)

      [ conn: conn, label: label ]
    end

    test "it creates a new topic", %{
      label: label
    } do
      assert_received { Mock.Database.Topic, :new, ^label }
    end

    test "it persists the new topic" do
      assert_received { Mock.Database.Topic, :persist, @mock_topic }
    end

    test "it returns the topic id as a string", %{
      conn: conn
    } do
      assert @mock_id_string == conn.resp_body
    end

    test "it responds with a 201", %{
      conn: conn
    } do
      assert 201 == conn.status
    end
  end
end
