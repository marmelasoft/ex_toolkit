defmodule Utilx.GitUtilsTest do
  use ExUnit.Case, async: true

  alias Utilx.GitUtils

  describe "revision_hash/0" do
    test "returns a Git revision hash as a string in an expected format" do
      # The actual value of the revision hash will depend on your current Git state,
      # so we can't predict it easily. We can, however, make sure it's a 40-character string
      # (which is the length of a SHA-1 hash), assuming a successful Git command execution.
      hash = GitUtils.revision_hash()
      assert is_binary(hash)
      assert Regex.match?(~r/\b[0-9a-f]{40}\b/, GitUtils.revision_hash())
    end

    test "returns the exact Git revision hash in a stage environment" do
      System.cmd("mkdir", ["-p", "test/test-repo"])

      File.cd!("test/test-repo", fn ->
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

        assert GitUtils.revision_hash() == "12d5a410f53ce5e605364eab95d7d8b246b1d4af"
      end)

      System.cmd("rm", ["-rf", "test/test-repo"])
    end
  end
end
