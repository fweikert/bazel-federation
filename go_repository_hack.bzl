# TODO(fweikert): This file only exists to signal the problems with the go_repository rule. It's technically redundant,
# but should serve as a marker.
load("@bazel_gazelle//:deps.bzl", _go_repository = "go_repository", _gazelle_dependencies = "gazelle_dependencies")

go_repository = _go_repository
gazelle_dependencies = _gazelle_dependencies