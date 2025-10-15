# State Change Role

This role implements state-driven transitions for components using the state machine framework. It provides a generic interface for changing component states while maintaining state consistency and validation.

## Features

- **State Context Reading**: Reads current component state from fact files
- **State Transient Handling**: Manages automatic transient state mapping
- **State Guard Validation**: Validates transitions according to state machine rules
- **State Persistence**: Persists state changes to fact files
- **Dynamic Role Execution**: Executes component-specific transition roles
- **Comprehensive Validation**: Validates component types, roles, and transitions

## Usage

### Basic Usage

```yaml
- name: "Change component state"
  include_role:
    name: state_change
  vars:
    component_name: "my_app"
    target_state: "RUNNING"
```

### Advanced Usage

```yaml
- name: "Change component state with custom parameters"
  include_role:
    name: state_change
  vars:
    component_name: "my_app"
    target_state: "STOPPED"
    skip_guard: false
    skip_persist: false
    dry_run: true
```

## Variables

### Required Variables

- `component_name`: Name of the component to transition
- `target_state`: Target state for the transition

### Optional Variables

- `skip_guard`: Skip state guard validation (default: false)
- `skip_persist`: Skip state persistence (default: false)
- `dry_run`: Execute in dry-run mode (default: false)
- `asset_type`: Override component type detection
- `transition_role_timeout`: Timeout for transition role execution (default: 300)

## Dependencies

This role depends on the following roles:

- `state_context`: For reading current state
- `state_transient`: For handling transient states
- `state_guard`: For transition validation
- `state_persist`: For state persistence

## Tags

- `state_context`: State context operations
- `state_transient`: Transient state handling
- `state_guard`: State guard validation
- `state_persist`: State persistence operations
- `transition_execution`: Transition role execution

## Examples

### Transition to Running State

```yaml
- name: "Start application"
  include_role:
    name: state_change
  vars:
    component_name: "web_app"
    target_state: "RUNNING"
```

### Transition to Stopped State

```yaml
- name: "Stop application"
  include_role:
    name: state_change
  vars:
    component_name: "web_app"
    target_state: "STOPPED"
```

### Dry Run Mode

```yaml
- name: "Validate transition without execution"
  include_role:
    name: state_change
  vars:
    component_name: "web_app"
    target_state: "RUNNING"
    dry_run: true
```

## Execution Flow

1. **Initialize Variables**: Set up component and state machine variables
2. **Validate Input**: Validate component type and target state
3. **Read Current State**: Use state_context role to get current state
4. **Handle Transient States**: Use state_transient role for transient mapping
5. **Validate Transition**: Use state_guard role to validate the transition
6. **Set Transient State**: Use state_persist role to set transient state if needed
7. **Execute Transition**: Call component-specific transition role
8. **Complete Transition**: Use state_persist role to set final state
9. **Display Results**: Show final state and execution status