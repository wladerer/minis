#!/bin/bash

# $1 = base abbreviation (G,A,T,C)
# $2 = residue number
# $3 = strand

getInfo () {
    keywords=$(sed $1!d baseSwap.inp)
}

swap () {
    echo "swapna $1 :$2 & @/pdbSegment=$3" >> swap.txt
    echo "sel :$2 & @/pdbSegment=$3" >> swap.txt
    echo "addh" >> swap.txt
}


