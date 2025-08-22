#!/usr/bin/env python3

import ast
import json
import sys
import re

python_obj_string = sys.stdin.read()
python_obj_string = re.sub(r"(datetime.datetime\(.*?\))", r"'\1'", python_obj_string)
dict_obj = ast.literal_eval(python_obj_string)
print(json.dumps(dict_obj))
