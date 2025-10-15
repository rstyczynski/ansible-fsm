# AI Aider - Ansible State-Driven Playbook Framework

This repository implements an automated assistant that generates, maintains, and verifies Ansible playbooks and roles implementing a state-machine-based restart and transition framework for Day-2 operations automation.

## Overview

The AI Aider framework provides:
- **State Machine Definition**: Declarative YAML definition of component states and transitions
- **State Context Role**: Detects current component state from various sources
- **State Guard Role**: Validates legal state transitions with custom guard conditions
- **State Persist Role**: Writes component state to fact files for auditability
- **Transition Playbook**: Orchestrates safe state transitions with proper validation

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    State Machine Framework                  │
├─────────────────────────────────────────────────────────────┤
│  group_vars/all/state_machines.yml                          │
│  ├── Component definitions                                 │
│  ├── State definitions                                     │
│  ├── Transition rules                                      │
│  └── Configuration settings                                │
├─────────────────────────────────────────────────────────────┤
│  Roles                                                      │
│  ├── state_context/     - Detect current state             │
│  ├── state_guard/       - Validate transitions             │
│  ├── state_persist/     - Persist state changes            │
│  ├── state_transient/   - Handle transient states          │
│  └── state_change/      - Generic state change orchestrator│
├─────────────────────────────────────────────────────────────┤
│  state_transition_playbook.yml                             │
│  ├── Pre-tasks: Validation                                │
│  ├── State Context: Detect current state                  │
│  ├── State Guard: Validate transition                     │
│  ├── Transition Execution: Execute state-specific actions  │
│  └── State Persist: Save new state                        │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Install Dependencies

```bash
# Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# Install roles (if using from Galaxy)
ansible-galaxy install -r roles/requirements.yml
```

### 2. Configure State Machine

Edit `group_vars/all/state_machines.yml` to define your components and their state machines.

### 3. Run State Transitions

#### Using the Simple Playbook (Recommended)

```bash
# Transition a component to RUNNING state
ansible-playbook change_component_state.yml \
  -e component=web_server \
  -e state=RUNNING

# Check current state only
ansible-playbook change_component_state.yml \
  -e component=web_server \
  --tags state_context

# Dry run a transition
ansible-playbook change_component_state.yml \
  -e component=web_server \
  -e state=MAINTENANCE \
  -e dry_run=true
```

#### Using the Original Playbook (Legacy)

The original `state_transition_playbook.yml` is available as a backup (`state_transition_playbook.yml.backup`).

```bash
# Legacy usage
ansible-playbook state_transition_playbook.yml \
  -e component=web_server \
  -e state=RUNNING
```

## State Machine Definition

### Component States

The framework supports the following standard states:

- **CREATED**: Resource has been created but not started
- **STARTING**: Resource is being initialized
- **RUNNING**: Resource is operational and healthy
- **STOPPING**: Resource is being shut down gracefully
- **STOPPED**: Resource is stopped but can be restarted
- **TERMINATING**: Resource is being permanently removed
- **TERMINATED**: Resource has been permanently removed
- **MAINTENANCE**: Resource is in maintenance mode
- **FAILED**: Resource is in an error state

### State Transitions

```
CREATED → STARTING → RUNNING → STOPPING → STOPPED → TERMINATING → TERMINATED
                │          │         ▲
                ▼          │         │
           MAINTENANCE <───┘         │
                │                    │
                └────────────────────┘

* → FAILED  (from any state)
```

## Usage Examples

### Basic State Transition

```yaml
# Transition VM from CREATED to RUNNING
ansible-playbook state_transition_playbook.yml \
  -e component=vm \
  -e transition=RUNNING \
  -i production
```

### Tag-Based Execution

```yaml
# Execute only state detection
ansible-playbook state_transition_playbook.yml \
  --tags state_context \
  -i production

# Execute specific transition
ansible-playbook state_transition_playbook.yml \
  --tags transition_to_RUNNING \
  -i production
```

### Component-Specific Configuration

```yaml
# Define component-specific variables
ansible-playbook state_transition_playbook.yml \
  -e component=web_server \
  -e transition=RUNNING \
  -e component_services="['nginx', 'php-fpm']" \
  -e component_ports="[80, 443]" \
  -i production
```

## Role Documentation

### state_context Role

Detects and reads the current state of a component.

**Usage:**
```yaml
- name: Detect current state
  include_role:
    name: state_context
  vars:
    component: "my_component"
```

**Key Variables:**
- `component`: Name of the component
- `state_detection_methods`: Methods for state detection
- `custom_detector_script`: Path to custom detection script

### state_guard Role

Validates that a state transition is legal according to the state machine.

**Usage:**
```yaml
- name: Validate transition
  include_role:
    name: state_guard
  vars:
    component: "my_component"
    current_state: "{{ component_state }}"
    target_transition: "{{ transition }}"
```

**Key Variables:**
- `component`: Name of the component
- `current_state`: Current state of the component
- `target_transition`: Desired target state
- `custom_guard_conditions`: Custom validation conditions

### state_persist Role

Persists component state to fact files for auditability.

**Usage:**
```yaml
- name: Persist new state
  include_role:
    name: state_persist
  vars:
    component: "my_component"
    new_state: "{{ target_transition }}"
```

**Key Variables:**
- `component`: Name of the component
- `new_state`: New state to persist
- `backup_enabled`: Enable backup of previous state

## Advanced Configuration

### Custom State Detection

Create custom detection scripts in the `detectors/` directory:

```bash
#!/bin/bash
# detectors/web_server_state_detector.sh

if systemctl is-active --quiet nginx; then
    echo "RUNNING"
elif systemctl is-failed --quiet nginx; then
    echo "FAILED"
else
    echo "STOPPED"
fi
```

### Custom Guard Conditions

Define custom validation logic in your playbook:

```yaml
- name: Validate transition with custom conditions
  include_role:
    name: state_guard
  vars:
    component: "database"
    current_state: "{{ component_state }}"
    target_transition: "MAINTENANCE"
    custom_guard_conditions:
      - "maintenance_window_check"
      - "dependency_check"
    component_maintenance_window:
      start: 2
      end: 4
    component_dependencies:
      - "backup_service"
      - "monitoring_service"
```

## Best Practices

### 1. State Machine Design

- Keep state machines simple and focused
- Use descriptive state names
- Define clear transition rules
- Include failure states and recovery paths

### 2. Component Configuration

- Define component-specific variables clearly
- Use consistent naming conventions
- Document component dependencies
- Include maintenance windows and constraints

### 3. Execution Strategy

- Always validate transitions before execution
- Use dry-run mode for testing
- Implement proper error handling
- Maintain audit trails

### 4. Monitoring and Alerting

- Monitor state fact files for changes
- Set up alerts for unexpected state transitions
- Track transition history and timing
- Implement health checks for each state

## Troubleshooting

### Common Issues

1. **State Detection Fails**
   - Check fact file permissions
   - Verify custom detector scripts
   - Review service status

2. **Transition Validation Fails**
   - Check state machine definition
   - Verify current state is valid
   - Review custom guard conditions

3. **State Persistence Fails**
   - Check fact file directory permissions
   - Verify backup directory exists
   - Review disk space

### Debug Mode

Enable debug output for troubleshooting:

```bash
ansible-playbook state_transition_playbook.yml \
  -e component=web_server \
  -e transition=RUNNING \
  -vvv \
  -i inventory
```

## Contributing

1. Follow Ansible best practices
2. Add comprehensive tests
3. Update documentation
4. Ensure linting passes

## License

MIT License - see LICENSE file for details.
