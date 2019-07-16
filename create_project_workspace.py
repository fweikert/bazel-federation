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
import base64
import codecs
import datetime
import hashlib
import json
import multiprocessing
import os
import os.path
import random
import re
from shutil import copyfile
import shutil
import stat
import subprocess
import sys
import tempfile
import threading
import time
import urllib.request
import uuid
import yaml
from urllib.request import url2pathname
from urllib.parse import urlparse


WORKSPACE_TEMPLATE = ("""workspace(name = "{project}_federation_example")

local_repository(name = "bazel_federation",
                 path = "..",
)

load("@bazel_federation//:repositories.bzl", "{project}")

{project}()

load("//@{project}:{internal_deps_file}", "{internal_deps_function}")	

{internal_deps_function}()

""")
# TODO(fweikert): toolchain function?


class Error(Exception):
    """
    Raised whenever something goes wrong and we should exit with an error.
    """


def eprint(msg):
    """
    Print to stderr and flush (just in case).
    """
    print(msg, flush=True, file=sys.stderr)


def create_new_workspace(project_name, internal_deps_file, internal_deps_function):
    return WORKSPACE_TEMPLATE.format(project=project_name, internal_deps_file=internal_deps_file, internal_deps_function=internal_deps_function)

def transform_existing_workspace(project_name, src_url):
    # 1. Transform workspace name
    # 2. Replace bazel-federation repo with local_repository
    # 3. Prefix internal deps bzl file target with @project_name
    raise NotImplementedError("soon (tm)")


def get_remote_file_contents(http_url):
    with urllib.request.urlopen(http_url) as resp:
        reader = codecs.getreader("utf-8")
        return reader(resp).read()



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
    parser.add_argument("--internal_deps_function", type=str, default="internal_deps")
    parser.add_argument("--workspace_src_url", type=str)

    args = parser.parse_args(argv)

    try:
        if args.workspace_src_url:
            content = transform_existing_workspace(args.project, args.workspace_src_url)
        else:
            content = create_new_workspace(args.project, args.internal_deps_file, args.internal_deps_function)

        set_up_project(args.project, content)
    except Exception as ex:
        eprint(ex)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
