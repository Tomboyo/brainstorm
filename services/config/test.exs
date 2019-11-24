import Config

config :rest,
  topic_database: Database.TopicMock
config :rest,
  fact_database: Database.FactMock
config :rest,
  document_database: Database.DocumentMock
