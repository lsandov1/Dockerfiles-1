#!/bin/bash -e

IMAGE="xeon-clearlinux-dars-apache"
DIR=$(dirname $(readlink -f "$0"))

. "${DIR}/../../../../script/shell.sh"
