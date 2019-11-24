defmodule Database.TopicTest do
  use ExUnit.Case
  use Database.Case
  doctest Database.Topic

  alias Database.{ Fact, Topic }

  defp setup_persistent_topic(_context) do
    topic = Topic.new("my label")
    Topic.persist(topic)
    [ topic: topic ]
  end

  describe "given a persistent topic with no associated facts" do
    setup :setup_persistent_topic

    test "Topic.fetch returns a map with the topic", %{
      topic: topic
    } do
      assert %{ topic: ^topic } = Topic.fetch(topic.id)
    end

    test "Topic.fetch returns a map with no facts", %{
      topic: topic
    } do
      facts = MapSet.new([])
      assert %{ facts: ^facts } = Topic.fetch(topic.id)
    end

    test "Topic.persist fails to persist the topic again", %{
      topic: persistent
    } do
      assert { :error, _any } = Topic.persist(persistent)
    end
  end

  describe "given a persistent topic with associated facts" do
    setup context do
      [ topic: topic       ] = setup_persistent_topic(context)
      [ topic: other_topic ] = setup_persistent_topic(context)

      internal_fact = Fact.new([ topic.id ], "internal")
      external_fact = Fact.new([ topic.id, other_topic.id ], "external")

      :ok = Fact.persist(internal_fact)
      :ok = Fact.persist(external_fact)

      [
        topic: topic,
        other_topic: other_topic,
        internal_fact: internal_fact,
        external_fact: external_fact
      ]
    end

    test "Topic.fetch returns a map with those facts", %{
      topic: topic,
      other_topic: other_topic,
      internal_fact: internal_fact,
      external_fact: external_fact
    } do
      actual = Topic.fetch(topic.id)

      assert actual.facts == MapSet.new([
        %Fact{
          id:      internal_fact.id,
          content: internal_fact.content,
          topics:  MapSet.new([ topic ])
        },
        %Fact{
          id:      external_fact.id,
          content: external_fact.content,
          topics:  MapSet.new([ topic, other_topic ])
        }
      ])
    end
  end

  describe "given a transient topic" do
    setup do
      [ topic: Topic.new("I am transient") ]
    end

    test "Topic.fetch returns nil", %{
      topic: transient
    } do
      assert nil == Topic.fetch(transient.id)
    end

    test "Topic.persist returns :ok", %{
      topic: transient
    } do
      assert :ok == Topic.persist(transient)
    end
  end

end
