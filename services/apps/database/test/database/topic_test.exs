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

    test "returns an empty set when there are no matched topics" do
      assert { :ok, MapSet.new() } == Topic.find("matches-nothing")
    end

    test "returns a map set of matched results", %{ topic: topic } do
      assert { :ok, MapSet.new([ topic ]) } == Topic.find("label")
    end

    test "escapes Apache Lucene query special characters" do
      # This will break Apache Lucene's grammar if not quoted correctly
      assert { :ok, MapSet.new([]) } == Topic.find(")")
    end
  end

  describe "Topic.persist/1" do
    setup :create_persistent_topic

    test "fails to persist a topic twice", %{
      topic: persistent
    } do
      assert { :error, _any } = Topic.persist(persistent)
    end

    test "returns :ok when it persists a topic" do
      assert :ok == Topic.persist(Topic.new("new topic"))
    end
  end

  describe "Given a persistent topic" do
    setup :create_persistent_topic

    test "Topic.delete/1 deletes the topic", %{ topic: topic } do
      Topic.delete(topic.id)

      assert nil == Database.Document.fetch(topic.id)
    end

    test "Topic.delete/1 returns :ok", %{ topic: topic } do
      assert :ok == Topic.delete(topic.id)
    end
  end

  describe "Given a nonexistant topic" do
    test "Topic.delete/1 return :enoent" do
      assert :enoent == Topic.delete(Database.Id.new())
    end
  end

end
