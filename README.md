# AI Aider - Ansible State-Driven Playbook Framework

This repository implements an automated assistant that generates, maintains, and verifies Ansible playbooks and roles implementing a state-machine-based restart and transition framework for Day-2 operations automation.

## Quick Start

### 1. Install Dependencies

```bash
# Install Ansible collections
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure State Machine

Edit `group_vars/all/state_machines.yml` to define your components and their state machines.

### 3. Run State Transitions

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

## Documentation

All documentation has been moved to the `doc/` directory:

- **[Main Documentation](doc/README.md)** - Complete framework documentation
- **[Quick Start Guide](doc/QUICKSTART.md)** - Getting started guide
- **[Implementation Summary](doc/IMPLEMENTATION_SUMMARY.md)** - Technical implementation details
- **[Refactoring Notes](doc/REFACTORING_NOTES.md)** - Recent refactoring changes
- **[SRS Document](doc/AI_Aider_SRS_v1.5.md)** - Software Requirements Specification

### Role Documentation

- **[state_change](doc/roles/state_change.md)** - Generic state change orchestrator
- **[state_context](doc/roles/state_context.md)** - State detection and reading
- **[state_guard](doc/roles/state_guard.md)** - Transition validation
- **[state_persist](doc/roles/state_persist.md)** - State persistence
- **[state_transient](doc/roles/state_transient.md)** - Transient state handling

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
│  change_component_state.yml                                │
│  ├── Simple playbook interface                             │
│  └── Uses state_change role                                │
└─────────────────────────────────────────────────────────────┘
```

## Files

- `change_component_state.yml` - Simple state change playbook
- `state_transition_playbook.yml.backup` - Original playbook (backup)
- `group_vars/all/` - Configuration files
- `roles/` - Ansible roles
- `doc/` - All documentation

