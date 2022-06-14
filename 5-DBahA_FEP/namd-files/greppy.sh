#!/bin/bash

#declares residue names and name array
residue1="gua"
residue1_number=7 # Only works for now for single digit residue number
residue1_end=8
residue1_strand='D1'
residue2="cyt"
residue2_number=5
residue2_end=6
residue2_strand='D2'
declare -a residue_names=($residue1"_lines.txt" $residue2"_lines.txt")

#declares atoms of interest for each residue
declare -a residue1_atoms=('N9' 'C8' 'C4' 'N3' 'C5' 'C6' 'N7' 'N1' 'O6' 'C2' 'N2' 'H8' 'H1' 'H21' 'H22')
declare -a residue2_atoms=('N1' 'C2' 'C6' 'C5' 'C4' 'N3' 'N4' 'O2' 'H6' 'H5' 'H41' 'H42')

while read -r line 
do
	if [[ "$line" =~ .*" D   $residue1_end ".* ]] && [[ "$line" =~ .*" $residue1_strand ".* ]] 
	then
		(cat ${residue_names[0]}) >> NRAS-DBahA-dual-top-step2.pdb
                rm ${residue_names[0]} 
		touch ${residue_names[0]}
        fi 	

	if [[ "$line" =~ .*" D   $residue1_number ".* ]] && [[ "$line" =~ .*" $residue1_strand ".* ]]
	then
		echo "$line" >> ${residue_names[0]}
		for name in "${residue1_atoms[@]}"
		do
       			if [[ "$line" =~ .*" $name ".* ]] 			
			then
				sed -i "s/$name/${name}G/" ${residue_names[0]}
			fi
	
		done
	else
		echo "$line" >> NRAS-DBahA-dual-top-step2.pdb
		echo "Normal: $line"
	fi	
done < NRAS-DBahA-single-top-step1.pdb

#&& [[ ! "$line" =~ "ATOM       ${residue1_number} ".* ]] 


#two while loops bc single and AVG are conflicting, we need to pull from diff files

