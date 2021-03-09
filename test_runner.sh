#!/bin/bash

docker run
	--pull \
	--rm \
	-v "${PWD}":"${PWD}" \
	scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3 "cd ${PWD}/tests; bash tests.sh"
tree -L 2 tests/
