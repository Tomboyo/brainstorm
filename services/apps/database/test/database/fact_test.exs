defmodule Database.FactTest do
  use ExUnit.Case
  use Database.Case
  alias Database.{ Fact, Topic }
  doctest Database.Fact

  def setup_persistent_topic(_context) do
    topic = Topic.new("my label")
    :ok = Topic.persist(topic)
    [ topic: topic ]
  end

  describe "given a transient fact" do
    setup :setup_persistent_topic
    setup %{ topic: topic } do
      [ fact: Fact.new("transient fact content", [ topic.id ]) ]
    end

    test "Fact.persist returns :ok", %{
      fact: transient
    } do
      assert :ok == Fact.persist(transient)
    end
  end

end
