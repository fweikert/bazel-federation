load("@bazel_federation//:third_party_repos.bzl", "zlib", "six")

def protobuf_test_deps():
    zlib()
    six()