#!/usr/bin/env python3

import ast
import json
import sys

python_obj_string = sys.stdin.read()
dict_obj = ast.literal_eval(python_obj_string)
print(json.dumps(dict_obj))
