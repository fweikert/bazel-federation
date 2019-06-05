load("@bazel_federation//:repositories.bzl", "skydoc")
load("@bazel_federation//:setup.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def bazel_skylib_internal_deps():
    # TODO(fweikert): add skydoc to the federation repo and fetch it through the federation
    maybe(
        git_repository,
        name = "io_bazel_skydoc",
        commit = "ac5c106412697ffb9364864070bac796b9bb63d3",  # Feb 27, 2019
        remote = "https://github.com/bazelbuild/skydoc.git",
    )