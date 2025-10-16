# appteam.transition

Transition logic for application instances in state-driven playbook framework.

## Roles

- `transition_app`: Transition logic for application instances

## Usage

```yaml
- name: Transition app instance
  include_role:
    name: appteam.transition.transition_app
  vars:
    target_state: RUNNING
    current_state: STOPPED
```

## Requirements

- Ansible 2.9+
- Python 3.6+
