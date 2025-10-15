# State Transient Role

This role handles automatic transient state mapping for state transitions, managing intermediate states during transitions.

## Features

- **Transient State Mapping**: Automatically maps final states to transient states
- **State Transition Logic**: Handles complex transition scenarios
- **Self-Transition Handling**: Manages transitions from transient to different final states
- **Timeout Management**: Supports timeout configuration for transient states

## Usage

### Basic Usage

```yaml
- name: "Handle transient state mapping"
  include_role:
    name: state_transient
  vars:
    component: "my_app"
    asset_type: "app"
    current_state: "STOPPED"
    target_state: "RUNNING"
```

### With Custom Mapping

```yaml
- name: "Handle custom transient mapping"
  include_role:
    name: state_transient
  vars:
    component: "database"
    asset_type: "db"
    current_state: "RUNNING"
    target_state: "MAINTENANCE"
    transient_mappings:
      MAINTENANCE:
        transient_state: "PREPARING_MAINTENANCE"
        success_state: "MAINTENANCE"
        failure_state: "RUNNING"
        timeout: 600
```

## Variables

### Required Variables

- `component`: Name of the component
- `asset_type`: Type of the component
- `current_state`: Current state of the component
- `target_state`: Target state for the transition

### Optional Variables

- `transient_mappings`: Custom transient state mappings
- `skip_transient_mapping`: Skip transient mapping (default: false)

## Tags

- `state_transient`: Transient state operations
- `transient_handling`: Transient state handling
- `transient_info`: Transient state information

## Examples

### Handle Standard Transition

```yaml
- name: "Handle STOPPED to RUNNING transition"
  include_role:
    name: state_transient
  vars:
    component: "web_server"
    asset_type: "app"
    current_state: "STOPPED"
    target_state: "RUNNING"
```

### Handle Transient to Different State

```yaml
- name: "Handle STARTING to STOPPED transition"
  include_role:
    name: state_transient
  vars:
    component: "web_server"
    asset_type: "app"
    current_state: "STARTING"
    target_state: "STOPPED"
```

## Output Variables

The role sets the following variables:

- `actual_target_state`: The actual state to transition to (may be transient)
- `transient_state`: The transient state if applicable
- `transient_success_state`: Success state for transient transition
- `transient_failure_state`: Failure state for transient transition
- `transient_timeout`: Timeout for transient state
- `skip_transient_mapping`: Whether transient mapping was skipped
- `transient_handling_success`: Whether transient handling was successful

## Transient State Logic

The role handles several scenarios:

1. **Standard Transition**: Maps final state to transient state if mapping exists
2. **Transient to Different State**: Handles transitions from transient states
3. **Self-Transition**: Handles transitions to the same state
4. **No Mapping**: Direct transition when no transient mapping exists

## State Machine Integration

The role integrates with the state machine configuration:

```yaml
transient_mappings:
  RUNNING:
    transient_state: "STARTING"
    success_state: "RUNNING"
    failure_state: "STOPPED"
    timeout: 300
  STOPPED:
    transient_state: "STOPPING"
    success_state: "STOPPED"
    failure_state: "RUNNING"
    timeout: 300
```

