load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//:setup.bzl", "maybe")
load("//:third_party_repos.bzl", "zlib", "org_golang_x_tools", "org_golang_x_sys", "six", "jinja2", "mistune", "markupsafe")

# Repositories in this file have been tested with Bazel 0.26.0.

def bazel_skylib():
    maybe(
        http_archive,
        name = "bazel_skylib",
        url = "https://github.com/bazelbuild/bazel-skylib/archive/0.8.0.tar.gz",
        sha256 = "2ea8a5ed2b448baf4a6855d3ce049c4c452a6470b1efd1504fdb7c1c134d220a",
        strip_prefix = "bazel-skylib-0.8.0",
    )

# TODO(fweikert): delete this function if it's not needed by the protobuf project itself.
def protobuf_deps():
    zlib()

def protobuf():
    protobuf_deps()
    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "b404fe166de66e9a5e6dab43dc637070f950cdba2a8a4c9ed9add354ed4f6525",
        strip_prefix = "protobuf-b4f193788c9f0f05d7e0879ea96cd738630e5d51",
        # Commit from 2019-05-15, update to protobuf 3.8 when available.
        url = "https://github.com/protocolbuffers/protobuf/archive/b4f193788c9f0f05d7e0879ea96cd738630e5d51.zip",
    )


# TODO(fweikert): same as above
def rules_go_deps():
    protobuf()
    org_golang_x_tools()
    org_golang_x_sys()


def rules_go():
    rules_go_deps()
    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "7be7dc01f1e0afdba6c8eb2b43d2fa01c743be1b9273ab1eaf6c233df078d705",
        urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.16.5/rules_go-0.16.5.tar.gz"],
    )


def buildtools_deps():
    bazel_skylib()
    rules_go()

def buildtools():
    buildtools_deps()
    maybe(
        http_archive,
        name = "com_github_bazelbuild_buildtools",
        strip_prefix = "buildtools-<commit hash>",
        url = "https://github.com/bazelbuild/buildtools/archive/<commit hash>.zip",
    )

def skydoc_deps(use_deprecated_skydoc):
    bazel_skylib()
    rules_nodejs()
    rules_sass()
    six()
    jinja2()
    mistune()
    markupsafe()

    if use_deprecated_skydoc:
        protobuf()

def skydoc(use_deprecated_skydoc=False):
    skydoc_deps(use_deprecated_skydoc)
    maybe(
        git_repository,
        name = "io_bazel_skydoc",
        commit = "ac5c106412697ffb9364864070bac796b9bb63d3",  # Feb 27, 2019
        remote = "https://github.com/bazelbuild/skydoc.git",
    )

def rules_nodejs():
    maybe(
        http_archive,
        name = "build_bazel_rules_nodejs",
        url = "https://github.com/bazelbuild/rules_nodejs/releases/download/0.30.1/rules_nodejs-0.30.1.tar.gz",
        sha256 = "abcf497e89cfc1d09132adfcd8c07526d026e162ae2cb681dcb896046417ce91",
    )

# TODO(fweikert): add sass
def rules_sass_deps():
    rules_nodejs()

def rules_sass():
    rules_sass_deps()

def bazel():
    maybe(
        git_repository,
        name = "io_bazel",
        remote = "https://github.com/bazelbuild/bazel.git",
        commit = "c689bf93917ad0efa8100b3a0fe1b43f1f1a1cdf",  # Mar 19, 2019
    )

#########################################
#               TODO                    #
#########################################
# TODO(fweikert): check dependencies and fetch them through the federation, too

# TODO(fweikert): add all gazelle dependencies to the federation, even though that might cause problems because of go_repository rules.
def gazelle():
    rules_go()
    maybe(
        git_repository,
        name = "bazel_gazelle",
        commit = "aa1a9cfe4845bc83482af92addbfcd41f8dc51f0",  # master as of 2019-01-27
        remote = "https://github.com/bazelbuild/bazel-gazelle",
        shallow_since = "1548631399 -0500",
    )

def bazel_integration_testing():
    maybe(
        http_archive,
        name = "build_bazel_integration_testing",
        url = "https://github.com/bazelbuild/bazel-integration-testing/archive/13a7d5112aaae5572544c609f364d430962784b1.zip",
        type = "zip",
        strip_prefix = "bazel-integration-testing-13a7d5112aaae5572544c609f364d430962784b1",
        sha256 = "8028ceaad3613404254d6b337f50dc52c0fe77522d0db897f093dd982c6e63ee",
    )


def bazel_toolchains():
    maybe(
        http_archive,
        name = "bazel_toolchains",
        sha256 = "5962fe677a43226c409316fcb321d668fc4b7fa97cb1f9ef45e7dc2676097b26",
        strip_prefix = "bazel-toolchains-be10bee3010494721f08a0fccd7f57411a1e773e",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/be10bee3010494721f08a0fccd7f57411a1e773e.tar.gz",
            "https://github.com/bazelbuild/bazel-toolchains/archive/be10bee3010494721f08a0fccd7f57411a1e773e.tar.gz",
        ],
    )
