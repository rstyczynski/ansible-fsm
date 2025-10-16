# toolchain.fsm

Finite State Machine collection for Ansible state management.

## Roles

- **state_change** - Generic state change orchestrator
- **state_context** - State detection and reading
- **state_guard** - Transition validation
- **state_persist** - State persistence
- **state_transient** - Transient state handling

## Usage

```yaml
- name: Change component state
  hosts: localhost
  roles:
    - toolchain.fsm.state_change
```

## Installation

Add to your `requirements.yml`:

```yaml
collections:
  - name: toolchain.fsm
    source: ./collections/ansible_collections/toolchain/fsm
    type: dir
```

Then install with:
```bash
ansible-galaxy collection install -r requirements.yml
```
