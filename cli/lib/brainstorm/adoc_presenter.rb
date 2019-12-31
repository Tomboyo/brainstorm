require 'brainstorm'
require 'brainstorm/version'
require 'brainstorm/model'
require 'brainstorm/model/document'

class Brainstorm::AdocPresenter

  def create_fact(response)
    case response.code
    when :id
      response.value
    when :match
      present_matches(response.value)
    end
  end

  def fetch_document(response)
    case response.code
    when :document
      present_document(response.value)
    when :enoent
      "Could not generate document: No topic with the given id exists."
    when :match
      present_matches(response.value)
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
    end
  end

  private

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

  def present_matches(matches)
    # sort matches by search term string
    matches = matches.to_a.sort { |a, b| a[0] <=> b[0] }
    # present each match group
    presented = matches.map { |term, topics| present_match(term, topics) }
    # separate each presentation by a paragraph followed by a footer
    [ *presented, matches_footer() ].join("\n\n")
  end

  def present_match(term, topics)
    if topics.empty?
      present_unmatched_term(term)
    else
      present_matched_term(term, topics)
    end
  end

  def present_unmatched_term(term)
    "No topics could be found for the search term \"#{term}\"."
  end

  def present_matched_term(term, topics)
    rendered_term = "The term \"#{term}\" matched the following topics:"
    rendered_topics = topics
      .map { |topic| "* #{topic.label} (#{topic.id})" }
      .sort
    
    [ rendered_term, *rendered_topics ].join("\n")
  end

  def matches_footer
    "Please refine your request to match a specific topic."
  end

end