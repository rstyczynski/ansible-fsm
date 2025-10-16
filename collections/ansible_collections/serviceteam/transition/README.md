# serviceteam.transition

Transition logic for services in state-driven playbook framework.

## Roles

- `transition_service` - Transition logic for service instances

## Usage

```yaml
- name: Transition service
  include_role:
    name: serviceteam.transition.transition_service
  vars:
    target_state: "RUNNING"
    current_state: "STOPPED"
```
