#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import subprocess

DOCUMENTATION = '''
---
module: change_ip
short_description: Change the IP address of a Windows machine
description:
    - "This module changes the IP address and subnet mask of a specified network adapter on a Windows machine."
options:
    adapter_name:
        description:
            - The name of the network adapter to modify.
        required: true
    ip_address:
        description:
            - The new IP address to assign to the adapter.
        required: true
    subnet_mask:
        description:
            - The new subnet mask to assign to the adapter.
        required: true
    gateway:
        description:
            - Configures that default gateway for the node.
        required: true
    dns_servers:
        description:
            - List of DNS servers to add to the node.
        required: true
author: Asa Moore
'''

EXAMPLES = '''
- name: Change IP address of a Windows machine
  change_ip:
    adapter_name: "Ethernet 1"
    ip_address: "{{ new_ip_address }}"
    subnet_mask: "{{ new_subnet_mask }}"
    gateway: "{{ new_gateway }}"
    dns_servers:
      - 1.1.1.1
      - 1.1.0.0
  async: 100
  poll: 0

- name: Wait for the node network interface to come back up
  local_action:
    module: wait_for
    host: "{{ new_ip_address }}"
    port: 5985
    delay: 10
    state: started
  register: wait_result

- name: Add host with new IP address to in-memory inventory
  add_host:
    name: "{{ inventory_hostname }}"
    ansible_host: "{{ new_ip_address }}"
    groups: "dynamic_hosts"
'''

RETURN = '''
original_ip:
    description: The original IP address before the change.
    type: str
changed_ip:
    description: The new IP address after the change.
    type: str
'''
