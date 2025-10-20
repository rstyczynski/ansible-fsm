# Ansible Role Return Values Guide

## Overview

Ansible roles can return values to the calling playbook using several methods. This guide shows you how to implement and capture role return values.

## Method 1: Using `set_fact` (Recommended)

### In the Role

```yaml
# roles/my_role/tasks/main.yml
---
- name: Perform operation
  ansible.builtin.debug:
    msg: "Processing {{ input_value }}"

- name: Calculate result
  ansible.builtin.set_fact:
    calculation_result: "{{ input_value | int * 2 }}"

- name: Return multiple values
  ansible.builtin.set_fact:
    role_result:
      success: true
      value: "{{ calculation_result }}"
      message: "Operation completed successfully"
      timestamp: "{{ ansible_date_time.iso8601 }}"

- name: Return status
  ansible.builtin.set_fact:
    role_status: "completed"
```

### In the Playbook

```yaml
---
- name: Call role and capture return values
  ansible.builtin.include_role:
    name: my_role
  vars:
    input_value: "5"
  register: role_output

- name: Display role return values
  ansible.builtin.debug:
    msg: |
      Role returned:
      - Status: {{ role_output.ansible_facts.role_status }}
      - Result: {{ role_output.ansible_facts.role_result }}
      - Calculation: {{ role_output.ansible_facts.calculation_result }}

- name: Use returned values
  ansible.builtin.debug:
    msg: "The calculated value is {{ role_output.ansible_facts.calculation_result }}"
```

## Method 2: Using `register` with Task Results

### In the Role

```yaml
# roles/my_role/tasks/main.yml
---
- name: Perform operation
  ansible.builtin.uri:
    url: "{{ api_endpoint }}"
    method: GET
  register: api_result

- name: Set return values based on task result
  ansible.builtin.set_fact:
    role_success: "{{ api_result.status == 200 }}"
    role_data: "{{ api_result.json }}"
    role_message: "{{ 'Success' if api_result.status == 200 else 'Failed' }}"
```

### In the Playbook

```yaml
---
- name: Call role
  ansible.builtin.include_role:
    name: my_role
  vars:
    api_endpoint: "https://api.example.com/data"
  register: role_output

- name: Check if role succeeded
  ansible.builtin.debug:
    msg: "Role success: {{ role_output.ansible_facts.role_success }}"
  when: role_output.ansible_facts.role_success
```

## Method 3: Using Loop Results

### In the Playbook

```yaml
---
- name: Call role multiple times
  ansible.builtin.include_role:
    name: my_role
  loop: [10, 20, 30]
  loop_control:
    loop_var: input_value
  register: role_results

- name: Display all results
  ansible.builtin.debug:
    msg: |
      Results:
      {% for result in role_results.results %}
      - Input: {{ result.item }}
        Output: {{ result.ansible_facts.calculation_result }}
        Success: {{ result.ansible_facts.role_result.success }}
      {% endfor %}

- name: Filter successful results
  ansible.builtin.set_fact:
    successful_results: "{{ role_results.results | selectattr('ansible_facts.role_result.success', 'equalto', true) | list }}"
```

## Best Practices

### 1. Use Descriptive Variable Names

```yaml
# Good
role_success: true
role_message: "Operation completed"
role_data: "{{ result_data }}"

# Avoid
success: true
msg: "Done"
data: "{{ result }}"
```

### 2. Return Structured Data

```yaml
# Good - structured return
role_result:
  success: true
  data:
    id: "{{ asset_id }}"
    type: "{{ asset_type }}"
    status: "registered"
  metadata:
    timestamp: "{{ ansible_date_time.iso8601 }}"
    version: "1.0"
```

### 3. Handle Errors Gracefully

```yaml
# In the role
- name: Set return values with error handling
  ansible.builtin.set_fact:
    role_result:
      success: "{{ operation_result.status == 200 }}"
      message: "{{ 'Success' if operation_result.status == 200 else 'Failed: ' + operation_result.msg }}"
      data: "{{ operation_result.json if operation_result.status == 200 else {} }}"
      error_code: "{{ operation_result.status if operation_result.status != 200 else 0 }}"
```

### 4. Use Conditional Returns

```yaml
# Return different values based on conditions
- name: Set success return values
  ansible.builtin.set_fact:
    role_result:
      success: true
      message: "Asset registered successfully"
  when: registration_result.status == 201

- name: Set already exists return values
  ansible.builtin.set_fact:
    role_result:
      success: true
      message: "Asset already registered"
      warning: true
  when: registration_result.status == 200

- name: Set failure return values
  ansible.builtin.set_fact:
    role_result:
      success: false
      message: "Registration failed"
      error: "{{ registration_result.msg }}"
  when: registration_result.status not in [200, 201]
```

## Real-World Example

Here's how the `asset_register` role has been updated to return values:

### Role Implementation

```yaml
# collections/ansible_collections/toolchain/fsm/roles/asset_register/tasks/main.yml
---
- name: Check if asset already registered
  ansible.builtin.uri:
    url: "{{ fsm.endpoint }}/api/v1/assets/{{ asset_id }}"
    method: GET
    headers:
      Content-Type: "application/json"
    status_code: [200, 404]
  register: asset_register_registration_result

- name: Request registration to FSM
  ansible.builtin.uri:
    url: "{{ fsm.endpoint }}/api/v1/assets"
    method: POST
    body: "{{ {'instance_id': asset_id, 'asset_type': asset_type} | to_json }}"
    headers:
      Content-Type: "application/json"
    status_code: 201
  when: asset_register_registration_result.status != 200
  register: asset_register_result

- name: Set role return values
  ansible.builtin.set_fact:
    asset_register_success: "{{ asset_register_registration_result.status == 200 or (asset_register_result is defined and asset_register_result.status == 201) }}"
    asset_register_message: "{{ 'Asset already registered' if asset_register_registration_result.status == 200 else 'Asset registered successfully' if asset_register_result is defined and asset_register_result.status == 201 else 'Asset registration failed' }}"
    asset_register_asset_id: "{{ asset_id }}"
    asset_register_asset_type: "{{ asset_type }}"
    asset_register_timestamp: "{{ ansible_date_time.iso8601 }}"
```

### Playbook Usage

```yaml
# playbooks/os/register_assets.yml
---
- name: Register assets
  ansible.builtin.include_role:
    name: toolchain.fsm.asset_register
  loop: [os1, app1]
  loop_control:
    loop_var: asset_id
  vars:
    asset_type: "simple_asset_type.yaml"
  register: asset_registration_results

- name: Display registration results
  ansible.builtin.debug:
    msg: |
      Asset Registration Results:
      {% for result in asset_registration_results.results %}
      - Asset: {{ result.ansible_facts.asset_register_asset_id }}
        Success: {{ result.ansible_facts.asset_register_success }}
        Message: {{ result.ansible_facts.asset_register_message }}
        Type: {{ result.ansible_facts.asset_register_asset_type }}
        Timestamp: {{ result.ansible_facts.asset_register_timestamp }}
      {% endfor %}
```

## Summary

- **Use `set_fact`** to return values from roles
- **Use `register`** to capture role results in playbooks
- **Return structured data** for better organization
- **Handle errors gracefully** with appropriate return values
- **Use descriptive variable names** to avoid conflicts
- **Test your return values** to ensure they work as expected

This approach allows you to create reusable roles that can communicate their results back to the calling playbook, enabling better error handling, conditional logic, and result processing.
