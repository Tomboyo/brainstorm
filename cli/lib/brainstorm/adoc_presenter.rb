require 'brainstorm'

class Brainstorm::AdocPresenter

  def present(document)
    topic = document['topic']
    facts = document['facts']

    <<~ADOC
    = #{topic['label']}
    #{present_facts(facts)}
    ADOC
  end

  def present_facts(facts)
    if facts.empty?
      "(No facts are associated with this topic.)"
    else
      facts
        .map { |fact| present_fact(fact) }
        .join("\n")
    end
  end

  def present_fact(fact)
    heading = fact['topics']
      .map { |topic| "<#{topic['id']}> #{topic['label']}" }
      .join(", ")
    
    <<~ADOC
    == #{heading}
    #{fact['content']}
    ADOC
  end
end