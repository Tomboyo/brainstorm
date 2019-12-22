import Config

config :rest,
  topic_database: Database.TopicMock,
  topic_presenter: Rest.Presenter.TopicMock,

  fact_database: Database.FactMock,
  fact_presenter: Rest.Presenter.FactMock,

  document_database: Database.DocumentMock,
  document_presenter: Rest.Presenter.DocumentMock
