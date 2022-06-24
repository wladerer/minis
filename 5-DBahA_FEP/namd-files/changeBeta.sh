#!/bin/bash

if [ ! -f input.log ]
then
    echo "input.log file is missing, either recover file or re-run baseSwap.sh"
    exit 
fi

resOld=$(sed -n '1p' input.log )
resPos=$(sed -n '2p' input.log )
resNew=$(sed -n '3p' input.log )
resStr=$(sed -n '4p' input.log )
compPos=$(sed -n '5p' input.log )
resDualTLC=$(sed -n '6p' input.log )
compDualTLC=$(sed -n '7p' input.log )
compOld=$(sed -n '8p' input.log )
compNew=$(sed -n '9p' input.log )


declare -a G_atoms=('N9' 'C8' 'C4' 'N3' 'C5' 'C6' 'N7' 'N1' 'O6' 'C2' 'N2' 'H8' 'H1' 'H21' 'H22')
declare -a C_atoms=('N1' 'C2' 'C6' 'C5' 'C4' 'N3' 'N4' 'O2' 'H6' 'H5' 'H41' 'H42')
declare -a T_atoms=('N1' 'C6' 'H6' 'C2' 'O2' 'N3' 'H3' 'C4' 'O4' 'C5' 'C5M' 'H51' 'H52' 'H53')
declare -a A_atoms=('N9' 'C5' 'N7' 'C8' 'H8' 'N1' 'C2' 'H2' 'N3' 'C4' 'C6' 'N6' 'H61' 'H62')


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