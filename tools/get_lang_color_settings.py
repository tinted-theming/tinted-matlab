import argparse

import json

from readAllSettings import get_settings_tree

def parse_args():
    parser = argparse.ArgumentParser(
        description="Read all settings from a Matlab mlsettings file."
    )
    parser.add_argument(
        "settings_file",
        help="Path to the zipped settings file containing the settings tree.",
    )
    return parser.parse_args()

def main():
    args = parse_args()

    tree = get_settings_tree(args.settings_file)

    for lang, sgroup in tree["matlab"]["editor"]["language"].items():
        print(lang)
        
        for setting in sgroup["settings"]:
            if setting["name"] == "SyntaxHighlightingColors":
                shl_colors_json = setting["value"]

        # replace escaped quotes
        shl_colors_json = shl_colors_json.replace('\\"', '"')

        # Remove leading and trailing quotes
        if len(shl_colors_json) >= 2:
            shl_colors_json = shl_colors_json[1:-1]
        if shl_colors_json == "":
            shl_colors_json = "{}"

        shl_colors_decoded = json.loads(shl_colors_json.replace('\\"', '"'))
        print(json.dumps(shl_colors_decoded, indent=2, sort_keys=True))
        print("")
        

if __name__ == "__main__":
    main()