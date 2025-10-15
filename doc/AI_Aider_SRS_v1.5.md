# Software Requirements Specification (SRS)
## AI Aider for Ansible State-Driven Playbook Development

**Version:** 2.0  
**Date:** 2025-01-27

---

### 1. Purpose
This SRS defines the functional and non-functional requirements for the *AI Aider* — an automated assistant that generates, maintains, and verifies Ansible playbooks and roles implementing a state-machine-based restart and transition framework for Platform as a Service (PaaS) applications. The goal is to standardize Day-2 operations automation for application instances and services with separation of concerns and safe state transitions.

---

### 2. Scope
The AI Aider supports engineers working in a GitOps-based OCI environment using Terraform + Terrateam + Ansible.  
It shall:  
- Produce and update Ansible artifacts (playbooks, roles, group_vars).  
- Ensure consistency with state definitions and transition guards.  
- Generate documentation, comments, and examples conforming to project conventions.  

Excluded: actual deployment or execution of playbooks.

---

### 3. Definitions, Acronyms, Abbreviations

| Term | Definition |
|------|-------------|
| **SRS** | Software Requirements Specification |
| **AI Aider** | The intelligent assistant (this system) |
| **State Machine** | Declarative YAML definition of component states and transitions |
| **State Machine Definition** | Reusable state machine template with states, transitions, and configurations |
| **Component Reference** | Component definition that references a state machine via `state_machine_spec` |
| **Transition Guard** | Validation ensuring transitions occur only from legal states |
| **Persistence Role** | Role writing component state to host facts |
| **Context Role** | Role reading current state from state file |
| **Guard Role** | Role validating allowed "from" states before transition execution |
| **Transition Role** | Component-specific role containing actual transition logic (e.g., `transition_app`) |
| **Resource Class** | Generic component type (e.g., `app`, `database`, `web`) that maps to transition roles |

---

### 4. Overall Description

#### 4.1 System Environment
- GitHub repository containing IaC code.
- CI workflows using Ansible lint and merge checks.
- Managed hosts reachable via SSH.

#### 4.2 User Characteristics
- DevOps engineers and platform SREs familiar with Ansible ≥ 2.15.
- Expected to understand YAML, roles, and Git workflows.

#### 4.3 Constraints
- Must generate idempotent, tag-aware playbooks.
- Must support execution filtering by `--tags`.
- Must avoid proprietary or environment-specific modules.

---

### 5. Specific Requirements

#### 5.1 Functional Requirements

| ID | Requirement | Acceptance Criteria |
|----|--------------|--------------------|
| F-1 | Generate base playbook with all transitions per component. | File includes pre_tasks, transition blocks, role includes. |
| F-2 | Produce role `state_context` to read current state from state file. | Role sets `current_state` fact. |
| F-3 | Produce role `state_guard` validating legal `from` states. | Illegal transition causes fatal assert. |
| F-4 | Produce role `state_persist` writing state facts. | File `/etc/ansible/facts.d/state_<component>.fact` updated. |
| F-5 | Integrate roles via `include_role` (no inline asserts). | No conditional hacks. |
| F-6 | Tag and var selection support. | Executable via tags or `-e transition=`. |
| F-7 | Safety and traceability. | Each transition calls guard and persist roles. |
| F-8 | Support initial_state override. | Defaults applied when no fact found. |
| F-9 | Provide reusable templates for other components. | Parameterized role generation. |
| F-10 | Inline documentation. | Each task has meaningful name/comment. |
| F-11 | Support multiple components using same state machine. | Components reference state machines via `state_machine_spec`. |
| F-12 | Separate state machine definitions from asset definitions. | State machines defined in `group_vars/all/state_machines.yml`, assets in `group_vars/all/assets.yml`. |
| F-13 | Support generic transition roles per resource class. | Transition roles named `transition_<class>` (e.g., `transition_app`) work for all instances of that class. |
| F-14 | Implement component-specific transition logic. | Transition roles contain real service management, health checks, and resource cleanup logic. |
| F-15 | Support component ownership of transition logic. | Each resource class team owns their transition role implementation. |
| F-16 | Support component type classification. | Components must have a `asset_type` field that categorizes them (e.g., `app`, `database`, `web`). |
| F-17 | Dynamic role resolution by component type. | Transition roles are resolved using asset_types configuration mapping instead of hardcoded patterns. |
| F-18 | Component type validation. | System must validate that `asset_type` is defined for all components and resolve to existing transition roles. |
| F-19 | Component type inheritance. | Components inherit their `asset_type` from configuration and pass it to transition roles. |
| F-20 | Asset properties management. | Assets define their properties (services, ports, processes, dependencies, maintenance_window) in `group_vars/all/assets.yml`. |
| F-21 | Map-based state access. | System provides centralized map-based access to component states while maintaining distributed state files for lifecycle management. |
| F-22 | Efficient state querying. | Support for filtering components by state, listing all component states, and efficient lookup by component name. |
| F-23 | Distributed state persistence. | Individual state files remain separate for distributed lifecycle management across different playbook instances. |
| F-24 | Centralized state operations. | Ansible-level map provides efficient programmatic access to all component states within a single playbook run. |

