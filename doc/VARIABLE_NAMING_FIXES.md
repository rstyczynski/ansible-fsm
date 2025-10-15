# Variable Naming Consistency Fixes

## Overview

Fixed inconsistent variable naming throughout the codebase to use consistent terminology:

- `target_transition` → `target_state`
- `transition` → `state` (command line parameter)

## Changes Made

### 1. Playbook Changes

**File**: `change_component_state.yml`
- Changed `target_transition: "{{ transition | default('') }}"` to `target_state: "{{ state | default('') }}"`

### 2. Role Changes

**File**: `roles/state_change/tasks/main.yml`
- Updated all references from `target_transition` to `target_state`
- Updated all references from `transition` to `state` in when conditions
- Updated debug messages to show "Target State" instead of "Transition"
- Updated validation messages to refer to "state" instead of "transition"

### 3. Documentation Changes

**Files Updated**:
- `README.md` - Updated usage examples
- `doc/README.md` - Updated usage examples  
- `doc/roles/state_change.md` - Recreated with correct content and variable names

## New Usage

### Command Line Usage

```bash
# Old usage (deprecated)
ansible-playbook change_component_state.yml -e component=app_instance_5 -e transition=RUNNING

# New usage (correct)
ansible-playbook change_component_state.yml -e component=app_instance_5 -e state=RUNNING
```

### Role Usage

```yaml
# Old usage (deprecated)
- include_role:
    name: state_change
  vars:
    component_name: "my_app"
    target_transition: "RUNNING"

# New usage (correct)
- include_role:
    name: state_change
  vars:
    component_name: "my_app"
    target_state: "RUNNING"
```

## Benefits

1. **Consistency**: All variables now use consistent naming (`target_state` vs `current_state`)
2. **Clarity**: `state` is clearer than `transition` for the command line parameter
3. **Maintainability**: Easier to understand and maintain with consistent naming
4. **Documentation**: All documentation now reflects the correct variable names

## Testing

The changes have been tested and verified:

- ✅ Playbook runs successfully with new parameter names
- ✅ All role tasks execute correctly
- ✅ State transitions work as expected
- ✅ No linting errors introduced

## Migration

To migrate existing scripts or documentation:

1. Replace `-e transition=` with `-e state=`
2. Replace `target_transition:` with `target_state:`
3. Update any custom playbooks or roles that reference these variables
