# TODO(fweikert): move into protobuf repo
load("@bazel_federation//:third_party_repos.bzl", "guava", "gson", "error_prone")

def test_deps():
    guava()
    gson()
    error_prone()