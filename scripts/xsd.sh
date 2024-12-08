#!/bin/bash

N=$1
XERCESC_DIR=$2
LIBXSD_FRONTEND_DIR=$3
LIBCUTL_DIR=$4

export PATH=$HOME/bin:$PATH

cat <<EOF | make -j"$N"
1
y
n
y




n
n
n
n
n
n
y
n
$XERCESC_DIR
1
n
$LIBXSD_FRONTEND_DIR

n
$LIBCUTL_DIR

EOF
