#!/bin/bash
set -euo pipefail
cd $(dirname $0)
[ $# -gt 0 ] || {
	echo "Usage: $0 [args] playbook-file.yaml" >&2
	exit 1
}
set -x
ansible-playbook -b -c local -C "$@"
set +x
exit 0
