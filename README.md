# Ansible Finite State Machine

version 0.1 - concept

This repository implements an Ansible-based finite state machine (FSM) framework for managing the lifecycle and state transitions of infrastructure and application components (like app1 and node1) using a modular, collection-driven approach.

Implementation covers following concepts:

1. FSM orchestrator invokes transition logic

2. State Machine covers transient states that are automatically reached before transition logic and the target state e.g. STARTING before RUNNING

3. Transition logic is owned by asset owning team (separation of concerns).

## Quick Start

The repository includes several bash test scripts in the root directory:

- **`test_smoke.sh`** - Basic smoke test for app1 and node1 components
- **`test_app1.sh`** - Focused test for app1 component with state transition validation (RUNNING, STOPPED, TERMINATED)
- **`test_all.sh`** - Comprehensive test suite for app1 and node1 components with bulk operations

## Run State Transitions

```bash
# Transition app1 to RUNNING state
ansible-playbook change_state.yml \
  -e component_name=app1 \
  -e state=RUNNING

# Transition node1 to STOPPED state
ansible-playbook change_state.yml \
  -e component_name=node1 \
  -e state=STOPPED

# Check current state
ansible-playbook get_component_state.yml \
  -e component_name=app1
```

## Look into Finite State Machine configuration

Edit `group_vars/all/state_machines.yml` to define your components and their state machines. 

## Collections

Ansible collection keeps together logic owned by subject matter experts. Practically each collection is owned by one of a teams interacting with systems via Ansible. The framework includes several Ansible collections organized by team: toolchain, service, app, and platform.

- **`toolchain.fsm`** - State machine framework with roles for state management
- **`platformteam.transition`** - Platform and OS transition roles (used by node1)
- **`appteam.transition`** - Application transition roles (used by app1)
- **`serviceteam.transition`** - Service transition roles

## Configuration Files

Key configuration files in the repository:

- **`inventory.yml`** - Configuration variables
- **`group_vars/all/`** - Configuration variables

- **`state_machines.yml`** - State machine definitions (generic_lifecycle with states: CREATED, STARTING, RUNNING, STOPPING, STOPPED, TERMINATING, TERMINATED, MAINTENANCE, FAILED)
- **`assets.yml`** - Asset definitions (app1, node1)
- **`asset_types.yml`** - Asset type configurations

## Playbooks

- **`change_state.yml`** - Main state change playbook
- **`change_state_bulk.yml`** - Bulk state change operations
- **`get_component_state.yml`** - State query playbook
- **`node1_start.yml`** / **`node1_stop.yml`** - Direct node operations

## Documentation

Disclaimer: docs are AI generated

- **`doc/`** - All documentation.
