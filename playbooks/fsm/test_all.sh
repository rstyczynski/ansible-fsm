#!/bin/bash

# Source the test helper framework
source "$(dirname "$0")/../../bin/test_helper.sh"

echo "app1: Remove state"
mv ../../state/state_app1.fact ../../state/state_app1.fact.bak
mv ../../state/state_node1.fact ../../state/state_node1.fact.bak

# Run tests
run_test "Start app1" "ansible-playbook change_state.yml -e component_name=app1 -e state=RUNNING"
run_test "Start node1" "ansible-playbook change_state.yml -e component_name=node1 -e state=RUNNING"

run_test "Stop node1" "ansible-playbook change_state.yml -e component_name=node1 -e state=STOPPED"
run_test "Stop app1" "ansible-playbook change_state.yml -e component_name=app1 -e state=STOPPED"

run_test "Bulk start components" "ansible-playbook change_state_bulk.yml -e components='app1,node1' -e state=RUNNING"
run_test "Bulk stop components" "ansible-playbook change_state_bulk.yml -e components='app1,node1' -e state=STOPPED"

run_test "Stop node1 (direct)" "ansible-playbook node1_stop.yml"
run_test "Start node1 (direct)" "ansible-playbook node1_start.yml"

ansible-playbook get_component_state.yml -e component_name=node1 
ansible-playbook get_component_state.yml -e component_name=app1

mv ../../state/state_app1.fact.bak ../../state/state_app1.fact
mv ../../state/state_node1.fact.bak ../../state/state_node1.fact
