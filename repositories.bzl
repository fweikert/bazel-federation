load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Repositories in this file have been tested with Bazel 0.26.0.

def _maybe(repo, name, **kwargs):
    if not native.existing_rule(name):
        repo(name = name, **kwargs)

def io_bazel_skylib():
    _maybe(
        http_archive,
        name = "io_bazel_skylib",
        url = "https://github.com/bazelbuild/bazel-skylib/archive/0.8.0.tar.gz",
        sha256 = "2ea8a5ed2b448baf4a6855d3ce049c4c452a6470b1efd1504fdb7c1c134d220a",
        strip_prefix = "bazel-skylib-0.8.0",
    )
