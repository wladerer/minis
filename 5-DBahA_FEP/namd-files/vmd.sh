#!/bin/bash 

grep ' D1' NRAS-DBahA-dual-top-step2.pdb > nab1.pdb
grep ' D2' NRAS-DBahA-dual-top-step2.pdb > nab2.pdb
vmd -dispdev text -e psfgen-dual-topology.tcl
vmd -psf dna.psf -pdb dna.pdb

vmd -dipsdev text -e vmd.inp 
