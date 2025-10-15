# State Transition Playbook Refactoring

## Overview

The original `state_transition_playbook.yml` has been refactored into a reusable `state_change` role with a simplified playbook wrapper.

## Changes Made

### 1. Created `state_change` Role

**Location**: `roles/state_change/`

**Structure**:
```
roles/state_change/
├── defaults/
│   └── main.yml       # Default variables (skip_guard, skip_persist, dry_run)
├── meta/
│   └── main.yml       # Role metadata (no dependencies)
├── tasks/
│   └── main.yml       # All state transition logic
└── README.md          # Role documentation
```

**Key Features**:
- Initializes all computed variables from component definitions
- Validates component types and transitions
- Coordinates state_context, state_transient, state_guard, and state_persist roles
- Handles transient state mapping
- Executes component-specific transition actions

### 2. Created Simplified Playbook

**File**: `change_component_state.yml`

**Purpose**: Provides a simple interface to the state_change role

**Usage**:
```bash
# Basic transition
ansible-playbook change_component_state.yml -e component=app_instance_5 -e transition=RUNNING

# With tags
ansible-playbook change_component_state.yml --tags state_context
ansible-playbook change_component_state.yml --tags transition_to_RUNNING

# With options
ansible-playbook change_component_state.yml -e component=app_instance_5 -e transition=STOPPED -e dry_run=true
```

### 3. Preserved Original Playbook

**File**: `state_transition_playbook.yml.backup`

The original playbook has been backed up for reference.

## Key Technical Decisions

### Variable Initialization

The `state_change` role initializes all computed variables using `set_fact` tasks with the `always` tag:

1. **Component Variables**: Type, services, processes, ports, dependencies
2. **State Machine Variables**: State machine configuration, component state machine
3. **Transition Variables**: Role name, collection, timeout, full role name

This ensures variables are available to all nested role calls.

### Role Dependencies

Initially, the `state_change` role had dependencies on state_context, state_transient, state_guard, and state_persist in `meta/main.yml`. This caused those roles to execute BEFORE the state_change role's tasks.

**Solution**: Removed role dependencies and use explicit `include_role` calls in the correct order within the tasks.

### Variable Passing

Variables are set at the playbook level in the `vars:` section and are automatically available to the role. The role then sets additional computed variables using `set_fact`.

### Execution Order

The role ensures proper execution order:

1. Initialize computed variables (always runs)
2. Validate component and transition
3. Read current state (state_context)
4. Handle transient state mapping (state_transient)
5. Validate transition (state_guard)
6. Set transient state if needed (state_persist)
7. Execute transition actions (component-specific role)
8. Complete transition to final state (state_persist)
9. Display results

## Benefits

1. **Reusability**: The state_change role can be used in other playbooks
2. **Modularity**: Clear separation between orchestration (role) and invocation (playbook)
3. **Maintainability**: Changes to state transition logic only need to be made in one place
4. **Simplicity**: The playbook is now very simple and easy to understand
5. **Flexibility**: Can be used as a role in more complex playbooks

## Testing

Tested successfully with:
- ✅ Self-transition (STOPPED → STOPPED)
- ✅ State change with transient states (STOPPED → STARTING → RUNNING)
- ✅ All validation and persistence logic
- ✅ Component type resolution
- ✅ Role name resolution

## Migration Notes

To migrate existing playbooks:

1. Replace playbook tasks with:
   ```yaml
   vars:
     component_name: "{{ component | default('resource') }}"
     target_transition: "{{ transition | default('') }}"
   
   roles:
     - role: state_change
   ```

2. Or use the new `change_component_state.yml` playbook directly

## Files Modified

- **Created**: `roles/state_change/` (new role)
- **Created**: `change_component_state.yml` (new simplified playbook)
- **Created**: `state_transition_playbook.yml.backup` (backup of original)
- **Modified**: `roles/state_transient/tasks/main.yml` (reordered tasks for validation)

## Backward Compatibility

The original `state_transition_playbook.yml` is still available as a backup. The new approach maintains all functionality while providing better structure.
