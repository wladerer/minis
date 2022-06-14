package require solvate
package require autoionize 

set prefix "dna_Na"

mol load psf ${prefix}_WI.psf pdb ${prefix}_WI.pdb

set sel [atomselect top "name N1 C2 N3 C4 C5 C6 N7 C8 N9 N1G C2G N3G C4G C5G C6G N7G C8G N9G N1C C2C N3C C4C C5C C6C N7C C8C N9C" ]
$sel set beta 1
set sel [atomselect top "all" ]
$sel writepdb ${prefix}_WIbeta.pdb

exit 
