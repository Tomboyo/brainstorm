defmodule Rest.Presenter do

  @type route :: { method :: atom, path :: String.t }
  @type presentable :: term

  @callback present(route, presentable) ::
      { :ok, String.t }
    | { :error, term }

  def present!(module, route, presentable) do
    case module.present(route, presentable) do
      { :ok, value }   -> value
      { :error, term } -> raise term
    end
  end

end
