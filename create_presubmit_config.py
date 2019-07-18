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
import re
import sys
import urllib.request
import utils
import yaml

# TODO(fweikert): keep this list in sync with PLATFORMS in https://github.com/bazelbuild/continuous-integration/blob/master/buildkite/bazelci.py
# (or find a better solution)
PYTHON_VERSIONS = {
    "debian10":         "python3.7",
    "macos":  "python3.7",
    "windows":  "python.exe",
}

DEFAULT_PYTHON_VERSION = "python3.6"

PROJECT_REGEX = re.compile(r"bazelbuild/([^/]+)/")


class Error(Exception):
    """Base error class for this module.

    Currently it doesn't offer anything substantial, though.
    """


# Copied from https://github.com/bazelbuild/continuous-integration/blob/master/buildkite/bazelci.py
# TODO(fweikert): find a way to reuse the module easily
def str_presenter(dumper, data):
    if len(data.splitlines()) > 1:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")

    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


def get_project_name_from_url(config_url):
    match = PROJECT_REGEX.search(config_url)
    if not match:
        raise Error("Config URL '%s' does not point to a file in the bazelbuild GitHub organisation." % config_url)
    return match.group(1)


def load_config(http_url):
    with urllib.request.urlopen(http_url) as resp:
        reader = codecs.getreader("utf-8")
        return yaml.safe_load(reader(resp))


def transform_config(project_name, config):
    tasks = config.get("tasks") or config.get("platforms")
    for name, task_config in tasks.items():
        task_config["setup"] = ['%s create_project_workspace.py --project=%s' % (get_python_version_for_task(name, task_config), project_name)]
        for field in ("run_targets", "build_targets", "test_targets"):
            if field in task_config:
                task_config[field] = transform_all_targets(project_name, task_config[field])

    return config


def get_python_version_for_task(name, task_config):
    platform = task_config.get("platform", name)
    return PYTHON_VERSIONS.get(platform, DEFAULT_PYTHON_VERSION)


def transform_all_targets(project_name, targets):
    return [transform_target(project_name, t) for t in targets]


def transform_target(project_name, target):
    if target == "--" or target.startswith("@"):
        return target
    
    exclusion_prefix = ""
    if target.startswith("-"):
        exclusion_prefix = "-"
        target = target[1:]

    slashes = "" if target.startswith("//") else "//"
    return "{}@{}{}{}".format(exclusion_prefix, project_name, slashes, target)


def write_config(project_name, config):
    path = "%s.yml" % project_name
    with open(path, "w") as f:
        f.write(yaml.dump(config))


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    yaml.add_representer(str, str_presenter)

    parser = argparse.ArgumentParser(description="Bazel Federation CI Configuration Generation Script")
    parser.add_argument("--config_url", type=str, required=True)
    parser.add_argument("--project", type=str, help="Name of the project that should be used as remote repository prefix in the new config. This flag can be omitted if --config_url points to a file in the bazelbuild GitHub organisation and if the repository name of that config file should be used as project name.")

    args = parser.parse_args(argv)

    try:
        project_name = args.project or get_project_name_from_url(args.config_url)
        config = transform_config(project_name, load_config(args.config_url))
        write_config(project_name, config)
    except Exception as ex:
        utils.eprint(ex)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())





