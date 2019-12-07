defmodule Database.DocumentTest do
  use ExUnit.Case
  use Database.Case
  alias Database.{ Document, Fact, Id, Topic }

  defp persistent_topic(label) do
    topic = Topic.new(label)
    Topic.persist(topic)
    topic
  end

  describe "Given a transient topic" do
    test "fetch/1 returns nil" do
      assert nil == Document.fetch(Id.new())
    end
  end

  describe "Given a topic" do
    setup do
      [ topic: persistent_topic("topic label") ]
    end

    test "fetch/1 returns a document generated from the topic", %{
      topic: topic
    } do
      assert topic == Document.fetch(topic.id).topic
    end
  end

  describe "Given a topic related to itself by a fact" do
    setup do
      topic = persistent_topic("Topic A")
      fact = Fact.new("fact content", [ topic.id ])
      :ok = Fact.persist(fact)

      [ topic: topic, fact: fact ]
    end

    test "fetch/1 returns a document which contains the fact", %{
      topic: topic,
      fact: fact
    } do
      assert Document.fetch(topic.id).facts == MapSet.new([
        Fact.from(fact.id, fact.content, [ topic ])
      ])
    end
  end

  describe "Given topics A and B related by fact F" do
    setup do
      topic_a = persistent_topic("Topic A")
      topic_b = persistent_topic("Topic B")

      fact = Fact.new("Fact F", [ topic_a.id, topic_b.id ])
      :ok = Fact.persist(fact)

      [ topic_a: topic_a, topic_b: topic_b, fact: fact ]
    end

    test "fetch(A.id) returns a document that contains F", %{
      topic_a: topic_a,
      topic_b: topic_b,
      fact: fact
    } do
      assert Document.fetch(topic_a.id).facts == MapSet.new([
        Fact.from(fact.id, fact.content, [ topic_a, topic_b ])
      ])
    end

    test "fetch(B.id) returns a document that contains F", %{
      topic_a: topic_a,
      topic_b: topic_b,
      fact: fact
    } do
      assert Document.fetch(topic_b.id).facts == MapSet.new([
        Fact.from(fact.id, fact.content, [ topic_a, topic_b ])
      ])
    end
  end
end
