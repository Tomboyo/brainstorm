defmodule Rest.Presenter do

  @type route :: { method :: atom, path :: String.t }
  @type presentable :: term

  @callback present(route, presentable) ::
      { :ok, String.t }
    | { :error, term }

end
