defmodule Utilx.NameUtils do
  def shorten_firstname(name) do
    [first, rest] = String.split(name, " ", parts: 2)
    [letter | _rest] = String.codepoints(first)
    "#{to_string(letter)}. #{rest}"
  end
end
