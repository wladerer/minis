#!/bin/bash

touch linescyto.txt

for name in 'N1' 'C2' 'C6' 'C5' 'C4' 'N3' 'N4' '02' 'H6' 'H5' 'H41' 'H42'
do
	grep -E "ATOM.*$name.* 5 .*D2" NRAS-DBahA-single-top-step1.pdb >> linescyto.txt
done
