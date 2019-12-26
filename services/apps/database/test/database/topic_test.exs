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

  describe "resolve_ids/1" do
    test "resolves id strings to themselves" do
      ids = [ to_string(Id.new()), to_string(Id.new()) ]
      assert ids == Topic.resolve_ids(ids) |> elem(1)
    end
  end

  describe "resolve_ids/1 (given a search term which matches one topic)" do
    setup do
      topic = Topic.new("topic label")
      topic_id = to_string(topic.id)
      Topic.persist(topic)

      [ topic_id: topic_id ]
    end

    test "returns the id of the matched topic", %{
      topic_id: topic_id
    } do
      assert [ topic_id ] == Topic.resolve_ids([ "topic" ]) |> elem(1)
    end
  end

  describe "resolve_ids/1 (given a search term which matches several topics)" do
    setup do
      topic_a = Topic.new("topic a")
      topic_b = Topic.new("topic b")
      :ok = Topic.persist(topic_a)
      :ok = Topic.persist(topic_b)

      [ topics: [ topic_a, topic_b ]]
    end

    test "returns a mapping from the search term to matched topics", %{
      topics: topics
    } do
      assert %{ "topic" => MapSet.new(topics) } ==
        Topic.resolve_ids([ "topic" ])
        |> elem(1)
    end

    test "excludes search terms which resolved from the mapping", %{
      topics: topics
    } do
      assert %{ "topic" => MapSet.new(topics) } ==
        Topic.resolve_ids([ "topic", "topic a" ])
        |> elem(1)
    end
  end

  describe "resolve_ids/1 (when all terms resolve to an id)" do
    setup do
      topic = Topic.new("topic label")
      Topic.persist(topic)

      [ terms: [ to_string(Id.new()), topic.label ]]
    end

    test "resolves 'totally'", %{ terms: terms } do
      assert { :total, _ } = Topic.resolve_ids(terms)
    end
  end

  describe "resolve_ids/1 (when one or more terms to not resolve to an id)" do
    setup do
      topic_a = Topic.new("topic a")
      topic_b = Topic.new("topic b")
      :ok = Topic.persist(topic_a)
      :ok = Topic.persist(topic_b)

      [ terms: [ "topic", to_string(Id.new()) ]]
    end

    test "resolves 'partially'", %{ terms: terms } do
      assert { :partial, _ } = Topic.resolve_ids(terms)
    end
  end

end
