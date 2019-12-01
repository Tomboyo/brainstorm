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

  test "Lucene.escape/1 quotes NOT" do
    assert "\"not\" \"noT\" \"nOt\" \"nOT\" \"Not\" \"NoT\" \"NOt\" \"NOT\"" ==
      Lucene.escape("not noT nOt nOT Not NoT NOt NOT")
  end

  # implicit or queries by use of whitespace (this is 4 or'd terms)
  test "Lucene.escape/1 creates OR queries from compositions" do
    assert ~S{title\:\(\+pink \(\~red "AND" \"blue green\"\)\)} ==
        Lucene.escape(~S{title:(+pink (~red AND "blue green"))})
  end

end
