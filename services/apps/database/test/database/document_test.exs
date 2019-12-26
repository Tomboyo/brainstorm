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
    test "fetch/1 returns a :not_found error" do
      id = Id.new()
      assert :enoent == Document.fetch(id)
    end
  end

  describe "Given a topic" do
    setup do
      [ topic: persistent_topic("topic label") ]
    end

    test "fetch/1 returns a document generated from the topic", %{
      topic: topic
    } do
      { :ok, document } = Document.fetch(topic.id)
      assert topic == document.topic
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
      { :ok, document } = Document.fetch(topic.id)
      assert MapSet.new([
        Fact.from(fact.id, fact.content, [ topic ])
      ]) == document.facts
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
      { :ok, document } = Document.fetch(topic_a.id)
      assert MapSet.new([
        Fact.from(fact.id, fact.content, [ topic_a, topic_b ])
      ]) == document.facts
    end

    test "fetch(B.id) returns a document that contains F", %{
      topic_a: topic_a,
      topic_b: topic_b,
      fact: fact
    } do
      { :ok, document } = Document.fetch(topic_b.id)
      assert MapSet.new([
        Fact.from(fact.id, fact.content, [ topic_a, topic_b ])
      ]) == document.facts
    end
  end
end
