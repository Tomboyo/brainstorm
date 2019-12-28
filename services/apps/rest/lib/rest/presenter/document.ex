defmodule Rest.Presenter.Document do
  alias Database.Document

  @behaviour Rest.Presenter

  @get_by_id { :get, "/:id" }

  @impl Rest.Presenter
  def present(route, presentable)
  def present(@get_by_id, %Document{} = document) do
    { :ok, Jason.encode!(%{ "document" => document }) }
  end
  def present(@get_by_id, { :document_error, id, :enoent }) do
    { :ok, Jason.encode!("Could not generate document: No topic with id `#{id}` exists.") }
  end
  def present(@get_by_id, { :matched_search_terms, map }) do
    { :ok, Jason.encode!(%{ "match" => map }) }
  end

end
