#!/bin/bash
set -euo pipefail
cd $(dirname $0)
for i in *.yaml
do
	set -x
	yamllint "$i" && ansible-lint "$i"
	set +x
done
exit 0
