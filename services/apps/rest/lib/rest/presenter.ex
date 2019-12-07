defmodule Rest.Presenter do

  @callback present_id(term) ::
      { :ok, String.t }
    | { :error, term }

end
