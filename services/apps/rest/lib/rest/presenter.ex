defmodule Rest.Presenter do

  @callback present(term) ::
      { :ok, String.t }
    | { :error, term }

  # TODO: remove
  @callback present_id(term) ::
      { :ok, String.t }
    | { :error, term }

end
