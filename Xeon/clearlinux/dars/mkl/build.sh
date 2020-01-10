#!/bin/bash -e

IMAGE="xeon-clearlinux-dars-mkl"
VERSION="19.11"
DIR=$(dirname $(readlink -f "$0"))

. "${DIR}/../../../../script/build.sh"
