#!/bin/bash

N=$1

cat <<EOF | make -j"$N"
1
y
n
y




1


1
y
n
y





2

2
EOF
