# SRS - Variable Safety Requirements

## 1. Variable Safety and Isolation

### 1.1 Overview

Variable safety is a critical requirement for the state-driven component management system. The system must prevent variable contamination, recursion risks, and ensure proper isolation when components interact with each other across different assets.

### 1.2 Problem Statement

When using the `state_change` role from one asset to control another asset, there are significant risks:

1. **Variable Contamination**: Variables set in one component's context can pollute the global scope and affect other components
2. **Recursion Risk**: Uncontrolled variable propagation can lead to infinite loops and system instability
3. **Cross-Asset Control Issues**: Direct variable sharing between assets can cause unpredictable behavior
4. **State Corruption**: Contaminated variables can lead to incorrect state transitions and system failures

### 1.3 Critical Safety Requirements

#### 1.3.1 Variable Isolation (REQ-VS-001)

**Requirement**: All internally computed variables within the `state_change` role MUST be isolated using a unique prefix to prevent contamination of the global variable scope.

**Implementation**:
- All `set_fact` operations within `state_change/tasks/main.yml` MUST use the `isolated_` prefix
- Variables MUST be renamed: `component` → `isolated_component`, `target_state` → `isolated_target_state`, etc.
- All subsequent references within the role MUST use the isolated variable names

**Rationale**: Prevents variable contamination when the role is used across different assets.

#### 1.3.2 Safe Cross-Asset Control (REQ-VS-002)

**Requirement**: The system MUST support safe cross-asset control where one component can control another without variable pollution.

**Implementation**:
- The `state_change` role MUST be designed for safe reuse across different assets
- All role parameters MUST be explicitly passed to prevent variable leakage
- The role MUST not rely on global variables that could be contaminated

**Rationale**: Enables complex orchestration scenarios where components need to control each other.

#### 1.3.3 Recursion Prevention (REQ-VS-003)

**Requirement**: The system MUST prevent recursion risks when components interact with each other.

**Implementation**:
- Variable isolation prevents uncontrolled variable propagation
- Each role execution MUST have its own isolated variable namespace
- No global variable dependencies that could cause recursion

**Rationale**: Prevents system instability and infinite loops.

#### 1.3.4 Dependency Validation Safety (REQ-VS-004)

**Requirement**: Dependency validation MUST work correctly even with variable isolation.

**Implementation**:
- The `state_guard` role MUST receive explicitly passed dependency information
- Dependency variables MUST be passed as: `component_dependencies: "{{ isolated_component_dependencies }}"`
- No reliance on global variables for dependency validation

**Rationale**: Ensures dependency validation continues to work after implementing variable isolation.

### 1.4 Implementation Details

#### 1.4.1 Variable Isolation Pattern

```yaml
# BEFORE (Unsafe)
- name: "Set component variables"
  set_fact:
    component: "{{ component_name }}"
    target_state: "{{ target_state }}"
    component_dependencies: "{{ dependencies }}"

# AFTER (Safe)
- name: "Set isolated component variables"
  set_fact:
    isolated_component: "{{ component_name }}"
    isolated_target_state: "{{ target_state }}"
    isolated_component_dependencies: "{{ dependencies }}"
```

#### 1.4.2 Safe Role Invocation

```yaml
# Safe role invocation with explicit variable passing
- name: "State Guard - Validate transition"
  ansible.builtin.include_role:
    name: state_guard
  vars:
    component: "{{ component_name }}"
    current_state: "{{ component_state }}"
    target_state: "{{ actual_target_state }}"
    component_dependencies: "{{ isolated_component_dependencies }}"
```

#### 1.4.3 Transient State Safety

```yaml
# Safe transient state handling
- name: "State Transient - Handle transient state mapping"
  ansible.builtin.include_role:
    name: state_transient
  vars:
    component: "{{ isolated_component }}"
    target_state: "{{ isolated_target_state }}"
    current_state: "{{ isolated_current_state }}"
```

### 1.5 Safety Validation

#### 1.5.1 Variable Contamination Tests

The system MUST pass the following tests:

1. **Cross-Asset Control Test**: Component A controlling Component B must not contaminate Component A's variables
2. **Recursion Prevention Test**: Multiple nested component interactions must not cause recursion
3. **Dependency Validation Test**: Dependency validation must work correctly with isolated variables
4. **State Transition Test**: State transitions must work correctly with variable isolation

#### 1.5.2 Safety Metrics

