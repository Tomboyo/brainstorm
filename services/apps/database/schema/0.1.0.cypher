CREATE CONSTRAINT ON (topic :topic) ASSERT topic.id IS UNIQUE;
CALL db.index.fulltext.createNodeIndex(
  "topic_label",
  ["topic"],
  ["label"],
  { analyzer: "simple" });