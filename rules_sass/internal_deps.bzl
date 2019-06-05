load("@bazel_federation//:repositories.bzl", "bazel", "buildtools", "skydoc", "rules_go")
load("@bazel_federation//:third_party_repos.bzl", "zlib")


def rules_sass_internal_deps():
    bazel()
    buildtools()
    skydoc()
    rules_go()