- **Variable Isolation Coverage**: 100% of internal variables must be isolated
- **Cross-Asset Safety**: 100% of cross-asset interactions must be safe
- **Recursion Prevention**: 0% risk of recursion in normal operations
- **Dependency Validation**: 100% of dependency checks must work correctly

### 1.6 Error Handling

#### 1.6.1 Variable Contamination Detection

The system MUST detect and prevent:

- Global variable pollution
- Uncontrolled variable propagation
- Cross-asset variable contamination
- Recursion risks

#### 1.6.2 Safety Failures

If variable safety is compromised, the system MUST:

1. **Fail Fast**: Stop execution immediately
2. **Log Error**: Record the safety violation
3. **Clean State**: Restore clean variable state
4. **Report Issue**: Provide clear error message

### 1.7 Compliance Requirements

#### 1.7.1 Mandatory Compliance

- **REQ-VS-001**: Variable Isolation - MANDATORY
- **REQ-VS-002**: Safe Cross-Asset Control - MANDATORY  
- **REQ-VS-003**: Recursion Prevention - MANDATORY
- **REQ-VS-004**: Dependency Validation Safety - MANDATORY

#### 1.7.2 Verification

All variable safety requirements MUST be verified through:

1. **Code Review**: Manual inspection of variable usage
2. **Automated Testing**: Test suite for variable safety
3. **Integration Testing**: Cross-asset interaction testing
4. **Performance Testing**: Recursion prevention validation

### 1.8 Risk Assessment

#### 1.8.1 High Risk Scenarios

1. **Cross-Asset Control**: Using `state_change` from one asset to control another
2. **Nested Interactions**: Multiple levels of component interactions
3. **Dependency Chains**: Complex dependency relationships between components
4. **State Transitions**: Rapid state changes across multiple components

#### 1.8.2 Mitigation Strategies

1. **Variable Isolation**: Prevent contamination through isolation
2. **Explicit Passing**: All variables must be explicitly passed
3. **Namespace Separation**: Each role execution has its own namespace
4. **Validation**: Continuous validation of variable safety

### 1.9 Implementation Checklist

- [ ] All `set_fact` operations use `isolated_` prefix
- [ ] All variable references use isolated names
- [ ] Role invocations pass variables explicitly
- [ ] Dependency validation works with isolated variables
- [ ] Cross-asset control is safe
- [ ] Recursion prevention is implemented
- [ ] Safety tests pass
- [ ] Documentation is updated

## 2. Dependency Management Operations

### 2.1 Overview

Dependency management operations provide automated lifecycle control for component dependencies. The system supports both start and stop dependency chains, ensuring proper orchestration of complex component relationships.

### 2.2 Problem Statement

Components in the system often have dependencies on other components. When transitioning a component's state, its dependencies must be managed appropriately:

1. **Start Dependencies**: When starting a component, its dependencies must be started first
2. **Stop Dependencies**: When stopping a component, its dependencies must be stopped after
3. **Dependency Validation**: The system must validate that dependencies are in the correct state
4. **Chain Management**: Complex dependency chains must be handled correctly

### 2.3 Dependency Operation Requirements

#### 2.3.1 Start Dependency Management (REQ-DM-001)

**Requirement**: When starting a component, the system MUST automatically start all its dependencies that are not already in the `RUNNING` state.

**Implementation**:
- Check current state of all dependencies
- Identify dependencies that are not `RUNNING`
- Start non-running dependencies using the `state_change` role
- Validate that all dependencies reach `RUNNING` state
- Proceed with the main component start only after dependencies are ready

**Rationale**: Ensures proper startup order and prevents starting components with non-functional dependencies.

#### 2.3.2 Stop Dependency Management (REQ-DM-002)

**Requirement**: When stopping a component, the system MUST automatically stop all its dependencies that are not already in the `STOPPED` state.

**Implementation**:
- Check current state of all dependencies
- Identify dependencies that are not `STOPPED`
- Stop non-stopped dependencies using the `state_change` role
- Validate that all dependencies reach `STOPPED` state
- Proceed with the main component stop only after dependencies are stopped

**Rationale**: Ensures proper shutdown order and prevents leaving orphaned running dependencies.

#### 2.3.3 Dependency State Validation (REQ-DM-003)

**Requirement**: The system MUST validate dependency states before and after dependency operations.

