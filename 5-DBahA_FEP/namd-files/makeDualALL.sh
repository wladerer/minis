#!/bin/bash

rm NRAS-DBahA-single-top-step1.pdb 
rm NRAS-DBahA-dual-top-step2.pdb

resOld=$1
resPos=$2
resNew=$3
resStr="$4"

#This is bash error handling at its finest
	re='^[0-9]+$'
	if [[ "$resOld" != [ATGC] ]]; then echo 'error: First argument must be: A,T,G,C' ; exit ;fi
    if ! [[ $resPos =~ $re ]]; then echo "error: Second argument must be an integer" >&2; exit 1 ; fi
	if [[ "$resNew" != [ATGC] ]]; then echo 'error: Third argument must be: A,T,G,C' ; exit ; fi


penultimateLine=$(tail -2 NRAS-DBahA-AVG-STR.pdb | head -n 1)
penultimateArray=($penultimateLine)

resN=penultimateArray[5] #Total number of residues in the file
compPos="$(($resN + 1 - $resPos))"
resEnd="$(($resPos + 1))"
compEnd="$(($compPos + 1))"


#More error handling
if [ $resPos -gt $(($resN)) ]; then echo "error: residue ${resPos} is out of range ($((${resN})))" ; exit ; fi

#Determines the complement base's strand
if [ $resStr = 'D1' ]
    then compStr='D2'
else compStr='D1'
fi


#Determines complement's identity
if [[ $resNew = 'A' ]]; then compNew='T'; compNewTLC='THY';
elif [[ $resNew = 'T' ]]; then compNew='A'; compNewTLC='ADE';
elif [[ $resNew = 'G' ]]; then compNew='C'; compNewTLC='CYT';
elif [[ $resNew = 'C' ]]; then compNew='G'; compNewTLC='GUA'; fi


if [[ $resOld = 'A' ]]; then resOldTLC='ADE' ; compOldTLC='THY' ;  compOld='T'
elif [[ $resOld = 'T' ]]; then resOldTLC='THY' ; compOldTLC='ADE' ; compOld='A'
elif [[ $resOld = 'G' ]]; then resOldTLC='GUA' ; compOldTLC='CYT' ; compOld='C'
elif [[ $resOld = 'C' ]]; then resOldTLC='CYT' ; compOldTLC='GUA' ; compOld='G'; fi


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


if [[ $resNew = 'A' ]]; then resNewTLC='ADE'; resAtoms=${A_atoms[@]}; compAtoms=${T_atoms[@]}
elif [[ $resNew = 'T' ]]; then resNewTLC='THY'; resAtoms=${T_atoms[@]}; compAtoms=${A_atoms[@]}
elif [[ $resNew = 'G' ]]; then resNewTLC='GUA'; resAtoms=${G_atoms[@]}; compAtoms=${C_atoms[@]}
elif [[ $resNew = 'C' ]]; then resNewTLC='CYT'; resAtoms=${C_atoms[@]}; compAtoms=${G_atoms[@]}; fi

touch "${resNew}_slice.txt"
touch "${compNew}_slice.txt"

while read -r line 
do

	#looking for  residue and strand of interest to be modified 
	if [[ "$line" =~ .*" D   $resPos ".* ]] && [[ "$line" =~ .*" $resStr ".* ]]
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


#adds lines into a new dual-top file line by line
#determines if the new line is unedited or not
#if the line needs to be edited, then the new lines are inserted from the slice text files
while read -r line 
do

	if [[ "$line" =~ " D   ${resEnd} ".*${resStr} ]]  
	then
		(cat "${resNew}_slice.txt") >> NRAS-DBahA-dual-top-step2.pdb
                rm "${resNew}_slice.txt" 
		touch "${resNew}_slice.txt"
        fi 	

	if [[ "$line" =~ " D   ${compEnd} ".*${compStr} ]]  
	then
		(cat "${compNew}_slice.txt") >> NRAS-DBahA-dual-top-step2.pdb
                rm "${compNew}_slice.txt" 
		touch "${compNew}_slice.txt"
        fi 	

	echo "$line" >> NRAS-DBahA-dual-top-step2.pdb	

	pattern1=".* ${resOldTLC} D .* ${resPos} .* ${resStr}" #regex patterns to replace the old three letter codes
	pattern2=".* ${compOldTLC} D .* ${compPos} .* ${compStr}"


	if [[ $line =~ $pattern1 ]] && [[ $resPos -gt 9 ]]
	then
		sed -i -r "s# ${resOldTLC} D  ${resPos} # ${resOld}${resNew}H D  ${resPos} #" NRAS-DBahA-dual-top-step2.pdb	
	elif [[ $line =~ $pattern1 ]]
	then
		sed -i -r "s# ${resOldTLC} D   ${resPos} # ${resOld}${resNew}H D   ${resPos} #" NRAS-DBahA-dual-top-step2.pdb	
	fi

	if [[ $line =~ $pattern2 ]] && [[ $compPos -gt 9 ]]
	then
		sed -i -r "s# ${compOldTLC} D  ${compPos} # ${compOld}${compNew}H D  ${compPos} #" NRAS-DBahA-dual-top-step2.pdb	
	elif [[ $line =~ $pattern2 ]]
	then
		sed -i -r "s# ${compOldTLC} D   ${compPos} # ${compOld}${compNew}H D   ${compPos} #" NRAS-DBahA-dual-top-step2.pdb	
	fi

done < NRAS-DBahA-AVG-STR.pdb

