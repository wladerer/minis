#!/bin/bash

resOld=$1
resPos=$2
resNew=$3
resStr="$4"
penultimateLine=$(tail -2 NRAS-DBahA-AVG-STR.pdb | head -n 1)
penultimateArray=($penultimateLine)

resN=penultimateArray[5] #Total number of residues in the file
compPos="$(($resN + 1 - $resPos))"
resEnd="$(($resPos + 1))"
compEnd="$(($compPos + 1))"


#Determines the complement base's strand
if [ $resStr = 'D1' ]
    then compStr='D2'
else compStr='D1'
fi


#Determines complement's identity
if [[ $resNew = 'A' ]]; then compNew='T'  
elif [[ $resNew = 'T' ]]; then compNew='A'
elif [[ $resNew = 'G' ]]; then compNew='C'
elif [[ $resNew = 'C' ]]; then compNew='G';fi


if [[ $resOld = 'A' ]]; then resOldTLC='ADE' ; compOldTLC='THY' ; 
elif [[ $resOld = 'T' ]]; then resOldTLC='THY' ; compOldTLC='ADE' ;
elif [[ $resOld = 'G' ]]; then resOldTLC='GUA' ; compOldTLC='CYT' ;
elif [[ $resOld = 'C' ]]; then resOldTLC='CYT' ; compOldTLC='GUA' ; fi


#The following creates our Chimera script that then creates the single-top-step1 pdb file
cat << END > swapna.com
swapna ${resNew} :${resPos} & @/pdbSegment=${resStr}
sel :${resPos} & @/pdbSegment=${resStr}
addh
swapna ${compNew} :${compPos} & @/pdbSegment=${compStr}
sel :${compPos} & @/pdbSegment=${compStr}
addh
write format pdb #0 NRAS-DBahA-single-top-step1.pdb
END

chimera --nogui --silent NRAS-DBahA-AVG-STR.pdb swapna.com

#declares atoms of interest for each residue


declare -a G_atoms=('N9' 'C8' 'C4' 'N3' 'C5' 'C6' 'N7' 'N1' 'O6' 'C2' 'N2' 'H8' 'H1' 'H21' 'H22')
declare -a C_atoms=('N1' 'C2' 'C6' 'C5' 'C4' 'N3' 'N4' 'O2' 'H6' 'H5' 'H41' 'H42')
declare -a T_atoms=('N1' 'C6' 'H6' 'C2' 'O2' 'N3' 'H3' 'C4' 'O4' 'C5' 'C5M' 'H51' 'H52' 'H53')
declare -a A_atoms=('N9' 'C5' 'N7' 'C8' 'H8' 'N1' 'C2' 'H2' 'N3' 'C4' 'C6' 'N6' 'H61' 'H62')


if [[ $resNew = 'A' ]]; then resAtoms=${A_atoms[@]}; compAtoms=${T_atoms[@]}
elif [[ $resNew = 'T' ]]; then resAtoms=${T_atoms[@]}; compAtoms=${A_atoms[@]}
elif [[ $resNew = 'G' ]]; then resAtoms=${G_atoms[@]}; compAtoms=${C_atoms[@]}
elif [[ $resNew = 'C' ]]; then resAtoms=${C_atoms[@]}; compAtoms=${G_atoms[@]}; fi

touch "${resNew}_slice.txt"
touch "${compNew}_slice.txt"

while read -r line 
do

	#looking for  residue and strand of interest to be modified 
	if [[ "$line" =~ .*" D   $resPos ".* ]] && [[ "$line" =~ .*" $resStr ".* ]]
	then
		for name in ${resAtoms[@]} #iterate over user defined atoms of interest
		do
			echo $name
			if [[ "$line" =~ " $name " ]] 			
			then
				echo 'found matching line'
				echo "$line" >> "${resNew}_slice.txt" #populate file with found strings
				if [[ ${#name} == 3 ]]
				then
					echo 'added to file'
					sed -i "s/ ${name} ${resNew}   D/${name}${resNew} ${resOld}${resNew}H D/" "${resNew}_slice.txt"
				else
					echo 'added to file'
					sed -i "s/$name  ${resNew}   D/${name}${resNew} ${resOld}${resNew}H D/" "${resNew}_slice.txt" 
				
				fi
			fi
		done
	fi

		#looking for residue2 and strand2 of interest to be modified 
	if [[ "$line" =~ .*" D   $compPos ".* ]] && [[ "$line" =~ .*" $compStr ".* ]]
	then
		for name in ${compAtoms[@]} #iterate over user defined atoms of interest
		do
			if [[ "$line" =~ " $name " ]] #checks to see if the atom is in the line		
			then
				echo "$line" >> "${compNew}_slice.txt" #populate file with found strings
				if [[ ${#name} == 3 ]]
				then
					sed -i "s/ ${name} ${compNew}   D/${name}${compNew} ${compOld}${compNew}H D/" "${compNew}_slice.txt"
				else
					sed -i "s/${name}  ${compNew}   D/${name}${compNew} ${compOld}${compNew}H D/" "${compNew}_slice.txt" 
				
				fi
			fi
		done
	fi
done < NRAS-DBahA-single-top-step1.pdb


while read -r line 
do
	#new residue
	if [[ "$line" =~ " D   ${resEnd} ".*${resStr} ]]  
	then
		(cat "${resNew}_slice.txt") >> NRAS-DBahA-dual-top-step2.pdb
                rm "${resNew}_slice.txt" 
		touch "${resNew}_slice.txt"
        fi 	

	#compliment
	if [[ "$line" =~ " D   ${compEnd} ".*${compStr} ]]  
	then
		(cat "${compNew}_slice.txt") >> NRAS-DBahA-dual-top-step2.pdb
                rm "${compNew}_slice.txt" 
		touch "${compNew}_slice.txt"
        fi 	

	echo "$line" >> NRAS-DBahA-dual-top-step2.pdb	



	if [[ "$line" =~ " D   ${resPos} ".*${resStr} ]]
	then
		sed -i "s/${resOldTLC}/${resOld}${resNew}H/" NRAS-DBahA-dual-top-step2.pdb	
	fi

	if [[ "$line" =~ " D   ${compPos} ".*${compStr} ]]
	then
		sed -i "s/${compOldTLC}/${compOld}${compNew}H/" NRAS-DBahA-dual-top-step2.pdb	
	fi

done < NRAS-DBahA-AVG-STR.pdb

rm swapna.com
rm "${resNew}_slice.txt"
rm "${compNew}_slice.txt"