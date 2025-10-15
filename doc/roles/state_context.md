# State Context Role

This role detects and reads the current state of a component from various sources including fact files, service status, and process checks.

## Features

- **State Detection**: Reads current component state from fact files
- **Fallback Detection**: Can detect state from service status or process checks
- **State Validation**: Validates detected state against state machine definition
- **Timestamp Tracking**: Records when and how state was detected

## Usage

### Basic Usage

```yaml
- name: "Read component state"
  include_role:
    name: state_context
  vars:
    component_name: "my_app"
    asset_type: "app"
```

### Advanced Usage

```yaml
- name: "Read component state with custom settings"
  include_role:
    name: state_context
  vars:
    component_name: "my_app"
    asset_type: "app"
    state_fact_file: "/custom/path/state_my_app.fact"
    initial_state: "CREATED"
```

## Variables

### Required Variables

- `component_name`: Name of the component to read state for
- `asset_type`: Type of the component

### Optional Variables

- `state_fact_file`: Path to the state fact file (default: auto-generated)
- `initial_state`: Initial state if no state is detected (default: "CREATED")
- `custom_detector_script`: Path to custom state detector script

## Tags

- `state_context`: State context operations
- `state_reading`: State reading operations
- `state_info`: State information display

## Examples

### Read Current State

```yaml
- name: "Get current state of web server"
  include_role:
    name: state_context
  vars:
    component_name: "web_server"
    asset_type: "app"
```

### Custom State Detection

```yaml
- name: "Read state with custom detector"
  include_role:
    name: state_context
  vars:
    component_name: "database"
    asset_type: "db"
    custom_detector_script: "/scripts/db_state_detector.sh"
```

## Output Variables

The role sets the following variables:

- `component_state`: Current state of the component
- `component_state_timestamp`: When the state was detected
- `component_state_method`: How the state was detected
- `component_state_valid`: Whether the state is valid
- `current_state`: Alias for component_state

