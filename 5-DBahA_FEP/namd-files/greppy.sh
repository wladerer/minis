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

	#looking for  residue and strand of interest to be modified 
	if [[ "$line" =~ .*" D   $residue1_number ".* ]] && [[ "$line" =~ .*" $residue1_strand ".* ]]
	then
		for name in "${residue1_atoms[@]}" #iterate over user defined atoms of interest
		do
			if [[ "$line" =~ " $name " ]] 			
			then
				echo "$line" >> ${residue_names[0]} #populate file with found strings
				if [[ ${#name} == 3 ]]
				then
					sed -i "s/ ${name} G   D/${name}G AGH D/" ${residue_names[0]}
				else
					sed -i "s/$name  G   D/${name}G AGH D/" ${residue_names[0]} 
				
				fi
			fi
		done
	fi
done < NRAS-DBahA-single-top-step1.pdb


while read -r line 
do
	if [[ "$line" =~ " D   8 ".*"D1" ]]  
	then
		(cat ${residue_names[0]}) >> NRAS-DBahA-dual-top-step2.pdb
                rm ${residue_names[0]} 
		touch ${residue_names[0]}
        fi 	

	echo "$line" >> NRAS-DBahA-dual-top-step2.pdb	
	echo "Normal: $line"

	if [[ "$line" =~ " D   7 ".*"D1" ]]
	then
		sed -i "s/ADE/AGH/" NRAS-DBahA-dual-top-step2.pdb	
	fi

done < NRAS-DBahA-AVG-STR.pdb
