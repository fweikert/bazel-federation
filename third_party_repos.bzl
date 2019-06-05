load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//:setup.bzl", "maybe")

def zlib():
    maybe(
        http_archive,
        name = "zlib",
        build_file = "@bazel_federation//:third_party/zlib.BUILD",
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        urls = ["https://zlib.net/zlib-1.2.11.tar.gz"],
    )

def six():
    maybe(
        http_archive,
        name = "six_archive",
        build_file = "@bazel_federation//:third_party/six.BUILD",
        sha256 = "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a",
        urls = ["https://pypi.python.org/packages/source/s/six/six-1.10.0.tar.gz#md5=34eed507548117b2ab523ab14b2f8b55"],
    )
    native.bind(name = "six", actual = "@six_archive//:six")

def org_golang_x_tools():
    maybe(
        http_archive,
        name = "org_golang_x_tools",
        # master^1, as of 2018-11-02 (master is currently broken)
        urls = ["https://codeload.github.com/golang/tools/zip/92b943e6bff73e0dfe9e975d94043d8f31067b06"],
        strip_prefix = "tools-92b943e6bff73e0dfe9e975d94043d8f31067b06",
        type = "zip",
        patches = [
            "@io_bazel_rules_go//third_party:org_golang_x_tools-gazelle.patch",
            "@io_bazel_rules_go//third_party:org_golang_x_tools-extras.patch",
        ],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix golang.org/x/tools
    )

def org_golang_x_sys():
    maybe(
        git_repository,
        name = "org_golang_x_sys",
        remote = "https://github.com/golang/sys",
        commit = "e4b3c5e9061176387e7cea65e4dc5853801f3fb7",  # master as of 2018-09-28
        patches = ["@io_bazel_rules_go//third_party:org_golang_x_sys-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix golang.org/x/sys
    )

# For manual testing against an LLVM toolchain.
# Use --crosstool_top=@llvm_toolchain//:toolchain
def llvm_toolchain():
    maybe(
        http_archive,
        name = "com_grail_bazel_toolchain",
        sha256 = "aafea89b6abe75205418c0d2127252948afe6c7f2287a79b67aab3e0c3676c4f",
        strip_prefix = "bazel-toolchain-d0a5b0af3102c7c607f2cf098421fcdbaeaaaf19",
        urls = ["https://github.com/grailbio/bazel-toolchain/archive/d0a5b0af3102c7c607f2cf098421fcdbaeaaaf19.tar.gz"],
    )

JINJA2_BUILD_FILE = """
py_library(
    name = "jinja2",
    srcs = glob(["jinja2/*.py"]),
    srcs_version = "PY2AND3",
    deps = [
        "@markupsafe_archive//:markupsafe",
    ],
    visibility = ["//visibility:public"],
)
"""

MARKUPSAFE_BUILD_FILE = """
py_library(
    name = "markupsafe",
    srcs = glob(["markupsafe/*.py"]),
    srcs_version = "PY2AND3",
    visibility = ["//visibility:public"],
)
"""

MISTUNE_BUILD_FILE = """
py_library(
    name = "mistune",
    srcs = ["mistune.py"],
    srcs_version = "PY2AND3",
    visibility = ["//visibility:public"],
)
"""

def markupsafe():
    maybe(
        http_archive,
        name = "markupsafe_archive",
        urls = ["https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz#md5=f5ab3deee4c37cd6a922fb81e730da6e"],
        sha256 = "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3",
        build_file_content = MARKUPSAFE_BUILD_FILE,
        strip_prefix = "MarkupSafe-0.23",
    )
    native.bind(
        name = "markupsafe",
        actual = "@markupsafe_archive//:markupsafe",
    )

def jinja2():
    maybe(
        http_archive,
        name = "jinja2_archive",
        urls = ["https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.8.tar.gz#md5=edb51693fe22c53cee5403775c71a99e"],
        sha256 = "bc1ff2ff88dbfacefde4ddde471d1417d3b304e8df103a7a9437d47269201bf4",
        build_file_content = JINJA2_BUILD_FILE,
        strip_prefix = "Jinja2-2.8",
    )
    native.bind(
        name = "jinja2",
        actual = "@jinja2_archive//:jinja2",
    )

def mistune():
    maybe(
        http_archive,
        name = "mistune_archive",
        urls = ["https://pypi.python.org/packages/source/m/mistune/mistune-0.7.1.tar.gz#md5=057bc28bf629d6a1283d680a34ed9d0f"],
        sha256 = "6076dedf768348927d991f4371e5a799c6a0158b16091df08ee85ee231d929a7",
        build_file_content = MISTUNE_BUILD_FILE,
        strip_prefix = "mistune-0.7.1",
    )
    native.bind(
        name = "mistune",
        actual = "@mistune_archive//:mistune",
    )