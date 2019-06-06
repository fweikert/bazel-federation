load("@bazel_federation//:repositories.bzl", "rules_sass", "skydoc")
load("@bazel_federation//:third_party_repos.bzl", "futures_2_whl", "futures_3_whl", "google_cloud_language_whl", "grpc_whl", "mock_whl", "subpar")


def rules_python_internal_deps():
    rules_sass()
    skydoc()

    futures_2_whl()
    futures_3_whl()
    google_cloud_language_whl()
    grpc_whl()
    mock_whl()
    subpar()
