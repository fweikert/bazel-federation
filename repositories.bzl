load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//:java_repositories.bzl", "remote_jdk11_repos", "java_tools_javac11_repos")
load("//:third_party_repos.bzl", "zlib", "org_golang_x_tools", "org_golang_x_sys", "six", "jinja2", "mistune", "markupsafe")

# Repositories in this file have been tested with Bazel 0.26.0.

def bazel_skylib_deps():
    pass

def bazel_skylib():
    bazel_skylib_deps()
    # TODO: point to original repository (was bazel-skylib-0.8.0)
    maybe(
        git_repository,
        name = "bazel_skylib",
        commit = "443b6a0008d87b8a65c4344d372617986cd1b829",
        remote = "https://github.com/fweikert/bazel-skylib.git",
    )

# TODO(fweikert): delete this function if it's not needed by the protobuf project itself.
def protobuf_deps():
    zlib()
    protobuf_javalite()

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
    native.bind(name = "com_google_protobuf_cc", actual = "@com_google_protobuf")
    native.bind(name = "com_google_protobuf_java", actual = "@com_google_protobuf")

def protobuf_javalite():
    maybe(
        http_archive,
        name = "com_google_protobuf_javalite",
        strip_prefix = "protobuf-javalite",
        urls = ["https://github.com/protocolbuffers/protobuf/archive/javalite.zip"],
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
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/0.18.6/rules_go-0.18.6.tar.gz",
            "https://github.com/bazelbuild/rules_go/releases/download/0.18.6/rules_go-0.18.6.tar.gz",
        ],
        sha256 = "f04d2373bcaf8aa09bccb08a98a57e721306c8f6043a2a0ee610fd6853dcde3d",
    )


def buildtools_deps():
    bazel_skylib()
    rules_go()

def buildtools():
    buildtools_deps()
    maybe(
        http_archive,
        name = "com_github_bazelbuild_buildtools",
        strip_prefix = "buildtools-f27d1753c8b3210d9e87cdc9c45bc2739ae2c2db",
        url = "https://github.com/bazelbuild/buildtools/archive/f27d1753c8b3210d9e87cdc9c45bc2739ae2c2db.zip",
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

def rules_sass_deps():
    bazel_skylib()
    rules_nodejs()

def rules_sass():
    rules_sass_deps()
    maybe(
        git_repository,
        name = "io_bazel_rules_sass",
        remote = "https://github.com/bazelbuild/rules_sass.git",
        commit = "8ccf4f1c351928b55d5dddf3672e3667f6978d60",
    )

def bazel():
    maybe(
        git_repository,
        name = "io_bazel",
        remote = "https://github.com/bazelbuild/bazel.git",
        commit = "c689bf93917ad0efa8100b3a0fe1b43f1f1a1cdf",  # Mar 19, 2019
    )


def rules_cc_deps():
    pass  # empty for now


def rules_cc():
    rules_cc_deps()
    # TODO: use correct repository
    maybe(
        git_repository,
        name = "rules_cc",
        remote = "https://github.com/fweikert/rules_cc.git",
        commit = "1545d1c041107b60f615abf29d90f35c31cd6e23",
    )


def rules_java_deps():
    remote_jdk11_repos()
    java_tools_javac11_repos()
    bazel_skylib()


def rules_java():
    rules_java_deps()
    # TODO: use correct repo
    maybe(
        git_repository,
        name = "rules_java",
        remote = "https://github.com/fweikert/rules_java.git",
        commit = "43d3483ce1e641cc8c5254259f63864c6142b00f",
    )


def rules_python():
    maybe(
        git_repository,
        name = "io_bazel_rules_python",
        remote = "https://github.com/bazelbuild/rules_python.git",
        commit = "fdbb17a4118a1728d19e638a5291b4c4266ea5b8",
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
