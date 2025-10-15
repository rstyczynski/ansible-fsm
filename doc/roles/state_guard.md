# State Guard Role

This role validates state transitions according to the state machine rules and custom guard conditions.

## Features

- **Transition Validation**: Validates transitions against state machine rules
- **Custom Guard Conditions**: Supports custom guard conditions for complex validation
- **Self-Transition Handling**: Handles transitions to the same state
- **Transient State Support**: Validates transitions involving transient states

## Usage

### Basic Usage

```yaml
- name: "Validate transition"
  include_role:
    name: state_guard
  vars:
    component: "my_app"
    asset_type: "app"
    current_state: "STOPPED"
    target_state: "RUNNING"
```

### With Custom Guard Conditions

```yaml
- name: "Validate transition with custom guards"
  include_role:
    name: state_guard
  vars:
    component: "my_app"
    asset_type: "app"
    current_state: "RUNNING"
    target_state: "MAINTENANCE"
    custom_guard_conditions:
      - "check_maintenance_window"
      - "verify_dependencies"
```

## Variables

### Required Variables

- `component`: Name of the component
- `asset_type`: Type of the component
- `current_state`: Current state of the component
- `target_state`: Target state for the transition

### Optional Variables

- `custom_guard_conditions`: List of custom guard conditions to check
- `skip_guard`: Skip guard validation (default: false)

## Tags

- `state_guard`: State guard operations
- `transition_validation`: Transition validation
- `guard_conditions`: Custom guard conditions

## Examples

### Validate Simple Transition

```yaml
- name: "Validate STOPPED to RUNNING transition"
  include_role:
    name: state_guard
  vars:
    component: "web_server"
    asset_type: "app"
    current_state: "STOPPED"
    target_state: "RUNNING"
```

### Validate with Custom Guards

```yaml
- name: "Validate maintenance transition"
  include_role:
    name: state_guard
  vars:
    component: "database"
    asset_type: "db"
    current_state: "RUNNING"
    target_state: "MAINTENANCE"
    custom_guard_conditions:
      - "check_backup_completion"
      - "verify_standby_ready"
```

## Output Variables

The role sets the following variables:

- `guard_validation_success`: Whether guard validation passed
- `guard_validation_message`: Message describing validation result
- `allowed_transitions`: List of allowed transitions from current state
- `guard_conditions_checked`: List of guard conditions that were checked

## Custom Guard Conditions

Custom guard conditions are defined in `tasks/custom_guard_conditions.yml` and can include:

- Service availability checks
- Resource availability checks
- Dependency checks
- Time-based conditions
- Custom business logic

