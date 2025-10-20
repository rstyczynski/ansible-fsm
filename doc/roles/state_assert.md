# State Assert Role

This role validates that an asset is in the expected state by querying the FSM API and asserting the current state matches the expected state.

## Features

- **State Validation**: Queries FSM API to get current asset state
- **State Assertion**: Validates current state matches expected state
- **Error Handling**: Provides clear error messages for assertion failures
- **Return Values**: Returns structured data about the assertion result
- **Debug Support**: Optional debug output for troubleshooting

## Usage

### Basic Usage

```yaml
- name: "Assert asset state"
  include_role:
    name: toolchain.fsm.state_assert
  vars:
    asset_id: "my_app"
    expected_state: "RUNNING"
```

### Advanced Usage

```yaml
- name: "Assert asset state with custom settings"
  include_role:
    name: toolchain.fsm.state_assert
  vars:
    asset_id: "database"
    expected_state: "STOPPED"
    fsm:
      endpoint: "https://fsm.example.com"
    debug_output: true
```

## Variables

### Required Variables

- `asset_id`: ID of the asset to assert state for
- `expected_state`: Expected state to assert

### Optional Variables

- `fsm.endpoint`: FSM API endpoint (default: "http://localhost:8080")
- `debug_output`: Enable debug output (default: false)

## Tags

- `state_assert`: State assertion operations
- `state_validation`: State validation
- `fsm_api`: FSM API operations

## Examples

### Assert Running State

```yaml
- name: "Assert application is running"
  include_role:
    name: toolchain.fsm.state_assert
  vars:
    asset_id: "web_server"
    expected_state: "RUNNING"
```

### Assert with Custom FSM Endpoint

```yaml
- name: "Assert state with custom endpoint"
  include_role:
    name: toolchain.fsm.state_assert
  vars:
    asset_id: "database"
    expected_state: "STOPPED"
    fsm:
      endpoint: "https://production-fsm.company.com"
```

### Capture Return Values

```yaml
- name: "Assert state and capture results"
  include_role:
    name: toolchain.fsm.state_assert
  vars:
    asset_id: "my_app"
    expected_state: "RUNNING"
  register: assertion_result

- name: "Display assertion results"
  ansible.builtin.debug:
    msg: |
      Assertion Results:
      - Asset: {{ assertion_result.ansible_facts.state_assert_asset_id }}
      - Expected: {{ assertion_result.ansible_facts.state_assert_expected_state }}
      - Actual: {{ assertion_result.ansible_facts.state_assert_actual_state }}
      - Success: {{ assertion_result.ansible_facts.state_assert_success }}
      - Message: {{ assertion_result.ansible_facts.state_assert_message }}
      - Timestamp: {{ assertion_result.ansible_facts.state_assert_timestamp }}
```

## Output Variables

The role sets the following variables:

- `state_assert_success`: Whether the assertion was successful (always true if role completes)
- `state_assert_asset_id`: The asset ID that was asserted
- `state_assert_expected_state`: The expected state that was asserted
- `state_assert_actual_state`: The actual state from the FSM API
- `state_assert_message`: Human-readable message about the assertion
- `state_assert_timestamp`: ISO8601 timestamp of when assertion was performed

## Error Handling

The role will fail with a clear error message if:

- The asset is not found (404 error from FSM API)
- The FSM API is unreachable
- The current state does not match the expected state

Example error message:
```
Current state 'STOPPED' does not match expected state 'RUNNING' for asset 'my_app'
```

## Dependencies

This role has no dependencies on other roles but requires:

- Access to the FSM API endpoint
- Valid `asset_id` that exists in the FSM system
- Network connectivity to the FSM API
