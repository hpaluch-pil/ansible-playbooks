#!/bin/bash
# Gather Ansible facts on localhost
set -euo pipefail
# format with 'jq' if output is terminal
fmt_command=jq
# if output is not terminal, just copy it with cat...
[ -t 1 ] || fmt_command=cat

# we have to fix 1st line of output to be valid json:
ansible localhost -m setup | sed '1s/.*{/{/' | $fmt_command
exit 0
