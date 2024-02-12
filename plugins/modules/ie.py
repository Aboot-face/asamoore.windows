#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import subprocess

DOCUMENTATION = '''
---
module: ie
short_description: Uses Invoke-Expression on the Windows node
description:
    - "This module leverages Invoke-Expression on a Windows node."
options:
    path:
        description:
            - Path to the script to be Invoked.
        required: true
author: Asa Moore
'''

EXAMPLES = '''
- name: Invoke Test.ps1
  ie:
    path: "C:\path\to\test.ps1"
'''
