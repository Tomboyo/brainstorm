require 'brainstorm'
require 'brainstorm/version'
require 'brainstorm/model'
require 'brainstorm/model/document'

class Brainstorm::AdocPresenter

  def fetch_document(response)
    case response.code
    when :document
      present_document(response.value)
    when :enoent
      "Could not generate document: No topic with the given id exists."
    when :match
      present_document_matches(response.value)
    end
  end

  def find_topics(topics)
    topics
      .map { |topic| "#{topic.label} <#{topic.id}>" }
      .join("\n") << "\n"
  end

  def delete_topic(response)
    case response
    when :ok
      'Topic deleted.'
    when :enoent
      'Topic not found.'
    else
      present_error(response)
    end
  end

  private

  def present_error(error)
    case error
    when StandardError
      "Encountered an error: `#{error}`#{error.backtrace&.join("\n")&.<<("\n")}"
    else
      "Unexpected error: unexpected service response `#{error}`."
    end
  end

  def present_document(document)
    facts = document.facts
      .sort { |f1, f2| paragraph(0, f1) <=> paragraph(0, f2) }
      .to_a
    
    [
      title(document.topic.label),
      paragraphs(facts),
      references(facts),
    ].join("\n\n") << "\n"
  end

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

  def present_document_matches(matches)
    term, topics = matches.to_a()[0] # there is only one k-v pair

    if topics.empty?
      unmatched_term(term)
    else
      matched_term(term, topics)
    end
  end

  def unmatched_term(term)
    "No topics could be found for the search term \"#{term}\"."
  end

  def matched_term(term, topics)
    rendered_term = "The term \"#{term}\" matched the following topics:"
    rendered_topics = topics
      .map { |topic| "* #{topic.label} (#{topic.id})" }
      .sort
    footer = "Please refine your request to match a specific topic."
    
    [ rendered_term, *rendered_topics, footer ].join("\n")
  end

end