#!/bin/bash

declare -a METAL=( "Os" "Re" "Ta" "W" )

INPUTDIR=/p/work1/wladerer/HSE06_diborides/vasp_inputs
POTDIR=/p/work1/wladerer/HSE06_diborides/vasp_inputs/POTCARs
POSDIR=/p/work1/wladerer/HSE06_diborides/vasp_inputs/POSCAR_scaffolds
SUBMIT=/p/work1/wladerer/HSE06_diborides/vasp_inputs/vasp.pbs
KPOINTS=/p/work1/wladerer/HSE06_diborides/vasp_inputs/KPOINTS


mkdir Os
mkdir Re
mkdir Ta
mkdir W

for dir in */
do

    cd $dir

    mkdir boat
    mkdir ff
    mkdir fj
    mkdir jj
   
    cd ../

done


for metal in ${METAL[@]}
do 
    cd $metal

        cd ff

            file_name=${metal}_ff
            cp $KPOINTS .
            cp $POSDIR/Ta_POSCAR ./POSCAR
            cp $POTDIR/${metal}B_POTCAR ./POTCAR
            cp $SUBMIT  .

            sed -i "s#M3T4L#${metal}#" POSCAR 
            sed -i 's#&&&#'`pwd`'#' vasp.pbs
            sed -i "s#vasptest#${file_name}#" vasp.pbs
            
            qsub vasp.pbs


        cd ..

        cd boat

            file_name="${metal}_boat"
            cp $KPOINTS .
            cp $POSDIR/Os_POSCAR ./POSCAR
            cp $POTDIR/${metal}B_POTCAR ./POTCAR
            cp $SUBMIT  .

            sed -i "s#M3T4L#${metal}#" POSCAR 
            sed -i 's#&&&#'`pwd`'#' vasp.pbs
            sed -i "s#vasptest#${file_name}#" vasp.pbs

            qsub vasp.pbs

            cd ..

        cd fj

            file_name="${metal}_fj"
            cp $KPOINTS .
            cp $POSDIR/W_POSCAR ./POSCAR
            cp $POTDIR/${metal}B_POTCAR ./POTCAR
            cp $SUBMIT  .

            sed -i "s#M3T4L#${metal}#" POSCAR 
            sed -i 's#&&&#'`pwd`'#' vasp.pbs
            sed -i "s#vasptest#${file_name}#" vasp.pbs

            qsub vasp.pbs

            cd ..

        cd jj

            file_name="${metal}_jj"
            cp $KPOINTS .
            cp $POSDIR/Re_POSCAR ./POSCAR
            cp $POTDIR/${metal}B_POTCAR ./POTCAR
            cp $SUBMIT  .

            sed -i "s#M3T4L#${metal}#" POSCAR 
            sed -i 's#&&&#'`pwd`'#' vasp.pbs
            sed -i "s#vasptest#${file_name}#" vasp.pbs

            qsub vasp.pbs

            cd ..

        cd ..

done
