package require solvate
package require autoionize 

set prefix "dna_Na"

mol load psf ${prefix}.psf pdb ${prefix}.pdb
set all [atomselect top all]
set xyz [measure center $all]
set xyz [vecinvert $xyz]
$all moveby $xyz
$all writepdb ${prefix}.pdb
mol delete top

solvate ${prefix}.psf ${prefix}.pdb -minmax {{-35 -35 -35 } { 35  35  35 }} -o ${prefix}_W

autoionize -psf ${prefix}_W.psf -pdb ${prefix}_W.pdb -sc 0.10  -cation SOD -o ${prefix}_WI

exit 
