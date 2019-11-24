defmodule Database.DocumentTest do
  use ExUnit.Case
  use Database.Case
  alias Database.{ Document, Fact, Topic }

  defp setup_persistent_topic(_context) do
    topic = Topic.new("my label")
    Topic.persist(topic)
    [ topic: topic ]
  end

  describe "given a transient topic" do
    setup do
      [ topic: Topic.new("transient label") ]
    end

    test "fetch returns nil", %{
      topic: topic
    } do
      assert nil == Document.fetch(topic.id)
    end
  end

  describe "given a persistent topic with no associated facts" do
    setup :setup_persistent_topic

    test "Document.fetch contains the topic", %{
      topic: topic
    } do
      assert topic == Document.fetch(topic.id).topic
    end

    test "Document.fetch contains no facts", %{
      topic: topic
    } do
      assert MapSet.new([]) == Document.fetch(topic.id).facts
    end
  end

  describe "given a persistent topic with an exomorphic fact" do
    setup :setup_persistent_topic
    setup %{ topic: topic } do
      [ topic: other_topic ] = setup_persistent_topic(nil)
      fact = Fact.new([ topic.id, other_topic.id ], "exomorphic fact")

      :ok = Fact.persist(fact)

      [ other_topic: other_topic, fact: fact ]
    end

    test "Document.fetch contains that fact", %{
      topic: topic,
      other_topic: other_topic,
      fact: fact
    } do
      assert Document.fetch(topic.id).facts == MapSet.new([
        %Fact{
          id: fact.id,
          content: fact.content,
          topics: MapSet.new([ topic, other_topic ])
        }
      ])
    end
  end

  describe "given a persistent topic with an endomorphic fact" do
    setup :setup_persistent_topic
    setup %{ topic: topic } do
      fact = Fact.new([ topic.id ], "endomorphic fact")

      :ok = Fact.persist(fact)

      [ topic: topic, fact: fact ]
    end

    test "Document.fetch contains that fact", %{
      topic: topic,
      fact: fact
    } do
      assert Document.fetch(topic.id).facts == MapSet.new([
        %Fact{
          id:      fact.id,
          content: fact.content,
          topics:  MapSet.new([ topic ])
        }
      ])
    end
  end

end
