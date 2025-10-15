#!/bin/bash

set -e

ansible-playbook change_state.yml -e component_name="app1" -e state=RUNNING
ansible-playbook change_state.yml -e component_name="node1" -e state=RUNNING

ansible-playbook change_state.yml -e component_name="node1" -e state=STOPPED
ansible-playbook change_state.yml -e component_name="app1" -e state=STOPPED

ansible-playbook change_state_bulk.yml -e components="app1,node1" -e state=RUNNING
ansible-playbook change_state_bulk.yml -e components="app1,node1" -e state=STOPPED

ansible-playbook node1_stop.yml
ansible-playbook node1_start.yml

