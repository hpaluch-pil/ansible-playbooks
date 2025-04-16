#!/bin/bash
set -xeuo pipefail
cd $(dirname $0)
ansible-playbook -b -c local install-packages.yaml
exit 0