---

### 6. Non-Functional Requirements

| ID | Category | Requirement |
|----|-----------|-------------|
| NF-1 | Maintainability | Code must pass `ansible-lint`. |
| NF-2 | Reusability | Transition roles must be class-agnostic (work for all instances of a resource class). State machines must be reusable across components. |
| NF-3 | Readability | Meaningful task names and YAML clarity. |
| NF-4 | Auditability | State changes must persist to fact files. |
| NF-5 | Idempotence | Re-running has no side effects. |

---

### 6.1 Variable Safety Requirements

**CRITICAL**: Variable safety is a fundamental requirement for the state-driven component management system. See [SRS_VARIABLE_SAFETY.md](./SRS_VARIABLE_SAFETY.md) for detailed requirements on:

- **Variable Isolation (REQ-VS-001)**: All internally computed variables within the `state_change` role MUST be isolated using the `isolated_` prefix to prevent contamination of the global variable scope.
- **Safe Cross-Asset Control (REQ-VS-002)**: The system MUST support safe cross-asset control where one component can control another without variable pollution.
- **Recursion Prevention (REQ-VS-003)**: The system MUST prevent recursion risks when components interact with each other.
- **Dependency Validation Safety (REQ-VS-004)**: Dependency validation MUST work correctly even with variable isolation.

**Implementation Status**: ✅ **IMPLEMENTED** - All variable safety requirements have been implemented and tested.

---

### 7. External Interface Requirements

| Interface | Description |
|------------|-------------|
| CLI | Runs via `ansible-playbook` with `--tags` or `-e transition=`. |
| File I/O | Reads/writes `/etc/ansible/facts.d/state_<component>.fact`. |
| GitHub Workflow | Integrated with CI validation. |

---

### 8. Performance Requirements
- State persistence tasks execute in < 5s per host.
- Playbook completes in < 60s for ≤10 hosts.

---

### 9. Design Constraints and Assumptions
- Python ≥ 3.9, Ansible ≥ 2.15.
- Managed nodes can write to `/etc/ansible/facts.d`.
- Offline-safe; no remote API dependencies.

---

### 10. Verification
- `ansible-playbook --check` succeeds for all transitions.
- Linting via GitHub Actions.
- State fact correctness verified after each run.

---

### 11. Exemplary Design (Informative)

#### 11.1 Hierarchical Resource Composition (ASCII)

```
+------------------------------------------------------+
| component1                                           |
|  State: STARTING                                     |
|                                                      |
|  +----------------------------------------------+    |
|  | resource                                     |    |
|  | State: STARTING                              |    |
|  |                                              |    |
|  |  +---------------------------+               |    |
|  |  | operating system          |  State: AVAILABLE |
|  |  +---------------------------+               |    |
|  |                                              |    |
|  |  +---------------------------+               |    |
|  |  | application instance      |  State: STARTING  |
|  |  +---------------------------+               |    |
|  +----------------------------------------------+    |
+------------------------------------------------------+
```

