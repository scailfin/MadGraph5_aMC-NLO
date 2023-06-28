#!/bin/bash
# c.f. https://github.com/scailfin/MadGraph5_aMC-NLO/pull/72

set -e
set -u
set -o pipefail

if [ -d bhabha ]; then
	rm -r bhabha
fi

if [ -f py.py ]; then
	rm py.py
fi

mg5_aMC bhabha_scattering.mg5
./bhabha/bin/madevent launch -f
