import json

import sys

fname = sys.argv[1]

with open(fname, 'rt') as f:
    scheme = json.load(f)

for langname, langsettings in scheme["matlab"]["editor"]["language"].items():
    print(f"plangs_dictionaries(\"{langname}\") = dictionary( ...")

    num_langsettings = len(langsettings)
    for i, setting in enumerate(langsettings):
        if i == num_langsettings - 1:
            comma = ""
        else:
            comma = ","
        setting_quoted = '"' + setting + '"'
        print(f"    {setting_quoted:30s}, \".{langname}.{setting}\"{comma} ...")
    print(");\n")
