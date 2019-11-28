require 'brainstorm'
require 'brainstorm/model/fact'
require 'brainstorm/model/topic'

class Brainstorm::AdocPresenter

  def present(document)
    facts = document.facts
      .sort { |f1, f2| paragraph(0, f1) <=> paragraph(0, f2) }
      .to_a
    
    [
      title(document.topic.label),
      paragraphs(facts),
      references(facts),
    ].join("\n\n") << ("\n")
  end

  private

  def title(text)
    heading(1, text)
  end

  def heading(level, text)
    "#{'=' * level} #{text}"
  end

  def paragraphs(facts)
    facts.map.with_index do |p, i|
      paragraph(i, p)
    end.join("\n\n")
  end

  def paragraph(index, fact)
    heading = heading(2, fact.topics
      .map(&:label.to_proc)
      .sort
      .join(" - ")
      .prepend("#{index + 1}. "))
    
    "#{heading}\n#{fact.content.strip}"
  end

  def references(facts)
    facts.map.with_index do |fact, i|
      reference(fact, i)
    end
    .join("\n\n")
    .prepend(heading(2, "Referenced Facts\n"))
  end

  def reference(fact, i)
    fact_id = "#{i + 1}. #{fact.id}"
    topic_bullets = fact.topics.map do |topic|
      "* #{topic.label}: #{topic.id}"
    end
    [ fact_id, *topic_bullets ].join("\n")
  end
end