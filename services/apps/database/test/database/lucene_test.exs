defmodule Database.LuceneTest do
  use ExUnit.Case
  alias Database.Lucene

  describe "Lucene.escape/1" do
    test "quotes sequences of character" do
      assert ~S("term") == Lucene.escape(~S(term))
    end

    test "escapes all special characters" do
      assert ~S("\+") == Lucene.escape(~S(+))
      assert ~S("\-") == Lucene.escape(~S(-))
      assert ~S("\&") == Lucene.escape(~S(&))
      assert ~S("\|") == Lucene.escape(~S(|))
      assert ~S("\!") == Lucene.escape(~S(!))
      assert ~S{"\("} == Lucene.escape(~S{(})
      assert ~S{"\)"} == Lucene.escape(~S{)})
      assert ~S("\{") == Lucene.escape(~S({))
      assert ~S("\}") == Lucene.escape(~S(}))
      assert ~S("\[") == Lucene.escape(~S([))
      assert ~S("\]") == Lucene.escape(~S(]))
      assert ~S("\^") == Lucene.escape(~S(^))
      assert ~S("\"") == Lucene.escape(~S("))
      assert ~S("\~") == Lucene.escape(~S(~))
      assert ~S("\*") == Lucene.escape(~S(*))
      assert ~S("\?") == Lucene.escape(~S(?))
      assert ~S("\:") == Lucene.escape(~S(:))
      # A single backslash is escaped
      assert "\"\\\\\"" == Lucene.escape("\\")
    end

    test "joins quoted terms with AND" do
      assert ~S("this" AND "that") == Lucene.escape(~S(this that))
    end

    test "quotes terms containing escaped characters" do
      assert ~S("\"terms\"" AND "\^with" AND "quotes\+")
        == Lucene.escape(~S("terms" ^with quotes+))
    end
  end

end
