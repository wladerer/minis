#!/bin/bash 

/bin/grep ' D1 ' NRAS-DBahA-dual-top-step2.pdb > nab1.pdb
/bin/grep ' D2 ' NRAS-DBahA-dual-top-step2.pdb > nab2.pdb
vmd -dispdev text -e psfgen-dual-topology.tcl