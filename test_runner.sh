#!/bin/bash

docker run --rm \
	-v "${PWD}":"${PWD}" \
	scailfin/madgraph5-amc-nlo:debug-local "cd ${PWD}/tests; bash tests.sh"
tree -L 2 tests/
