defmodule Database.TopicTest do
  use ExUnit.Case
  use Database.Case
  alias Database.{ Id, Topic }
  doctest Database.Topic

  defp create_persistent_topic(_content) do
    topic = Topic.new("my label")
    :ok = Topic.persist(topic)
    [ topic: topic ]
  end

  describe "Topic.find/1" do
    setup :create_persistent_topic

    test "returns an empty set when there are no matched topics" do
      assert MapSet.new() == Topic.find("matches-nothing")
    end

    test "returns a map set of matched results", %{ topic: topic } do
      assert MapSet.new([ topic ]) == Topic.find("label")
    end

    test "escapes Apache Lucene query special characters" do
      # This will break Apache Lucene's grammar if not quoted correctly
      assert MapSet.new([]) == Topic.find(")")
    end
  end

  describe "Topic.persist/1" do
    setup :create_persistent_topic

    test "fails to persist a topic twice", %{
      topic: persistent
    } do
      assert_raise(Bolt.Sips.Exception, fn () -> Topic.persist(persistent) end)
    end

    test "returns :ok when it persists a topic" do
      assert :ok == Topic.persist(Topic.new("new topic"))
    end
  end

  describe "Given a persistent topic" do
    setup :create_persistent_topic

    test "Topic.delete/1 deletes the topic", %{ topic: topic } do
      Topic.delete(topic.id)

      # TODO: this should be implemented as Topic.fetch/1
      assert :enoent == Database.Document.fetch(topic.id)
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

  describe "resolve_id/1" do
    setup do
      topic_a = Topic.new("topic a")
      topic_b = Topic.new("topic b")
      Topic.persist(topic_a)
      Topic.persist(topic_b)
      [ topic_a: topic_a, topic_b: topic_b ]
    end

    test "resolves a well-formed id string to the Id type" do
      id = Id.new()
      assert { :id, id } == Topic.resolve_id(to_string(id))
    end

    test "resolves a search term to the id of a uniquely-matched topic", %{
      topic_a: topic_a
    } do
      assert { :id, topic_a.id } == Topic.resolve_id("topic a")
    end

    test "resolves an unmatched search term to the empty set" do
      assert { :match, %{ "unmatched term" => MapSet.new() }} ==
        Topic.resolve_id("unmatched term")
    end

    test "resolves the search term to a set of matching topics", %{
      topic_a: topic_a,
      topic_b: topic_b
    } do
      assert { :match, %{ "topic" => MapSet.new([ topic_a, topic_b ]) }}
        == Topic.resolve_id("topic")
    end
  end

  describe "resolve_ids/1" do
    setup do
      topic_a = Topic.new("topic label a")
      topic_b = Topic.new("topic label b")
      Topic.persist(topic_a)
      Topic.persist(topic_b)
      [ topic_a: topic_a, topic_b: topic_b ]
    end

    test "coalesces ids into a set", %{
      topic_a: topic_a,
      topic_b: topic_b
    } do
      assert %{
        id: MapSet.new([ topic_a.id, topic_b.id ]),
        match: %{}
      } == Topic.resolve_ids([ topic_a.id, "topic b" ])
    end

    test "coalesces matches into a map", %{
      topic_a: topic_a,
      topic_b: topic_b
    } do
      assert %{
        match: %{
          "topic" => MapSet.new([ topic_a, topic_b ]),
          "label" => MapSet.new([ topic_a, topic_b ]),
          "none"  => MapSet.new()
        },
        id: MapSet.new()
      } == Topic.resolve_ids([ "topic", "label", "none" ])
    end
  end
end
