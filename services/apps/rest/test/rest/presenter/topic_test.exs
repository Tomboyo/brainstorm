defmodule Rest.Presenter.TopicTest do
  use ExUnit.Case
  alias Rest.Presenter.Topic

  describe "POST /" do
    test "json-encodes the given topic's id" do
      topic = Database.Topic.new("label")
      assert { :ok, Jason.encode!(topic.id) } ==
        Topic.present({ :post, "/"}, topic)
    end
  end

  describe "GET /" do
    test "json-encodes the list of topics" do
      topics = [ Database.Topic.new("label") ]
      assert { :ok, Jason.encode!(topics) } ==
        Topic.present({ :get, "/" }, topics)
    end
  end

  describe "GET /:id" do
    test "json-encodes the given topic" do
      topic = Database.Topic.new("label")
      assert { :ok, Jason.encode!(topic) } ==
        Topic.present({ :get, "/:id" }, topic)
    end
  end
end
