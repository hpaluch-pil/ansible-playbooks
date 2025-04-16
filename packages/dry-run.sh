#!/bin/bash
set -xeuo pipefail
cd $(dirname $0)
ansible-playbook -b -c local -C install-packages.yaml
exit 0
