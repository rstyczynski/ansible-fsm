# Quick Start Guide - State-Driven Playbook Framework

## 🚀 Getting Started

### 1. Install Dependencies

```bash
# Install Ansible collections
ansible-galaxy collection install -r requirements.yml
```

### 2. Test the Framework

```bash
# Run the test script
./test_state_machine.sh
```

### 3. Basic Usage Examples

#### Check Current State
```bash
# Detect current state of a component
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=test_component \
  --tags state_context
```

#### Validate Transition
```bash
# Validate a state transition (dry run)
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=test_component \
  -e transition=RUNNING \
  --tags state_guard \
  --check
```

#### Execute Transition
```bash
# Execute a state transition
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=test_component \
  -e transition=RUNNING
```

#### Dry Run (Recommended for Testing)
```bash
# Test transition without making changes
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=test_component \
  -e transition=RUNNING \
  --check
```

## 🎯 Common Use Cases

### 1. Web Server Management

```bash
# Start web server
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=os \
  -e transition=RUNNING

# Put web server in maintenance
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=os \
  -e transition=MAINTENANCE

# Stop web server
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=os \
  -e transition=STOPPED
```

### 2. Database Management

```bash
# Start database
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=database \
  -e transition=RUNNING

# Put database in maintenance
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=database \
  -e transition=MAINTENANCE
```

## 🔧 Configuration

### Inventory Setup

Edit `inventory.yml` to add your actual hosts:

```yaml
production:
  hosts:
    your_server:
      ansible_host: your.server.ip
      component: "your_component"
      component_services:
        - "your_service"
      # ... other configuration
```

### Component Configuration

Define component-specific variables in your inventory:

```yaml
component_services: ["nginx", "php-fpm"]
component_processes: ["nginx", "php-fpm"]
component_ports: [80, 443]
component_dependencies: ["systemd-resolved", "rsyslog"]
component_maintenance_window:
  start: 2
  end: 4
```

## 🛠️ Troubleshooting

### Common Issues

1. **"no hosts matched"**
   - Check your inventory file
   - Verify host definitions
   - Use `--limit localhost` for local testing

2. **Permission denied**
   - Ensure SSH keys are configured
   - Check `ansible_user` and `ansible_become` settings

3. **State detection fails**
   - Verify component services are defined
   - Check custom detector scripts
   - Review fact file permissions

### Debug Mode

```bash
# Enable verbose output
ansible-playbook state_transition_playbook.yml \
  -i inventory.yml \
  -e component=test_component \
  -e transition=RUNNING \
  -vvv
```

## 📚 Next Steps

1. **Customize Components**: Edit `group_vars/all/state_machines.yml`
2. **Add Custom Detectors**: Create scripts in `examples/detectors/`
3. **Configure Guard Conditions**: Modify role variables
4. **Set Up Monitoring**: Monitor state fact files
5. **Implement CI/CD**: Integrate with your deployment pipeline

## 🆘 Support

- Check the main `README.md` for detailed documentation
- Review role-specific README files in `roles/*/README.md`
- Examine examples in the `examples/` directory
- Test with `--check` flag before running actual transitions