rm swapna.com
rm "${resNew}_slice.txt"
rm "${compNew}_slice.txt"

resDualTLC="${resOld}${resNew}H"
compDualTLC="${compOld}${compNew}H"

echo "Swapping residue ${resPos} (${resOldTLC}) in strand ${resStr} for ${resNewTLC}"
echo "Swapping resiude ${compPos} (${compOldTLC}) in strand ${compStr} for ${compNewTLC}"
echo "Two files have been prepared -- single and dual topology"
echo "*** Check that the requested input has been satisfactorily executed before the next step ***"

echo "|"
echo "|"
echo "|"
echo "Would you like to continue? [y/n]"

while true; do
	read response
	case $response in 
		''|[yY]*)
			continue=true
			break;;
		[nN]*)
			continue=false
			break;;
		*)
			echo "Invalid Input";;
	esac
done

if $continue
then
	echo "|"
	echo "Making FEP using vmd . . ."
	echo "|"

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
fi

echo "|"
echo "|"
echo "|"
echo "Would you like to continue? [y/n]"

while true; do
	read response
	case $response in 
		''|[yY]*)
			continue=true
			break;;
		[nN]*)
			continue=false
			break;;
		*)
			echo "Invalid Input";;
	esac
done

if $continue
then
	echo "Changing BETA column and defining extra bonds between terminal GUA:CYT base pairs  . . ."

	if [[ $resOld = 'A' ]]; then resOldAtoms=${A_atoms[@]}; compOldAtoms=${T_atoms[@]}
	elif [[ $resOld = 'T' ]]; then resOldAtoms=${T_atoms[@]}; compOldAtoms=${A_atoms[@]}
	elif [[ $resOld = 'G' ]]; then resOldAtoms=${G_atoms[@]}; compOldAtoms=${C_atoms[@]}
	elif [[ $resOld = 'C' ]]; then resOldAtoms=${C_atoms[@]}; compOldAtoms=${G_atoms[@]}; fi


	if [[ $resNew = 'A' ]]; then resNewAtoms=${A_atoms[@]}; compNewAtoms=${T_atoms[@]}
	elif [[ $resNew = 'T' ]]; then resNewAtoms=${T_atoms[@]}; compNewAtoms=${A_atoms[@]}
	elif [[ $resNew = 'G' ]]; then resNewAtoms=${G_atoms[@]}; compNewAtoms=${C_atoms[@]}
	elif [[ $resNew = 'C' ]]; then resNewAtoms=${C_atoms[@]}; compNewAtoms=${G_atoms[@]}; fi

	for ATOM in ${resOldAtoms[@]} 
	do
		pattern=".* ${ATOM} .*${resDualTLC} .* ${resStr}"
		line=$( grep "$pattern" dna_Na_WI.fep) 
		new_line=${line/  0.00      / -1.00      }
		line_number=$( grep -n "$pattern" dna_Na_WI.fep | cut -f1 -d: )
		sed -i -r "${line_number}s#${line}#${new_line}#" dna_Na_WI.fep
	done

	for ATOM in ${resNewAtoms[@]} 
	do
		pattern=".* ${ATOM}${resNew} .*${resDualTLC} .* ${resStr}"
		line=$( grep "$pattern" dna_Na_WI.fep) 
		new_line=${line/  0.00      /  1.00      }
		line_number=$( grep -n "$pattern" dna_Na_WI.fep | cut -f1 -d: )
		sed -i -r "${line_number}s#${line}#${new_line}#" dna_Na_WI.fep

	done

	for ATOM in ${compOldAtoms[@]} 
	do
		pattern=".* ${ATOM} .*${compDualTLC} .* ${compStr}"
		line=$( grep "$pattern" dna_Na_WI.fep) 
		new_line=${line/  0.00      / -1.00      }
		line_number=$( grep -n "$pattern" dna_Na_WI.fep | cut -f1 -d: )
		sed -i -r "${line_number}s#${line}#${new_line}#" dna_Na_WI.fep

	done

	for ATOM in ${compNewAtoms[@]} 
	do
		pattern=".* ${ATOM}${compNew} .*${compDualTLC} .* ${compStr}"
		line=$( grep "$pattern" dna_Na_WI.fep) 
		new_line=${line/  0.00      /  1.00      }
		line_number=$( grep -n "$pattern" dna_Na_WI.fep | cut -f1 -d: )
		sed -i -r "${line_number}s#${line}#${new_line}#" dna_Na_WI.fep
	done



	pattern=".* N3  CYT D   1 .* D1"
	grep -n "$pattern" dna_Na_WI.fep | cut -f3 -d: 

	line=($(grep -n ".* N3  CYT D   1 .* D1" dna_Na_WI.fep))
	N3_CYT1_D1=$((${line[1]}-1))

	line=($(grep -n ".* N1  GUA D  11 .* D2" dna_Na_WI.fep))
	N1_GUA11_D2=$((${line[1]}-1))

	line=($(grep -n ".* N1  GUA D  11 .* D1" dna_Na_WI.fep))
	N1_GUA11_D1=$((${line[1]}-1))

	line=($(grep -n ".* N3  CYT D   1 .* D2" dna_Na_WI.fep))
	N3_CYT1_D2=$((${line[1]}-1))

	cat << END > extrabonds.txt
bond ${N3_CYT1_D1} ${N1_GUA11_D2} 4 3.00
bond ${N1_GUA11_D1} ${N3_CYT1_D2} 4 3.00
END

fi

echo "SUCCESS!"