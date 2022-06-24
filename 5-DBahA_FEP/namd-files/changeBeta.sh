#!/bin/bash

declare -a G_atoms=('N9' 'C8' 'C4' 'N3' 'C5' 'C6' 'N7' 'N1' 'O6' 'C2' 'N2' 'H8' 'H1' 'H21' 'H22')
declare -a C_atoms=('N1' 'C2' 'C6' 'C5' 'C4' 'N3' 'N4' 'O2' 'H6' 'H5' 'H41' 'H42')
declare -a T_atoms=('N1' 'C6' 'H6' 'C2' 'O2' 'N3' 'H3' 'C4' 'O4' 'C5' 'C5M' 'H51' 'H52' 'H53')
declare -a A_atoms=('N9' 'C5' 'N7' 'C8' 'H8' 'N1' 'C2' 'H2' 'N3' 'C4' 'C6' 'N6' 'H61' 'H62')

while read -r line 
do

	#looking for  residue and strand of interest to be modified 
	if [[ "$line" =~ .*" D   $resNewTLC ".* ]] && [[ "$line" =~ .*" $resStr ".* ]]
	then
		for name in ${resAtoms[@]} #iterate over user defined atoms of interest
		do
			if [[ "$line" =~ " $name " ]] 			
			then
				echo "$line" >> "${resNew}_slice.txt" #populate file with found strings
				if [[ ${#name} == 3 ]]
				then
					sed -i "s/ ${name} ${resNew}   D/${name}${resNew} ${resOld}${resNew}H D/" "${resNew}_slice.txt"
				else
					sed -i "s/$name  ${resNew}   D/${name}${resNew} ${resOld}${resNew}H D/" "${resNew}_slice.txt" 
				fi
			fi
		done
	fi


done < dna_Na_WI.fep
