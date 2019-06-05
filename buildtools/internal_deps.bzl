load("@bazel_federation//:repositories.bzl", "gazelle")

def buildtools_internal_deps():
    gazelle()
