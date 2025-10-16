#!/bin/bash

# Source the test helper framework
source "$(dirname "$0")/../../bin/test_helper.sh"

echo "app1: Remove state"
mv ../../state/state_app1.fact ../../state/state_app1.fact.bak

# Run tests
run_test "app1: Start app1" "ansible-playbook change_state.yml -e component_name=app1 -e state=RUNNING"
run_test "node1: Start node1" "ansible-playbook change_state.yml -e component_name=node1 -e state=RUNNING"

echo "app1: Restore state"
mv ../../state/state_app1.fact.bak ../../state/state_app1.fact