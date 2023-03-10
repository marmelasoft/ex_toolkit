defmodule Utilx.GitUtils do
  @spec revision_hash :: String.t()
  def revision_hash do
    case System.cmd("git", ["rev-parse", "HEAD"]) do
      {ref, 0} ->
        ref

      {_, _code} ->
        git_ref = File.read!(".git/HEAD")

        if String.contains?(git_ref, "ref:") do
          ["ref:", ref_path] = String.split(git_ref)
          File.read!(".git/#{ref_path}")
        else
          git_ref
        end
    end
    |> String.replace("\n", "")
  end
end
