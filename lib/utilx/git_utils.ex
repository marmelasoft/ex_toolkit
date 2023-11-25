defmodule Utilx.GitUtils do
  @moduledoc """
  This module provides utility functions for interacting with Git.
  """

  @doc """
  Retrieves the current Git revision hash.
  """
  @spec revision_hash :: String.t()
  def revision_hash do
    case System.cmd("git", ["rev-parse", "HEAD"], stderr_to_stdout: true, into: "") do
      {ref, 0} -> String.trim(ref)
      _ -> get_git_ref()
    end
  rescue
    _ -> get_git_ref()
  end

  defp get_git_ref do
    git_ref = File.read!(Path.join(".git", "HEAD"))

    if String.contains?(git_ref, "ref:") do
      [_, ref_path] = String.split(git_ref)
      File.read!(Path.join(".git", String.trim(ref_path)))
    else
      git_ref
    end
    |> String.trim()
  end
end
