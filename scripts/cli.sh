#!/bin/bash

N=$1
CUTL_DIR=$2

cat <<EOF | make -j"$N"
1
y
n
y




n
$CUTL_DIR

EOF
