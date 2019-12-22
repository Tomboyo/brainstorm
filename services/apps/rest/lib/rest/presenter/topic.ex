defmodule Rest.Presenter.Topic do
  @behaviour Rest.Presenter

  @impl Rest.Presenter
  def present(route, presentable)
  def present({ :post, "/" }, topic), do: Jason.encode(topic.id)
  def present({ :get, "/" }, topics), do: Jason.encode(topics)
  def present({ :get, "/:id" }, topic), do: Jason.encode(topic)

end
