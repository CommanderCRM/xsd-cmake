#!/bin/bash

N=$1
CUTL_DIR=$2
XERCESC_DIR=$3

cat <<EOF | make -j"$N"
1
y
n
y




1


n
$CUTL_DIR

n
$XERCESC_DIR
1
g++
2
EOF
