load("@bazel_federation//:repositories.bzl", "bazel", "bazel_integration_testing", "bazel_skylib", "bazel_toolchains", "protobuf", "rules_sass", "skydoc")
load("@bazel_federation//:third_party_repos.bzl", "zlib")


def rules_nodejs_internal_deps():
    bazel()
    bazel_integration_testing()
    bazel_skylib()
    bazel_toolchains()
    protobuf()
    rules_sass()
    skydoc()
    zlib()