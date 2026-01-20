from readAllSettings import get_settings_tree

import json

import tempfile

import argparse

from pathlib import Path

import os

import sys

import subprocess


def parse_args():
    parser = argparse.ArgumentParser(description="Interactively diff matlab settings")
    parser.add_argument(
        "-R",
        "--release",
        help="Specify MATLAB release, otherwise latest installed release is used",
    )
    return parser.parse_args()


def get_settings_file(release: str):
    # For windows only...
    mathworks_user_data_dir = Path(os.environ["AppData"]) / "MathWorks" / "MATLAB"
    if not (mathworks_user_data_dir.exists() and mathworks_user_data_dir.is_dir()):
        print(f"No MATLAB user data found at '{mathworks_user_data_dir}'")
        sys.exit(1)

    if release:
        release_user_data_dir = mathworks_user_data_dir / release.upper()
        if not (release_user_data_dir.exists() and release_user_data_dir.is_dir()):
            print(
                f"ERROR: Release user data folder not found at '{release_user_data_dir}'"
            )
            sys.exit(1)
    else:
        all_release_dirs = [d for d in mathworks_user_data_dir.iterdir() if d.is_dir()]
        if len(all_release_dirs) < 1:
            print(f"No MATLAB user data found at '{mathworks_user_data_dir}'")
            sys.exit(1)
        all_release_dirs.sort()
        release_user_data_dir = all_release_dirs[-1]

    settings_file = release_user_data_dir / "matlab.mlsettings"
    return settings_file


def _write_temp_files(settings_file, tmp1, tmp2):
    json.dump(get_settings_tree(settings_file), tmp1, indent=2, sort_keys=True)
    tmp1.flush()
    input("Change a setting in MATLAB then press enter...")
    json.dump(get_settings_tree(settings_file), tmp2, indent=2, sort_keys=True)
    tmp2.flush()


def main():
    args = parse_args()

    settings_file = get_settings_file(args.release)
    print(f"Using settings file: {settings_file}")

    tmp1 = tempfile.NamedTemporaryFile("wt")
    tmp2 = tempfile.NamedTemporaryFile("wt")
    try:
        _write_temp_files(settings_file, tmp1, tmp2)
        subprocess.run(["delta", tmp1.name, tmp2.name])
    finally:
        tmp1.close()
        tmp2.close()


if __name__ == "__main__":
    main()