Notes:
1. operating system resource is accessible via SSH
2. application instance is accessible via platform API

---

#### 11.2 Resource Lifecycle State Machine

```
              ┌──────────────────────────────┐
              ▼                              │
CREATED → STARTING → RUNNING → STOPPING → STOPPED → TERMINATING → TERMINATED
                        │          │         ▲
                        ▼          │         │
                   MAINTENANCE <───┘         │
                        │                    │
                        └────────────────────┘

* → FAILED  (from any state)
```

**Notes (per image):**
- **MAINTENANCE** is reachable only from **RUNNING**.
- From **MAINTENANCE** you may return to **RUNNING** or proceed to **STOPPED**.
- From **STOPPED** you may **restart** to **STARTING**.
- The primary linear flow remains: CREATED → STARTING → RUNNING → STOPPING → STOPPED → TERMINATING → TERMINATED.
- `* → FAILED` from any state.

### 12. Mapping to Ansible Implementation

| Concept | Ansible Artifact | Description |
|----------|------------------|--------------|
| Component | Playbook | Contains all transitions for a managed unit. |
| State Context | Role: `state_context` | Reads current state. |
| Transition Guard | Role: `state_guard` | Validates legal transitions. |
| Persistence | Role: `state_persist` | Writes new state facts. |
| Transition Logic | Role: `transition_<class>` | Component-specific transition implementation (e.g., `transition_app`). |
| State Machine Definition | `group_vars/all/state_machines.yml` | Defines reusable state machine templates in `state_machines` section. |
| Asset Reference | `group_vars/all/assets.yml` | Defines assets that reference state machines via `state_machine_spec` and includes asset properties. |

### 13. Corrected State Transition Workflow

#### 13.1 Proper State Transition Sequence

The state machine framework follows a specific sequence to ensure proper state management:

1. **State Context** - Read current state from fact file
2. **State Transient** - Calculate transient state mappings (e.g., RUNNING → STARTING)
3. **State Guard** - Validate transition is allowed from current state
4. **State Persist (First)** - Set transient state BEFORE operations (e.g., STARTING)
5. **Execute Operations** - Perform actual work with realistic delays
6. **State Persist (Second)** - Complete transition to final state (e.g., RUNNING)

#### 13.2 Key Changes in v1.5

- **Removed `state_auto_complete` role** - This role was performing fake operations and interfering with proper workflow
- **Added realistic delays** - Operations now include configurable delays to simulate real work
- **Corrected state persistence** - Transient states are set BEFORE operations, not after
- **Proper operation execution** - Real work happens in the main playbook with appropriate delays

#### 13.3 Example Transition Flow

When transitioning to `RUNNING`:
1. Set `STARTING` state (transient)
2. Execute start operations with delays
3. Complete transition to `RUNNING` state

### 14. Generic Role Architecture

#### 14.1 Component-Specific Transition Logic

The framework now supports component-specific transition roles that contain real implementation logic:

**Role Naming Convention:**
- `transition_app` - Works for all application instances (`app_instance`, `app_instance_2`, `app_instance_3`, etc.)
- `transition_database` - Works for all database instances (`database_instance_1`, `database_instance_2`, etc.)
- `transition_web` - Works for all web service instances (`web_service_1`, `web_service_2`, etc.)

**Role Resolution Logic:**
```yaml
# Component name: app_instance_3
# Extracted class: app (via split('_')[0])
# Resolved role: transition_app
```

#### 14.2 Transition Role Structure

Each transition role contains:
- **Service Management**: Real systemd service start/stop operations
- **Health Verification**: Port checks, process verification, dependency validation
- **Resource Cleanup**: File cleanup, process termination, network resource management
- **Failure Handling**: Diagnosis, recovery attempts, error reporting

#### 14.3 Component Ownership

- **Separation of Concerns**: State machine mechanics stay centralized, component logic is decentralized
- **Component Ownership**: Each resource class team owns their transition role implementation
- **Reusability**: One role per resource class, not per instance
- **Maintainability**: Changes to component logic don't affect state machine framework

