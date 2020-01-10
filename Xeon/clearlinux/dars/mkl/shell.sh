#!/bin/bash -e

IMAGE="xeon-clearlinux-dars-mkl"
DIR=$(dirname $(readlink -f "$0"))

. "${DIR}/../../../../script/shell.sh"
