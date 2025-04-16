# Introductory Ansible Playbooks

Ansible is popular provision (system configuration) tool, available from https://docs.ansible.com

Ansible supports 2 main modes of operation:

1. `Playbook mode` - directly run tasks on specified host(s)
2. `Inventory mode` - gather list of hosts, roles, groups and run specific tasks on them

This example is for simple `Playbook mode` running locally. If you want to see
`Inventory mode` in action you can find example project on
https://github.com/hpaluch-pil/pil-ansible-roles

# Setup

Tested on Debian 12 and Fedora 41.

On Debian 12 Install:
```shell
sudo apt-get install ansible ansible-lint yamllint python3-apt
```

On Fedora 41 run:
```shell
sudo dnf install yamllint ansible python3-ansible-lint
```

# Example: install packages

> [!WARNING]
> If your `sudo` command requires password you have to add `-K` parameter to `ansible-playbook` commands
> (runs from scripts `dry-run.sh` and `run.sh`)

Now test package installation in dry mode running:
```shell
packages/dry-run.sh
```

Note: planned changes will be printed in "yellow" while matching state (no
operation needed) is printed in "green", skipped items are "cyan".

To really install packages on your local system run:

```shell
packages/run.sh
```

Note: you can notice variable `ansible_pkg_mgr` in
`packages/install-packages.yaml`. It depends on your Linux distribution and is
so called "facts". To list known "facts" on your system you can run provided
script `./gather-facts.sh`. Here is example how to extract package manager with
`jq` utility:

```shell
./gather-facts.sh | jq -r '.ansible_facts.ansible_pkg_mgr'
```

Linting:
- Warning! There are currently reported several Ansible Lint errors (but I don't like new verbose syntax pushed by RedHat)
- run: `packages/check-yaml.sh`

