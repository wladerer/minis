package require psfgen
resetpsf

topology ../toppar/top_all36_na.rtf
topology ../toppar/top_all36_prot.rtf
topology ../toppar/toppar_water_ions.str
topology ../toppar/top_all36_na-dual-topology.rtf
topology ../toppar/N6-dA-DBahA_IUPAC_atoms.str

pdbalias residue  DA ADE
pdbalias residue  DT THY
pdbalias residue  DC CYT
pdbalias residue  DG GUA

pdbalias residue  DA3  ADE
pdbalias residue  DT3  THY
pdbalias residue  DC3  CYT
pdbalias residue  DG3  GUA

pdbalias residue DA5  ADE
pdbalias residue DT5  THY
pdbalias residue DC5  CYT
pdbalias residue DG5  GUA

pdbalias atom    THY  C7 C5M
pdbalias atom    DT    C7 C5M
pdbalias atom    DT5   C7 C5M
pdbalias atom    DT3   C7 C5M

pdbalias atom    ADE  OP1  O1P
pdbalias atom    THY  OP1  O1P
pdbalias atom    GUA  OP1  O1P
pdbalias atom    CYT  OP1  O1P
pdbalias atom    ADE  OP2  O2P
pdbalias atom    THY  OP2  O2P
pdbalias atom    GUA  OP2  O2P
pdbalias atom    CYT  OP2  O2P

pdbalias atom    ADE  H5'1 H5'
pdbalias atom    ADE  H5'2 H5''
pdbalias atom    ADE  H2'1 H2'
pdbalias atom    ADE  H2'2 H2''
pdbalias atom    THY  H5'1 H5'
pdbalias atom    THY  H5'2 H5''
pdbalias atom    THY  H2'1 H2'
pdbalias atom    THY  H2'2 H2''
pdbalias atom    THY  H71 H51
pdbalias atom    THY  H72 H52
pdbalias atom    THY  H73 H53
pdbalias atom    GUA  H5'1 H5'
pdbalias atom    GUA  H5'2 H5''
pdbalias atom    GUA  H2'1 H2'
pdbalias atom    GUA  H2'2 H2''
pdbalias atom    CYT  H5'1 H5'
pdbalias atom    CYT  H5'2 H5''
pdbalias atom    CYT  H2'1 H2'
pdbalias atom    CYT  H2'2 H2''

# Build PSF of strand 1 and 2.
for {set i 1} {$i <= 2} {incr i} {
    # Load a molecule using nab1.pdb and nab2.pdb
    mol load pdb nab${i}.pdb               

    # Select just loaded molecule
    set sel [atomselect top "nucleic"] 

    # Build a segment (or molecule) based on the PDB file.
    # The segment id (segid) is D1 or D2.
    segment D${i}  {
        first 5TER
        last 3TER
        pdb nab${i}.pdb
    }

    # Now we modify residues by applying patches.
    foreach resid [join [lsort -unique [$sel get resid]]]  {
	# In CHARMM force field, nucleic acids are in RNA form.
	# We need to convert RNA to DNA by applying DEO5 or DEOX patch that deoxidize sugar group.
        if {$resid == 1} {
            patch DEO5 D${i}:$resid
	    #THIS SHOULD BE A SPECIAL PATCH FOR THE FIRST RESIDUE IN THE HELIX
        } else { 
            patch DEOX D${i}:$resid
        }

	# In each DNA strand, CpG cytosine has resid 15.
	# We apply patches to apply chemical modifications.
	# 5MC2: methylation
	# 5HMC: hydroxymethylation
	# 5FC2: formylation
	# 5CAC: carboxylation
	# 5NCC: neutral carboxylation
        #if {$resid == 15} {
        #    patch 5FC2 D${i}:$resid 
        #}

	# Resid 14 of D1 is thymine
	# 5HMU: hydroxyuracil
	# 5PMU: phosphomethyluracil
#	if {$resid == 14 && $i == 1 } {
#	    patch 5HMU D${i}:$resid
	    #SPECIAL PATCH FOR THE LAST RESIDUE IN THE HELIX??  THERE ARE NOT 14 RESIDUES...  NOT APPLIED...
	    #patch 5PMU D${i}:$resid
#	}
    }

    # Read coordinates from PDB file.
    coordpdb nab${i}.pdb D${i}

    # remove this object so that we can build another one in the next round.
    $sel delete
}

guesscoord ;# guess the coordinates of missing atoms
regenerate angles dihedrals ;# alway do this after patching.

writepsf dna.psf
writepdb dna.pdb

exit

