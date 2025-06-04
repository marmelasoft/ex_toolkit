defmodule ExToolkit.GitTest do
  use ExUnit.Case, async: true

  alias ExToolkit.Git

  describe "revision_hash/0" do
    test "returns a Git revision hash as a string in an expected format" do
      # The actual value of the revision hash will depend on your current Git state,
      # so we can't predict it easily. We can, however, make sure it's a 40-character string
      # (which is the length of a SHA-1 hash), assuming a successful Git command execution.
      hash = Git.revision_hash()
      assert is_binary(hash)
      assert Regex.match?(~r/\b[0-9a-f]{40}\b/, Git.revision_hash())
    end

    @tag :tmp_dir
    test "returns the exact Git revision hash in a stage git environment", %{tmp_dir: git_dir_path} do
      File.cd!(git_dir_path, fn ->
        git_init_repo()

        assert Git.revision_hash() == "12d5a410f53ce5e605364eab95d7d8b246b1d4af"
      end)
    end

    @tag :tmp_dir
    test "returns the exact Git revision hash from `.git/HEAD` when only ref is accessible", %{tmp_dir: git_dir_path} do
      File.cd!(git_dir_path, fn ->
        git_init_repo()

        System.cmd("rm", ["-rf", Path.join(git_dir_path, ".git/objects")])

        assert Git.revision_hash() == "e9fb75a2e9ca5958dd4d5a7898f5d8efe756b48f"
      end)
    end

    @tag :tmp_dir
    test "returns the exact Git revision hash from `.git/HEAD` when repo is not accessible", %{tmp_dir: git_dir_path} do
      File.cd!(git_dir_path, fn ->
        git_init_repo()

        {commit_hash, 0} =
          System.cmd("git", ["rev-parse", "HEAD"], stderr_to_stdout: true, into: "")

        {_output, 0} =
          System.cmd("git", ["checkout", String.trim(commit_hash)],
            stderr_to_stdout: true,
            into: ""
          )

        System.cmd("rm", ["-rf", Path.join(git_dir_path, ".git/objects")])

        assert Git.revision_hash() == "e9fb75a2e9ca5958dd4d5a7898f5d8efe756b48f"
      end)
    end
  end

  defp git_init_repo do
    System.cmd("git", ["init"])

    System.cmd("git", ["commit", "--no-gpg-sign", "--allow-empty", "-m", "Hi"],
      env: [
        {"GIT_AUTHOR_NAME", "Test"},
        {"GIT_AUTHOR_EMAIL", "test@example.com"},
        {"GIT_AUTHOR_DATE", "2023-03-04T23:36:00 +000"},
        {"GIT_COMMITTER_NAME", "Test"},
        {"GIT_COMMITTER_EMAIL", "test@example.com"},
        {"GIT_COMMITTER_DATE", "2023-03-04T23:36:00 +000"}
      ]
    )
  end
end
