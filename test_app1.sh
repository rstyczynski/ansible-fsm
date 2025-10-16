#!/bin/bash

# Source the test framework
source ./bin/test_helper.sh

echo "app1: Remove state"
mv ./state/state_app1.fact ./state/state_app1.fact.bak

# Run tests
run_test "app1: Start app1" "ansible-playbook change_state.yml -e component_name=app1 -e state=RUNNING"
run_negative_test "app1: Move to STARTING state (transitive)" "ansible-playbook change_state.yml -e component_name=app1 -e state=STARTING"
run_negative_test "app1: Terminate" "ansible-playbook change_state.yml -e component_name=app1 -e state=TERMINATED"

run_test "app1: Stop" "ansible-playbook change_state.yml -e component_name=app1 -e state=STOPPED"
run_test "app1: Terminate" "ansible-playbook change_state.yml -e component_name=app1 -e state=TERMINATED"
run_negative_test "app1: Start app1" "ansible-playbook change_state.yml -e component_name=app1 -e state=RUNNING"

ansible-playbook get_component_state.yml -e component_name=app1 | awk '/Map State - Display component state from map/,/^$/ {if($0!="") print $0}' | sed '/^$/d'

echo "app1: Restore state"
mv ./state/state_app1.fact.bak ./state/state_app1.fact