**Implementation**:
- Pre-operation validation: Check current dependency states
- Post-operation validation: Verify dependencies reached target state
- Error handling: Fail fast if dependencies cannot be managed
- State reporting: Provide clear feedback on dependency states

**Rationale**: Ensures reliability and provides clear feedback on dependency management operations.

#### 2.3.4 Configuration-Driven Dependency Control (REQ-DM-004)

**Requirement**: Dependency management MUST be configurable per asset type and component.

**Implementation**:
- Asset type configuration: `disable_state_guard` for specific asset types
- Component-specific dependency definitions in `assets.yml`
- Flexible dependency management that can be enabled/disabled per component
- Support for different dependency management strategies

**Rationale**: Provides flexibility for different component types and use cases.

### 2.4 Implementation Details

#### 2.4.1 Start Dependency Flow

```yaml
# Start dependency management flow
- name: "Check if dependencies need to be started"
  set_fact:
    should_start_dependencies: "{{ target_state in ['STARTING', 'RUNNING'] and component_dependencies | default([]) | length > 0 }}"

- name: "Extract dependency states from global state map"
  set_fact:
    dependency_states: "{{ component_dependencies | map('extract', global_component_states) | map(attribute='state') | list }}"

- name: "Create dependency state mapping"
  set_fact:
    dependency_state_map: "{{ dict(component_dependencies | zip(dependency_states)) }}"

- name: "Start dependencies that are not RUNNING"
  ansible.builtin.include_role:
    name: state_change
  vars:
    component_name: "{{ item.key }}"
    target_state: RUNNING
    component_dependencies: "{{ dependency_component_map[item.key] | default([]) }}"
  loop: "{{ dependency_state_map | dict2items }}"
  when:
    - item.value not in ['RUNNING']

- name: "Validate all dependencies are RUNNING"
  ansible.builtin.assert:
    that:
      - item.value == 'RUNNING'
    fail_msg: "Dependency {{ item.key }} is not RUNNING (current: {{ item.value }})"
    success_msg: "All dependencies are RUNNING"
  loop: "{{ dependency_state_map | dict2items }}"
```

#### 2.4.2 Stop Dependency Flow

```yaml
# Stop dependency management flow
- name: "Check if dependencies need to be stopped"
  set_fact:
    should_stop_dependencies: "{{ target_state in ['STOPPING', 'STOPPED', 'TERMINATING', 'TERMINATED'] and component_dependencies | default([]) | length > 0 }}"

- name: "Extract dependency states from global state map"
  set_fact:
    dependency_states: "{{ component_dependencies | map('extract', global_component_states) | map(attribute='state') | list }}"

- name: "Create dependency state mapping"
  set_fact:
    dependency_state_map: "{{ dict(component_dependencies | zip(dependency_states)) }}"

- name: "Stop dependencies that are not STOPPED"
  ansible.builtin.include_role:
    name: state_change
  vars:
    component_name: "{{ item.key }}"
    target_state: STOPPED
    component_dependencies: "{{ dependency_component_map[item.key] | default([]) }}"
  loop: "{{ dependency_state_map | dict2items }}"
  when:
    - item.value not in ['STOPPED']

- name: "Validate all dependencies are STOPPED"
  ansible.builtin.assert:
    that:
      - item.value == 'STOPPED'
    fail_msg: "Dependency {{ item.key }} is not STOPPED (current: {{ item.value }})"
    success_msg: "All dependencies are STOPPED"
  loop: "{{ dependency_state_map | dict2items }}"
```

#### 2.4.3 Asset Type Configuration

```yaml
# Asset type configuration for dependency management
asset_types:
  node:
    disable_state_guard: true
    dependency_management: true
  app:
    disable_state_guard: false
    dependency_management: true
  os:
    disable_state_guard: false
    dependency_management: true
```

#### 2.4.4 Component Dependency Definition

```yaml
# Component dependency definitions
node1:
  state_machine_spec: generic_lifecycle
  asset_type: node
  initial_state: CREATED
  dependencies:
    - app1

app1:
  state_machine_spec: generic_lifecycle
  asset_type: app
  initial_state: CREATED
  dependencies:
    - os_instance1

os_instance1:
  state_machine_spec: generic_lifecycle
  asset_type: os
  initial_state: CREATED
```

### 2.5 Dependency Chain Examples

#### 2.5.1 Start Chain: node1 → app1 → os_instance1

