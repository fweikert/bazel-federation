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
import codecs
import os
import os.path
import re
import sys
import urllib.request
import utils


LOCAL_FEDERATION_TEMPLATE = """local_repository(
    name = "bazel_federation",
    path = "..",
)"""

WORKSPACE_TEMPLATE = """workspace(name = "{project}_federation_example")

%s

load("@bazel_federation//:repositories.bzl", "{project}")

{project}()

load("@{project}//:{internal_deps_file}", "{project}_{internal_deps_function_suffix}")

{project}_{internal_deps_function_suffix}()
""" % LOCAL_FEDERATION_TEMPLATE
# TODO(fweikert): toolchain function?

LOAD_REGEX = re.compile(r'^(load\(")([^@]{2})')


def create_new_workspace(project_name, internal_deps_file, internal_deps_function_suffix):
    return WORKSPACE_TEMPLATE.format(
        project=project_name,
        internal_deps_file=internal_deps_file,
        internal_deps_function_suffix=internal_deps_function_suffix,
    )


def transform_existing_workspace(project_name, workspace_url):
    template = get_remote_file_contents(workspace_url)
    lines = template.split("\n")

    lines = rewrite_deps_function(project_name, lines)
    # TODO: rewrite workspace name
    lines = fix_repository_in_load_statements(project_name, lines)
    lines = replace_federation_repo(lines)
    return "\n".join(lines)


def get_remote_file_contents(http_url):
    with urllib.request.urlopen(http_url) as resp:
        reader = codecs.getreader("utf-8")
        return reader(resp).read()


def rewrite_deps_function(project_name, lines):
    # Replaces FOO_deps with FOO. We need the entire project repo, not just its dependencies.
    # In theory we could always use FOO in the original workspace file if the maybe() macro
    # realizes that it does not have to import repository FOO if the current workspace has the name FOO.
    # However, I haven't tested that yet.
    pattern = re.compile(r"\b%s_deps\b" % project_name)
    return [pattern.sub(project_name, l) for l in lines]


def fix_repository_in_load_statements(project_name, lines):
    # Prefix internal deps bzl file target with @project_name
    sub_func = create_load_sub_func(project_name)
    return [LOAD_REGEX.sub(sub_func, l) for l in lines]


def create_load_sub_func(project_name):

    def modify_load_statement(match):
        load = match.group(1)
        text = match.group(2)
        prefix = "" if text.startswith("//") else "//"
        return "%s@%s%s%s" % (load, project_name, prefix, text)

    return modify_load_statement


def replace_federation_repo(lines):
    # TODO(fweikert): replace this very basic algorithm that fails
    # 1. If bazel-federation is not a git_repository
    # 2. If there are multiple git repositories in the file
    # 3. If the file isn't formatted properly
    start = find_repo_start(lines)
    end = find_repo_end(lines, start)
    if start is None or end is None:
        raise Exception("TODO: improve this algorithm since start=%s, end=%s", start, end)

    return lines[:start] + [LOCAL_FEDERATION_TEMPLATE] + lines[end+1:]


def find_repo_start(lines):
    for pos, line in enumerate(lines):
        if line.startswith("git_repository"):
            return pos


def find_repo_end(lines, start_pos):
    for offset, line in enumerate(lines[start_pos:]):
        if line.startswith(")"):
            return start_pos + offset
    

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
    parser.add_argument("--internal_deps_file", type=str, default="internal_deps.bzl")
    parser.add_argument("--internal_deps_function_suffix", type=str, default="internal_deps")
    parser.add_argument("--workspace_url", type=str, help="URL of the WORKSPACE file that should be used as template.")

    args = parser.parse_args(argv)

    try:
        if args.workspace_url:
            content = transform_existing_workspace(args.project, args.workspace_url)
        else:
            content = create_new_workspace(
                args.project, args.internal_deps_file, args.internal_deps_function_suffix
            )

        set_up_project(args.project, content)
    except Exception as ex:
        utils.eprint(ex)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
