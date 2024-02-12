#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import subprocess

DOCUMENTATION = '''
---
module: local_copy
short_description: Copy files locally
description:
    - "This module copies files from the Windows node to another location on the Windows node"
options:
    src:
        description:
            - The source destination to be coppied.
        required: true
    dest:
        description:
            - The destination file path to be coppied.
        required: true
    recursive:
        description:
            - Boolean value based on if the source should be recursively coppied. Defaults to false.
    force:
        description:
            - Boolean value based on if the copy should be forced. This will disregard idempotency rules and will overwrite anything in the destination directory. Defaults to false.
author: Asa Moore
'''

EXAMPLES = '''
- name: Copy directory. Recursively copy and force the copy.
  local_copy:
    src: "C:\path\to\src"
    dest: "C:\path\to\dest"
    recursive: true
    force: true
'''