### 15. Component Type Architecture (v1.7)

#### 15.1 Component Type Classification

The framework now supports explicit component type classification through the `asset_type` field:

**Component Configuration:**
```yaml
asset_definitions:
  app_instance:
    state_machine_spec: app_lifecycle
    asset_type: app
    initial_state: CREATED
  app_instance_2:
    state_machine_spec: app_lifecycle
    asset_type: app
    initial_state: CREATED
  database_instance:
    state_machine_spec: database_lifecycle
    asset_type: database
    initial_state: CREATED
```

#### 15.2 Dynamic Role Resolution

Transition roles are now resolved using the `asset_type` field instead of parsing component names:

**Role Resolution Logic:**
```yaml
# Old method (deprecated):
# component_name: app_instance_3
# extracted_class: app (via split('_')[0])
# resolved_role: transition_app

# New method (v1.7):
# asset_type: app (from configuration)
# resolved_role: transition_app
```

#### 15.3 Benefits of Component Type Architecture

1. **Explicit Classification**: No ambiguity about component types
2. **Cleaner Resolution**: No string parsing required
3. **Better Maintainability**: Type changes don't require name changes
4. **Enhanced Validation**: System can validate component types exist
5. **Improved Documentation**: Clear type definitions in configuration

#### 15.4 Implementation Status

**✅ Completed Features:**
- Component type field added to all component definitions
- Dynamic role resolution using `asset_type`
- Variable passing to transition roles
- Validation of component type existence
- Successful testing with `app_instance_4`

**🔧 Technical Implementation:**
- `asset_type` resolved from `component[component_name].asset_type`
- Default fallback to `'app'` if not specified
- Role name pattern: `transition_{{ asset_type }}`
- Variable inheritance through `include_role` calls

### 16. Component Types Configuration Architecture (v1.9)

#### 16.1 Component Types Configuration

The framework now supports a dedicated configuration file for mapping component types to their corresponding roles, supporting both local roles and roles from collections:

**Asset Types Configuration (`group_vars/all/asset_types.yml`):**
```yaml
asset_types:
  app:
    role_name: transition_app
    role_collection: null  # null for local roles
    default_timeout: 300

  database:
    role_name: transition_database
    role_collection: null
    default_timeout: 600

  # Example of role from a collection
  kubernetes:
    role_name: transition_k8s
    role_collection: "community.kubernetes"
    default_timeout: 900
```

#### 16.2 Benefits of Component Types Configuration

1. **Collection Support**: Roles can be sourced from Ansible collections
2. **Flexible Mapping**: Component types can map to any role name, not just `transition_{{ type }}`
3. **Timeout Configuration**: Per-component-type timeout settings
4. **Centralized Management**: All role mappings in one configuration file
5. **Backward Compatibility**: Fallback to legacy pattern if component type not found

#### 16.3 Role Resolution Logic

**New Resolution Process:**
```yaml
# 1. Look up component type in asset_types configuration
asset_type_info: "{{ asset_types[asset_type] | default({}) }}"

# 2. Resolve role name (with fallback to legacy pattern)
transition_role_name: "{{ asset_type_info.role_name | default(asset_type_config.legacy_pattern | replace('{{ asset_type }}', asset_type)) }}"

# 3. Resolve collection (null for local roles)
transition_role_collection: "{{ asset_type_info.role_collection | default(asset_type_config.default_collection) }}"

# 4. Execute role with collection support
- name: "Execute transition actions"
  include_role:
    name: "{{ transition_role_name }}"
    collection: "{{ transition_role_collection if transition_role_collection is not none else omit }}"
```

#### 16.4 Global Configuration Settings

**Component Type Configuration Settings:**
```yaml
asset_type_config:
  # Default role collection for all component types
  default_collection: null
  
  # Validation settings
  validate_role_existence: true
  validate_collection_availability: true
  
  # Fallback settings
  fallback_asset_type: "app"
  fallback_role_name: "transition_app"
  fallback_collection: null
  
  # Role resolution settings
  role_resolution_method: "asset_types"  # Options: "asset_types", "legacy_pattern"
  legacy_pattern: "transition_{{ asset_type }}"
```

