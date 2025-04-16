# Introductory Ansible Playbooks

Ansible is popular provision (system configuration) tool, available from https://docs.ansible.com

Ansible supports 2 main modes of operation:

1. `Playbook mode` - directly run tasks on specified host(s)
2. `Inventory mode` - gather list of hosts, roles, groups and run specific tasks on them

This example is for simple `Playbook mode` running locally. If you want to see
`Inventory mode` in action you can find example project on
https://github.com/hpaluch-pil/pil-ansible-roles

# Setup

Tested on Debian 12. Install:
```shell
sudo apt-get install ansible ansible-lint yamllint
```

# Example: install packages

Now test package installation in dry mode running:
```shell
packages/dry-run.sh
```
Note: planned changes will be printed in "yellow" while matching state (no operation needed) is printed
in "green"

To really install packages to your local system run:
```shell
packages/run.sh
```

Linting:
- Warning! There are currently reported several Ansible Lint errors (but I don't like new verbose syntax pushed by RedHat)
- run: `packages/check-yaml.sh`

