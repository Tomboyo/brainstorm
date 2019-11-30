defmodule Database.LuceneTest do
  use ExUnit.Case
  alias Database.Lucene

  test "Lucene.escape/1 escapes all special characters" do
    assert "\\+\\-\\&\\&\\|\\|\\!\\(\\)\\{\\}\\[\\]\\^\\\"\\~\\*\\?\\:\\\\"
      == Lucene.escape("+-&&||!(){}[]^\"~*?:\\")
  end

  test "Lucene.escape/1 quotes AND" do
    assert "\"and\" \"anD\" \"aNd\" \"aND\" \"And\" \"AnD\" \"ANd\" \"AND\""
      == Lucene.escape("and anD aNd aND And AnD ANd AND")
  end

  test "Lucene.escape/1 quotes OR" do
    assert "\"or\" \"oR\" \"Or\" \"OR\"" == Lucene.escape("or oR Or OR")
  end

end
