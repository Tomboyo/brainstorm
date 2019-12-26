defmodule Rest.Presenter.Document do
  alias Database.Document

  @behaviour Rest.Presenter

  @impl Rest.Presenter
  def present(route, presentable)
  def present({ :get, "/:id" }, %Document{} = document) do
    { :ok, Jason.encode!(document) }
  end
  def present({ :get, "/:id" }, { :document_error, id, :enoent }) do
    { :ok, Jason.encode!("Could not generate document: No topic with id `#{id}` exists.") }
  end

end
