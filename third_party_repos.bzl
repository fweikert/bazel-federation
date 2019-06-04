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

    bind(
        name = "six",
        actual = "@six_archive//:six",
    )


def guava():
    maven_jar(
        name = "guava_maven",
        artifact = "com.google.guava:guava:18.0",
    )

    bind(
        name = "guava",
        actual = "@guava_maven//jar",
    )

def gson():
    maven_jar(
        name = "gson_maven",
        artifact = "com.google.code.gson:gson:2.7",
    )

    bind(
        name = "gson",
        actual = "@gson_maven//jar",
    )

def error_prone():
    maven_jar(
        name = "error_prone_annotations_maven",
        artifact = "com.google.errorprone:error_prone_annotations:2.3.2",
    )

    bind(
        name = "error_prone_annotations",
        actual = "@error_prone_annotations_maven//jar",
    )