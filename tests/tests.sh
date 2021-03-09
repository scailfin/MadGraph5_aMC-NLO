#!/bin/bash

set -e
set -u
set -o pipefail

if [ -d top_mass_scan ]; then
	rm -r top_mass_scan
fi

if [ -f py.py ]; then
	rm py.py
fi

lhapdf install NNPDF23_lo_as_0130_qed
mg5_aMC test_top_mass_scan.mg5
