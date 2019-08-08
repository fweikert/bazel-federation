#!/usr/bin/env python3
#
# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import os
import os.path
import sys
import utils


WORKSPACE_TEMPLATE = (
    """workspace(name = "{project}_federation_example")

local_repository(
    name = "bazel_federation",
    path = "..",
)

load("@bazel_federation//:repositories.bzl", "{project}")

{project}()

load("@{project}//:setup.bzl", "{project}_setup")

{project}_setup()

load("@{project}//:internal_deps.bzl", "{project}_internal_deps")

{project}_internal_deps()

load("@{project}//:internal_setup.bzl", "{project}_internal_setup")

{project}_internal_setup()
""")


def create_new_workspace(project_name):
    return WORKSPACE_TEMPLATE.format(project=project_name)


def set_up_project(project_name, workspace_content):
    os.mkdir(project_name)
    path = os.path.join(os.getcwd(), project_name, "WORKSPACE")
    with open(path, "w") as f:
        f.write(workspace_content)


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    parser = argparse.ArgumentParser(description="Bazel Federation WORKSPACE Generation Script")
    parser.add_argument("--project", type=str, required=True)

    args = parser.parse_args(argv)

    try:
        content = create_new_workspace(args.project)
        set_up_project(args.project, content)
    except Exception as ex:
        utils.eprint(ex)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
