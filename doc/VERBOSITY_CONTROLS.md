# State Map Role Verbosity Controls

The state map role has been optimized to reduce verbose output while maintaining functionality. You can control the verbosity using the following variables:

## Verbosity Control Variables

### `state_map_verbose` (default: `false`)
Controls detailed state map loading information:
- Shows found state files list
- Shows detailed loading results with full map structure
- Shows component list and metadata

### `state_display_verbose` (default: `true`)
Controls component state display information:
- Shows component state details
- Shows reading method and timestamps
- Shows metadata and file paths

### `state_loading_verbose` (default: `false`)
Controls individual file loading details:
- Shows per-file loading progress
- Shows parsing details

## Usage Examples

### Quiet Mode (Minimal Output)
```yaml
- name: "Load states quietly"
  hosts: all
  vars:
    state_map_verbose: false
    state_display_verbose: false
    state_loading_verbose: false
  roles:
    - state_context
```

### Verbose Mode (Full Output)
```yaml
- name: "Load states with full details"
  hosts: all
  vars:
    state_map_verbose: true
    state_display_verbose: true
    state_loading_verbose: true
  roles:
    - state_context
```

### Default Mode (Balanced)
```yaml
- name: "Load states with balanced output"
  hosts: all
  # Uses defaults: state_map_verbose=false, state_display_verbose=true, state_loading_verbose=false
  roles:
    - state_context
```

## Command Line Override

You can also override these variables from the command line:

```bash
# Quiet mode
ansible-playbook playbook.yml -e state_map_verbose=false -e state_display_verbose=false

# Verbose mode
ansible-playbook playbook.yml -e state_map_verbose=true -e state_display_verbose=true
```

## Benefits

- **Reduced Output**: By default, only essential information is shown
- **Flexible Control**: Fine-grained control over different types of output
- **Backward Compatible**: Existing playbooks continue to work unchanged
- **Performance**: Less output means faster execution and easier log parsing
