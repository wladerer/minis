#!/bin/bash

get_vars () {
        
NAME=$(sed -n '1p' $1)
ABBREV=$(sed -n '2p' $1)
STRING=$(sed -n '3p' $1)
IFS=' ' read -ra ATOMS <<< $STRING
}

