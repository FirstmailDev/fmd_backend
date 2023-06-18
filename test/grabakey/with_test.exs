defmodule Firstmail.WithTest do
  use Firstmail.DataCase, async: false

  test "last assigned value is carried to both code blocks but not outside test" do
    var = 1

    res =
      with 1 <- var,
           var <- var + 1,
           2 <- var do
        var == 2
      else
        val -> val
      end

    assert true == res

    res =
      with 1 <- var,
           var <- var + 1,
           3 <- var do
        var == 2
      else
        val -> val
      end

    assert 2 == res
  end
end