### 17. Component Properties Architecture (v1.8)

#### 16.1 Centralized Component Properties

The framework now supports centralized component property management through dedicated configuration files:

**Component Properties Structure:**
```yaml
# group_vars/all/assets.yml
asset_definitions:
  app_instance:
    state_machine_spec: app_lifecycle
    asset_type: app
    initial_state: CREATED
    # Component-specific properties
    services:
      - "com.apple.syspolicyd"
      - "com.apple.kextd"
    processes:
      - "kernel_task"
      - "launchd"
    ports:
      - 8180
    dependencies:
      - "com.apple.syspolicyd"
      - "com.apple.kextd"
    maintenance_window:
      start: 2
      end: 4
```

#### 16.2 Benefits of Centralized Properties

1. **Single Source of Truth**: All component properties defined in one location
2. **Consistency**: All components follow the same property structure
3. **Maintainability**: Changes to component properties only need to be made in one place
4. **Cleaner Inventory**: Inventory files focus on host-specific configuration
5. **Better Organization**: Logical separation between component definitions and state machines

#### 16.3 Property Inheritance

Component properties are automatically inherited by transition roles:

**Playbook Variable Resolution:**
```yaml
vars:
  component_services: "{{ component[component_name].services | default([]) }}"
  component_processes: "{{ component[component_name].processes | default([]) }}"
  component_ports: "{{ component[component_name].ports | default([]) }}"
  component_dependencies: "{{ component[component_name].dependencies | default([]) }}"
  component_maintenance_window: "{{ component[component_name].maintenance_window | default({}) }}"
```

### 17. State Machine Architecture

#### 17.1 Separated State Machine Structure

The state machine framework uses a two-tier architecture with separated files:

**State Machine Definitions (`group_vars/all/state_machines.yml`):**
```yaml
state_machines:
  app_lifecycle:
    states: [CREATED, STARTING, RUNNING, ...]
    transitions:
      CREATED:
        to: [STARTING, FAILED]
    initial_state: CREATED
    state_configs:
      CREATED:
        description: "Application instance created but not started"
        actions: []
```

**Asset References (`group_vars/all/assets.yml`):**
```yaml
asset_definitions:
  app_instance:
    state_machine_spec: app_lifecycle
    asset_type: app
    initial_state: CREATED
    services: [...]
    ports: [...]
  app_instance_2:
    state_machine_spec: app_lifecycle
    asset_type: app
    initial_state: CREATED
    services: [...]
    ports: [...]
```

#### 17.2 Benefits of Separated Architecture

1. **Reusability**: Multiple components can reference the same state machine
2. **Maintainability**: State machine changes affect all referencing components
3. **Scalability**: Easy to add new state machines and components
4. **Consistency**: Ensures all components using the same state machine follow identical rules

### 18. Component Type Usage Examples

#### 18.1 Basic Component Registration

**Adding a new application instance:**
```yaml
# In group_vars/all/assets.yml
asset_definitions:
  app_instance_4:
    state_machine_spec: app_lifecycle
    asset_type: app
    initial_state: CREATED
```

**Adding a database instance:**
```yaml
asset_definitions:
  database_instance_1:
    state_machine_spec: database_lifecycle
    asset_type: database
    initial_state: CREATED
```

#### 18.2 Transition Execution Examples

**Application instance transition:**
```bash
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=app_instance_4 \
  -e transition=RUNNING
```

**Database instance transition:**
```bash
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=database_instance_1 \
  -e transition=RUNNING
```

#### 18.3 Role Resolution Examples

**Component Type Resolution:**
```yaml
# Component: app_instance_4
# asset_type: app (from configuration)
# Resolved role: transition_app

# Component: database_instance_1  
# asset_type: database (from configuration)
# Resolved role: transition_database
```

#### 18.4 Variable Inheritance

