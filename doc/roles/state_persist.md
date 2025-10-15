# State Persist Role

This role persists component state changes to fact files for auditability and state tracking.

## Features

- **State Persistence**: Writes component state to fact files
- **Backup Management**: Creates backups of existing state files
- **Metadata Tracking**: Records timestamps and transition information
- **Validation**: Verifies persisted state is correct
- **Cleanup**: Manages old backup files

## Usage

### Basic Usage

```yaml
- name: "Persist component state"
  include_role:
    name: state_persist
  vars:
    component: "my_app"
    asset_type: "app"
    new_state: "RUNNING"
```

### With Custom Settings

```yaml
- name: "Persist state with custom settings"
  include_role:
    name: state_persist
  vars:
    component: "database"
    asset_type: "db"
    new_state: "MAINTENANCE"
    state_fact_file: "/custom/path/state_db.fact"
    backup_retention_days: 30
```

## Variables

### Required Variables

- `component`: Name of the component
- `asset_type`: Type of the component
- `new_state`: New state to persist

### Optional Variables

- `state_fact_file`: Path to state fact file (default: auto-generated)
- `backup_retention_days`: Number of days to keep backups (default: 30)
- `skip_persist`: Skip persistence (default: false)

## Tags

- `state_persist`: State persistence operations
- `state_persistence`: State persistence
- `transient_state_set`: Setting transient states
- `final_state_completion`: Final state completion

## Examples

### Persist Final State

```yaml
- name: "Persist RUNNING state"
  include_role:
    name: state_persist
  vars:
    component: "web_server"
    asset_type: "app"
    new_state: "RUNNING"
```

### Persist Transient State

```yaml
- name: "Set transient STARTING state"
  include_role:
    name: state_persist
  vars:
    component: "web_server"
    asset_type: "app"
    new_state: "STARTING"
```

## Output Variables

The role sets the following variables:

- `persistence_success`: Whether persistence was successful
- `persistence_timestamp`: When the state was persisted
- `previous_state`: Previous state before change
- `state_fact_file_path`: Path to the state fact file
- `backup_file_path`: Path to the backup file created

## Fact File Format

The state fact file contains:

```yaml
component_state: "RUNNING"
component_state_timestamp: "2025-10-14T09:47:38Z"
component_state_method: "persist"
component_state_valid: true
component_state_metadata:
  previous_state: "STOPPED"
  transition_reason: "manual"
  transition_timestamp: "2025-10-14T09:47:38Z"
```

## Backup Management

- Creates timestamped backups before state changes
- Automatically cleans up old backups based on retention policy
- Preserves backup files in `state/backups/` directory

