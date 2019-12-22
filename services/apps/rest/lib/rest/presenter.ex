defmodule Rest.Presenter do

  @type route :: { method :: atom, path :: String.t }
  @type presentable :: term

  @callback present(route, presentable) ::
      { :ok, String.t }
    | { :error, term }

  @spec present(module, route, presentable) :: String.t
  def present(module, route, presentable) do
    module.present(route, presentable)
  end

end