**Playbook variable resolution:**
```yaml
vars:
  component_name: "{{ component | default('resource') }}"
  asset_type: "{{ component[component_name].asset_type | default('app') }}"
```

**Role variable passing:**
```yaml
- name: "Execute transition actions for {{ component_name }}"
  include_role:
    name: "transition_{{ asset_type }}"
  vars:
    target_state: "{{ actual_target_state | default(target_transition) }}"
    current_state: "{{ component_state }}"
    component_instance: "{{ component_name }}"
```

#### 18.5 Multi-Component Scenarios

**Mixed component types in same inventory:**
```yaml
# inventory.yml
all:
  children:
    app_hosts:
      hosts:
        app-1:
          component: app_instance_1
        app-2:
          component: app_instance_2
    database_hosts:
      hosts:
        db-1:
          component: database_instance_1
        db-2:
          component: database_instance_2
```

**Bulk operations by component type:**
```bash
# Start all application instances
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  --limit app_hosts \
  -e transition=RUNNING

# Stop all database instances  
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  --limit database_hosts \
  -e transition=STOPPED
```

---

### 19. Platform as a Service (PaaS) Focus (v1.9)

#### 19.1 PaaS vs IaaS Distinction

The framework has been updated to focus on **Platform as a Service (PaaS)** application management rather than Infrastructure as a Service (IaaS) compute management:

**Key Changes:**
- **Component Naming**: `compute_instance` → `app_instance` (application instances vs compute instances)
- **State Machine**: `compute_lifecycle` → `app_lifecycle` (application lifecycle vs compute lifecycle)
- **Component Type**: `compute` → `app` (application type vs compute type)
- **Transition Role**: `transition_compute` → `transition_app` (application transition logic vs compute transition logic)

#### 19.2 Application-Centric State Descriptions

State descriptions have been updated to reflect application management:

**Before (IaaS Focus):**
- "Compute instance (VM+OS) has been created but not started"
- "Compute instance is being initialized (VM boot + OS startup)"
- "Compute instance is operational (VM running + OS services active)"

**After (PaaS Focus):**
- "Application instance has been created but not started"
- "Application instance is being initialized (app startup + service initialization)"
- "Application instance is operational (app running + services active)"

#### 19.3 Application-Centric Actions

Transition actions have been updated to focus on application and service management:

**Before (IaaS Actions):**
- `start_vm`, `boot_os`, `verify_compute_health`
- `monitor_vm_health`, `monitor_os_services`
- `shutdown_os`, `stop_vm`
- `destroy_vm`

**After (PaaS Actions):**
- `start_app`, `initialize_services`, `verify_app_health`
- `monitor_app_health`, `monitor_services`
- `shutdown_app`, `stop_services`
- `destroy_app`

#### 19.4 Benefits of PaaS Focus

1. **Application-Centric**: Framework now manages applications and services rather than infrastructure
2. **Service-Oriented**: Focus on application lifecycle, service dependencies, and platform operations
3. **Platform Operations**: Better suited for managing application instances in containerized or serverless environments
4. **Clearer Semantics**: Component names and descriptions clearly indicate application management
5. **Modern Architecture**: Aligns with modern PaaS platforms and microservices architectures

#### 19.5 Implementation Impact

**Configuration Changes:**
- All component definitions updated to use `app_instance` naming
- State machine definitions updated to `app_lifecycle`
- Component types changed from `compute` to `app`
- Transition roles renamed from `transition_compute` to `transition_app`

**Documentation Updates:**
- SRS updated to reflect PaaS focus
- Examples updated to show application instance management
- State descriptions updated for application lifecycle
- Action descriptions updated for service management

**Backward Compatibility:**
- Existing IaaS-focused configurations can be migrated by updating component names and types
- State machine definitions can be updated to use application-focused descriptions
- Transition roles can be updated to focus on application and service management

### 20. Map-Based State Access Architecture (v2.0)

#### 20.1 Centralized State Map Overview

The framework now supports both distributed state files and centralized map-based access for efficient state operations:

