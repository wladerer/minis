#!/bin/bash 

grep ' D1' NRAS-DBahA-dual-top-step2.pdb > nab1.pdb
grep ' D2' NRAS-DBahA-dual-top-step2.pdb > nab2.pdb

vmd -dispdev text -e psfgen-dual-topology.tcl
vmd -dispdev text -psf dna.psf -pdb dna.pdb -e vmd.tk

mv cionize-ions_1-SOD.pdb nab_Na3.pdb 
sed -i 's/   SOD/  D3 SOD/' nab_Na3.pdb

mv nab1.pdb nab_Na1.pdb
mv nab2.pdb nab_Na2.pdb

vmd -dispdev text -e psfgen_Na-dual-topology.tcl
vmd -dispdev text -e solvate_70box_100mM.tcl
vmd -dispdev text -e restraint_NAs_only-dual-topology.tcl

cp dna_Na_WI.pdb dna_Na_WI.fep