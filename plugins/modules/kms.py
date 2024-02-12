#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import subprocess

DOCUMENTATION = '''
---
module: kms
short_description: Set KMS on Windows Machine
description:
    - "This module controls and activates KMS on Windows hosts"
options:
    ip:
        description:
            - The ip of the KMS server.
        required: true
    port:
        description:
            - The port of the KMSserver.
        required: true
    sign_windows:
        description:
            - Whether to automatically attempt to sign the Windows node with the KMS server. Uses %windir%\System32\slmgr.vbs. Defaults to False.
    sign_office:
        description:
            - Whether to automatically attempt to sign Office on the Windows node with the KMS server. Uses %windir%\Microsoft Office\Office16\ospp.vbs. Defaults to False.
author: Asa Moore
'''

EXAMPLES = '''
- name: Set KMS server and activate Windows and Office16
  kms:
    ip: "192.168.1.100"
    port: 1688
    sign_windows: true
    sign_office: true
'''
