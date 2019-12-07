defmodule Rest.Presenter.Json do
  @behaviour Rest.Presenter

  @impl Rest.Presenter
  def present_id(presentable), do: Jason.encode(presentable.id)

end
