defmodule Jason.Encoder.ImplementationsTest do
  @moduledoc """
  Tests of the custom Jason.Encoder implementations.

  The image/1 function spits out an elixir primitive representation of an input
  by calling decode(encode(input)). This allows us to test for equality more
  easily than with json strings.

  Tests lower in the file should use image/1 to construct expected outputs so
  that tests are independent of one another and terse. This is a "recursive"
  test strategy. So, for example, once MapSet and Topic are tested, use
  image(MapSet.new(topic)) or image(thing.topics) to construct expectations.
  """
  use ExUnit.Case
  alias Database.{ Document, Fact, Id, Topic }

  defp image(encodable) do
    { :ok, encoded } = Jason.encode(encodable)
    { :ok, decoded } = Jason.decode(encoded)
    decoded
  end

  test "Given a map set, Jason.encode returns a list" do
    assert [] == image(MapSet.new([]))
  end

  test "Given a string, Jason.encode returns a JSON string" do
    assert "string" == image("string")
  end

  test "Given a Database.Id, Jason.encode returns the id as a string" do
    id = Id.new()
    assert to_string(id) == image(id)
  end

  test "Given a Topic, Jason.encode returns a map of that topic" do
    topic = Topic.new("A")
    assert %{ "id" => image(topic.id), "label" => image(topic.label) }
      == image(topic)
  end

  test "Given a Fact, Jason.encode returns a map of that fact" do
    topic_a = Topic.new("A")
    topic_b = Topic.new("B")
    fact = Fact.new("content", [ topic_a, topic_b ])

    assert %{
      "id" => image(fact.id),
      "content" => image(fact.content),
      "topics" => image(fact.topics)
    } == image(fact)
  end

  test "Given a Document, Jason.encode returns a map of that document" do
    topic_a = Topic.new("A")
    topic_b = Topic.new("B")
    fact = Fact.new("content", [ topic_a, topic_b ])
    document_root = Topic.new("C")
    document = Document.new(document_root, [ fact ])

    assert %{
      "topic" => image(document_root),
      "facts" => image(document.facts)
    }
  end

end
