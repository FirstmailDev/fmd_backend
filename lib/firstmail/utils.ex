defmodule Firstmail.Utils do
  def domain(email) do
    [_, domain] = String.split(email, "@")
    domain
  end

  def parse_pem(pubkey_pem) do
    String.split(pubkey_pem, "\n", trim: true)
    |> Enum.filter(fn line -> not String.starts_with?(line, "-----") end)
    |> Enum.join()
  end
end
