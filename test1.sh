#!/bin/bash

ansible-playbook change_components_state.yml -e components="app1" -e state=RUNNING
ansible-playbook change_components_state.yml -e components="node1" -e state=RUNNING

ansible-playbook change_components_state.yml -e components="node1" -e state=STOPPED
ansible-playbook change_components_state.yml -e components="app1" -e state=STOPPED

ansible-playbook change_components_state.yml -e components="app1,node1" -e state=RUNNING