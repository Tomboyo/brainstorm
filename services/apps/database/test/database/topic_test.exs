defmodule Database.TopicTest do
  use ExUnit.Case
  use Database.Case
  doctest Database.Topic

  alias Database.Topic

  defp create_persistent_topic(_content) do
    topic = Topic.new("my label")
    :ok = Topic.persist(topic)
    [ topic: topic ]
  end

  describe "Topic.find/1" do
    setup :create_persistent_topic

    test "it returns an empty set when there are no matched topics" do
      assert MapSet.new() == Topic.find("notalabel")
    end

    test "it returns a map set of matched results", %{ topic: topic } do
      assert MapSet.new([ topic ]) == Topic.find("my")
      assert MapSet.new([ topic ]) == Topic.find("label")
    end
  end

  describe "Topic.persist/1" do
    setup :create_persistent_topic

    test "Topic.persist fails to persist a topic twice", %{
      topic: persistent
    } do
      assert { :error, _any } = Topic.persist(persistent)
    end

    test "Topic.persist returns :ok when it persists a topic" do
      assert :ok == Topic.persist(Topic.new("new topic"))
    end
  end

end