1. **Start node1**: 
   - Check dependencies: `app1` (STOPPED)
   - Start `app1`: Check dependencies: `os_instance1` (STOPPED)
   - Start `os_instance1`: No dependencies, start directly
   - Validate `os_instance1` is RUNNING
   - Start `app1`: Validate `os_instance1` is RUNNING, start `app1`
   - Validate `app1` is RUNNING
   - Start `node1`: Validate `app1` is RUNNING, start `node1`
   - Validate `node1` is RUNNING

#### 2.5.2 Stop Chain: node1 → app1 → os_instance1

1. **Stop node1**:
   - Stop `node1` first
   - Check dependencies: `app1` (RUNNING)
   - Stop `app1`: Check dependencies: `os_instance1` (RUNNING)
   - Stop `os_instance1`: No dependencies, stop directly
   - Validate `os_instance1` is STOPPED
   - Stop `app1`: Validate `os_instance1` is STOPPED, stop `app1`
   - Validate `app1` is STOPPED

### 2.6 Error Handling

#### 2.6.1 Dependency Start Failures

If a dependency cannot be started:
1. **Fail Fast**: Stop the entire start operation
2. **Log Error**: Record which dependency failed and why
3. **Clean State**: Ensure no partial starts are left in inconsistent state
4. **Report Issue**: Provide clear error message with dependency information

#### 2.6.2 Dependency Stop Failures

If a dependency cannot be stopped:
1. **Continue**: Allow the main component to stop (dependencies may be managed elsewhere)
2. **Log Warning**: Record the dependency stop failure
3. **Report Status**: Provide clear status on dependency stop results

### 2.7 Performance Considerations

#### 2.7.1 Parallel Dependency Management

- Dependencies can be started/stopped in parallel when they don't depend on each other
- Sequential processing for dependencies with their own dependency chains
- Optimize for minimal total operation time

#### 2.7.2 State Validation Efficiency

- Use global state map for efficient dependency state checking
- Minimize external calls for state validation
- Cache dependency state information when possible

### 2.8 Testing Requirements

#### 2.8.1 Dependency Chain Tests

1. **Simple Chain**: A → B → C start/stop operations
2. **Complex Chain**: Multiple parallel dependencies
3. **Failure Scenarios**: Dependency start/stop failures
4. **State Validation**: Correct state transitions for all components

#### 2.8.2 Performance Tests

1. **Large Chains**: Test with many dependencies
2. **Parallel Operations**: Test concurrent dependency management
3. **State Validation**: Test efficient state checking

### 2.9 Compliance Requirements

#### 2.9.1 Mandatory Compliance

- **REQ-DM-001**: Start Dependency Management - MANDATORY
- **REQ-DM-002**: Stop Dependency Management - MANDATORY
- **REQ-DM-003**: Dependency State Validation - MANDATORY
- **REQ-DM-004**: Configuration-Driven Control - MANDATORY

#### 2.9.2 Verification

All dependency management requirements MUST be verified through:

1. **Unit Testing**: Individual dependency operations
2. **Integration Testing**: Full dependency chains
3. **Performance Testing**: Large dependency chains
4. **Failure Testing**: Error scenarios and recovery

### 2.10 Implementation Checklist

- [ ] Start dependency management implemented
- [ ] Stop dependency management implemented
- [ ] Dependency state validation working
- [ ] Configuration-driven control implemented
- [ ] Error handling for failures
- [ ] Performance optimization
- [ ] Testing coverage complete
- [ ] Documentation updated

### 1.10 Conclusion

Variable safety is a fundamental requirement for the state-driven component management system. The implementation of variable isolation, safe cross-asset control, recursion prevention, and dependency validation safety ensures the system can handle complex orchestration scenarios without compromising system stability or data integrity.

The `isolated_` prefix pattern provides a simple yet effective mechanism for preventing variable contamination while maintaining full functionality of the state management system.

### 2.11 Dependency Management Conclusion

Dependency management operations provide the foundation for complex component orchestration. The implementation of start/stop dependency chains, state validation, and configuration-driven control ensures that components can be managed as cohesive systems rather than isolated entities.

The dependency management system enables:
- **Automated Lifecycle Management**: Components automatically manage their dependencies
- **Reliable Operations**: Proper start/stop order ensures system reliability
- **Flexible Configuration**: Different strategies for different component types
- **Error Resilience**: Proper handling of dependency failures

This approach provides a scalable and maintainable solution for managing complex component relationships in the state-driven component management system.
