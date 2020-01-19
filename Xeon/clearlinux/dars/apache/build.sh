#!/bin/bash -e

IMAGE="xeon-clearlinux-dars-apache"
VERSION="19.11"
DIR=$(dirname $(readlink -f "$0"))

. "${DIR}/../../../../script/build.sh"
