defmodule Rest.Presenter.Fact do
  @behaviour Rest.Presenter

  @impl Rest.Presenter
  def present(route, presentable)
  def present({ :post, "/" }, %Database.Fact{} = fact) do
    Jason.encode(fact.id)
  end
  def present({ :post, "/" }, { :match, matches }), do: Jason.encode(matches)

end
