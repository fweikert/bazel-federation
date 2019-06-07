load("@bazel_federation//:repositories.bzl", "bazel", "skydoc")

def bazel_skylib_internal_deps():
    bazel()
    skydoc()