defmodule Database.TopicTest do
  use ExUnit.Case
  use Database.Case
  doctest Database.Topic

  alias Database.Topic

  describe "given a persistent topic" do
    setup do
      topic = Topic.new("my label")
      Topic.persist(topic)
      [ topic: topic ]
    end

    test "Topic.fetch retrieves the topic", %{
      topic: persistent
    } do
      actual = Topic.fetch(persistent.id)
      assert persistent == actual
    end

    test "Topic.persist fails to persist the topic again", %{
      topic: persistent
    } do
      assert { :error, _any } = Topic.persist(persistent)
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