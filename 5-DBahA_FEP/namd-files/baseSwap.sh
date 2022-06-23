#!/bin/bash
#declares residue names and name array
residue1="gua"
new_residue1="AGH"
new_residue2="TCH"
residue1_abbrev="G"
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
					sed -i "s/ ${name} ${residue1_abbrev}   D/${name}${residue1_abbrev} AGH D/" ${residue_names[0]}
				else
					sed -i "s/$name  ${residue1_abbrev}   D/${name}${residue1_abbrev} AGH D/" ${residue_names[0]} 
				
				fi
			fi
		done
	fi

		#looking for residue2 and strand2 of interest to be modified 
	if [[ "$line" =~ .*" D   $residue2_number ".* ]] && [[ "$line" =~ .*" $residue2_strand ".* ]]
	then
		for name in "${residue2_atoms[@]}" #iterate over user defined atoms of interest
		do
			if [[ "$line" =~ " $name " ]] #checks to see if the atom is in the line		
			then
				echo "$line" >> ${residue_names[1]} #populate file with found strings
				if [[ ${#name} == 3 ]]
				then
					sed -i "s/ ${name} ${residue2_abbrev}   D/${name}${residue2_abbrev} TCH D/" ${residue_names[1]}
				else
					sed -i "s/$name  ${residue2_abbrev}   D/${name}${residue2_abbrev} TCH D/" ${residue_names[1]} 
				
				fi
			fi
		done
	fi
done < NRAS-DBahA-single-top-step1.pdb


while read -r line 
do
	#residue 1
	if [[ "$line" =~ " D   ${residue1_end} ".*${residue1_strand} ]]  
	then
		(cat ${residue_names[0]}) >> NRAS-DBahA-dual-top-step2.pdb
                rm ${residue_names[0]} 
		touch ${residue_names[0]}
        fi 	

	#residue2
	if [[ "$line" =~ " D   ${residue2_end} ".*${residue2_strand} ]]  
	then
		(cat ${residue_names[1]}) >> NRAS-DBahA-dual-top-step2.pdb
                rm ${residue_names[1]} 
		touch ${residue_names[1]}
        fi 	

	echo "$line" >> NRAS-DBahA-dual-top-step2.pdb	

	if [[ "$line" =~ " D   ${residue1_number} ".*${residue1_strand} ]]
	then
		sed -i "s/ADE/AGH/" NRAS-DBahA-dual-top-step2.pdb	
	fi

	if [[ "$line" =~ " D   ${residue2_number} ".*${residue2_strand} ]]
	then
		sed -i "s/THY/TCH/" NRAS-DBahA-dual-top-step2.pdb	
	fi

done < NRAS-DBahA-AVG-STR.pdb
