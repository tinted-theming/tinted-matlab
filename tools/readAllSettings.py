"""
Read Matlab settings tree from a .mlsettings file, including hidden settings.

Usage:

    python readAllSettings.py <path to .mlsettings file> [--json]

Options:

    --json: Output in json format. Default output is human friendly "pretty"
    format
"""

import json

import sys

import zipfile

import argparse

from typing import Any


def traverse_settings_tree(root: zipfile.Path) -> dict:
    assert root.is_dir()
    settings: dict[str, Any] = {}
    for child in root.iterdir():
        if child.is_dir():
            assert child.name not in ["settings", "attributes", "path"]
            settings[child.name] = traverse_settings_tree(child)
        elif child.is_file() and child.name == "settings.json":
            with child.open() as f:
                settings.update(json.load(f))
    return settings


def parse_args():
    parser = argparse.ArgumentParser(
        description="Read all settings from a Matlab mlsettings file."
    )
    parser.add_argument(
        "settings_file",
        help="Path to the zipped settings file containing the settings tree.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output the settings in JSON format.",
    )
    return parser.parse_args()


def output_pretty(settings_tree: dict, indent_level: int = 0):
    indent = "  " * indent_level
    for key, value in settings_tree.items():
        print(f"{indent}[{key}]")
        if "settings" in value and "attributes" in value:
            # This is a SettingsGroup node that contains some Settings
            for setting in value["settings"]:
                print(f"{indent * 2}{setting['name']}: {setting['value']}")

        if key not in ["settings", "attributes", "path"]:
            output_pretty(value, indent_level + 1)


def output_json(settings_tree: dict):
    print(json.dumps(settings_tree, indent=2, sort_keys=True))


def main():
    args = parse_args()

    with zipfile.ZipFile(args.settings_file, "r") as z:
        root = zipfile.Path(z, "fsroot/settingstree/")
        if not (root.exists() and root.is_dir()):
            print("No settings tree found in the provided file.", file=sys.stderr)
            sys.exit(1)
        settings_tree = traverse_settings_tree(root)

    if args.json:
        output_json(settings_tree)
    else:
        output_pretty(settings_tree)


if __name__ == "__main__":
    main()
