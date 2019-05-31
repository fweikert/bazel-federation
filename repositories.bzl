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
        url = "https://github.com/bazelbuild/bazel-skylib/archive/0.6.0.tar.gz",
        sha256 = "eb5c57e4c12e68c0c20bc774bfbc60a568e800d025557bc4ea022c6479acc867",
        strip_prefix = "bazel-skylib-0.6.0",
    )