**Dual Architecture Benefits:**
- **Distributed State Files**: Individual `state_<component>.fact` files for lifecycle management across different playbook instances
- **Centralized Map Access**: Ansible-level `global_component_states` map for efficient programmatic operations within a single playbook run

#### 20.2 State Map Implementation

**Map Loading Process:**
```yaml
# 1. Find all state fact files
- name: "Find all state fact files"
  find:
    paths: "{{ state_fact_directory | default('./state') }}"
    patterns: "state_*.fact"
  register: state_files_found

# 2. Load each file into map
- name: "Load state file and build map entry"
  include_tasks: load_single_state_file.yml
  loop: "{{ state_files_found.files }}"

# 3. Set global state map
- name: "Set global state map facts"
  set_fact:
    global_component_states: "{{ component_states_map }}"
```

**Map Structure:**
```yaml
global_component_states:
  app_instance:
    state: RUNNING
    timestamp: '2025-10-15T08:53:02Z'
    method: state_persist
    previous_state: STARTING
    transition: STARTING -> RUNNING
    valid: true
    file_path: state/state_app_instance.fact
    file_exists: true
    metadata:
      hostname: "Ryszards-MacBook-Pro"
      user_id: "rstyczynski"
      playbook_name: "Change Component State"
      ansible_version: {...}
  app_instance_2:
    state: TERMINATED
    timestamp: '2025-10-14T09:47:38Z'
    # ... similar structure
```

#### 20.3 State Access Operations

**Component State Lookup:**
```yaml
- name: "Get component state from map"
  set_fact:
    current_state: "{{ global_component_states[component].state }}"
    current_timestamp: "{{ global_component_states[component].timestamp }}"
  when: global_component_states[component] is defined
```

**Filter by State:**
```yaml
- name: "Get components in specific state"
  set_fact:
    running_asset_definitions: "{{ global_component_states | dict2items | selectattr('value.state', 'equalto', 'RUNNING') | map(attribute='key') | list }}"
```

**List All States:**
```yaml
- name: "Display all component states"
  debug:
    msg: "All Component States: {{ global_component_states | to_nice_yaml }}"
```

#### 20.4 State Context Role Integration

**Enhanced State Context Role:**
```yaml
# roles/state_context/tasks/main.yml
- name: "Load state map for efficient access"
  include_tasks: load_state_map.yml

- name: "Use map-based state access"
  include_tasks: map_state_operations.yml
  when: global_component_states is defined

- name: "Fallback to individual file reading"
  include_tasks: individual_file_reading.yml
  when: global_component_states is not defined
```

#### 20.5 Usage Examples

**Get Specific Component State:**
```bash
ansible-playbook get_component_state_map.yml -e component_name=app_instance_5
```

**List All Component States:**
```bash
ansible-playbook get_component_state_map.yml -e list_all=true
```

**Filter Components by State:**
```bash
ansible-playbook get_component_state_map.yml -e filter_state=RUNNING
```

#### 20.6 Benefits of Map-Based Architecture

1. **Efficient Access**: O(1) lookup time for component states
2. **Batch Operations**: Process multiple components simultaneously
3. **State Filtering**: Easy filtering and querying by state
4. **Distributed Persistence**: Individual files remain for lifecycle management
5. **Centralized Operations**: Single map for programmatic access
6. **Backward Compatibility**: Fallback to individual file reading if map unavailable
7. **Performance**: Reduced file I/O operations for multiple state queries

#### 20.7 Implementation Files

**Core Implementation:**
- `roles/state_context/tasks/load_state_map.yml` - Loads all state files into map
- `roles/state_context/tasks/load_single_state_file.yml` - Loads individual state file
- `roles/state_context/tasks/map_state_operations.yml` - Map-based state operations
- `roles/state_context/tasks/individual_file_reading.yml` - Fallback individual file reading
- `get_component_state_map.yml` - Demonstration playbook for map-based access

**Key Features:**
- Automatic state file discovery
- Efficient map loading with `slurp` and `from_yaml`
- Comprehensive state metadata preservation
- Robust error handling and fallback mechanisms
- Support for filtering and querying operations

---

**End of Document**
