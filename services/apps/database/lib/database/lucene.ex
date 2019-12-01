defmodule Database.Lucene do

  # Escape Apache Lucene query text. Achtung: This is not iron-clad.
  #
  # There doesn't appear to be any functionality provided by Lucene itself to do
  # this. This code should not be trusted in a publicly-facing enviroment but
  # works well enough for single-user use on a private network.
  #
  # This escapes all special characters and quotes special terms (AND, OR, NOT).
  # The result is an implicit OR of single terms.
  #
  # See https://lucene.apache.org/core/2_9_4/queryparsersyntax.html#Escaping%20Special%20Characters
  @special_char ~r/[\+\-&\|\!\(\){}\[\]\^"~\*\?:\\]/
  @special_word ~r/([aA][nN][dD])|([oO][rR])|([nN][oO][tT])/
  def escape(text) do
    String.replace(text, @special_char, fn x -> "\\" <> x end)
    |> String.replace(@special_word, fn x -> "\"#{x}\"" end)
  end

end
