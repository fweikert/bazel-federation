load("@bazel_federation//:repositories.bzl", "bazel_skylib", "bazel_toolchains", "gazelle")
load("@bazel_federation//:third_party_repos.bzl", "llvm_toolchain")

def rules_go_internal_deps():
    bazel_skylib()
    bazel_toolchains()
    gazelle()
    llvm_toolchain()
