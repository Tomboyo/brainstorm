defmodule Rest.Presenter.Document do
  @behaviour Rest.Presenter

  @impl Rest.Presenter
  def present(route, presentable)

  def present({ :get, "/:id" }, document), do: Jason.encode(document)
end
