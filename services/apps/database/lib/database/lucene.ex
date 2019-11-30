defmodule Database.Lucene do

  # Escape Apache Lucene query text. Achtung: This is not iron-clad.
  #
  # See https://lucene.apache.org/core/2_9_4/queryparsersyntax.html#Escaping%20Special%20Characters
  @special_char ~r/[\+\-&\|\!\(\){}\[\]\^"~\*\?:\\]/
  @special_word ~r/([aA][nN][dD])|([oO][rR])/
  def escape(text) do
    String.replace(text, @special_char, fn x -> "\\" <> x end)
    |> String.replace(@special_word, fn x -> "\"#{x}\"" end)
  end

end
