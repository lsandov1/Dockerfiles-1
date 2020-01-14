#!/bin/bash -e

IMAGE="xeon-clearlinux-mers"
VERSION="19.11"
DIR=$(dirname $(readlink -f "$0"))

. "${DIR}/../../../script/build.sh"
