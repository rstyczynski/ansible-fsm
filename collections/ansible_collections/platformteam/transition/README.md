# Platform Team Transition Collection

This collection contains transition roles for the state-driven playbook framework.

## Roles

- `transition_node`: Handles node instance transitions in state machines

## Usage

```yaml
- name: Transition node
  include_role:
    name: platformteam.transition.transition_node
    vars:
      target_state: RUNNING
      current_state: STOPPED
```

## Requirements

- Ansible >= 2.9
- State-driven playbook framework dependencies
