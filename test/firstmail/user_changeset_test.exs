defmodule Firstmail.UserChangesetTest do
  use Firstmail.DataCase, async: false

  @empty %{email: nil, token: "EMPTY"}

  test "email must be non blank" do
    changeset = User.changeset(%User{}, %{@empty | email: ""})
    assert %{email: ["can't be blank"]} == errors_on(changeset)
  end

  test "email without @ is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a.b.c"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email with \s is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a @b.c"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email with \n is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@\nb.c"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email with \r is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@\rb.c"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email with \t is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@\tb.c"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email with \s prefix is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: " a@b.c"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email with \s sufix is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@b.c "})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email @ no left nor right is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "@"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email @ no left is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "@a.b"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email @ no right is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email @ no double right is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@b"})
    assert %{email: ["has invalid format"]} == errors_on(changeset)
  end

  test "email passes validation" do
    changeset = User.changeset(%User{}, %{@empty | email: "a@b.c"})
    assert %{} == errors_on(changeset)
    changeset = User.changeset(%User{}, %{@empty | email: "x.y@b.c"})
    assert %{} == errors_on(changeset)
    changeset = User.changeset(%User{}, %{@empty | email: "x_y@b.c"})
    assert %{} == errors_on(changeset)
    changeset = User.changeset(%User{}, %{@empty | email: "x_y.w-z@b.c"})
    assert %{} == errors_on(changeset)
  end
end
