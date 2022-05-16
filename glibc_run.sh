#!/bin/bash

VERSION="./glibc_versions"
DIR_TCACHE='tcache'
DIR_HOST='x64'
GLIBC_VERSION=''
TARGET=''

# Handle arguments
function show_help {
    echo "Usage: $0 <version> <target> [-h] [-disable-tcache] [-i686]"
}

if [[ $# < 2 ]]; then
    show_help
    exit 1
fi

GLIBC_VERSION=$1
TARGET=$2

while :; do
    case $3 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -disable-tcache)
            DIR_TCACHE='notcache'
            ;;
        -i686)
            DIR_HOST='i686'
            ;;
        '')
            break
            ;;
    esac
    shift
done

OUTPUT_DIR="$VERSION/$GLIBC_VERSION/${DIR_HOST}_${DIR_TCACHE}/lib"

# Get glibc source
if [ ! -e "$OUTPUT_DIR/libc.so.6" ]; then
    echo "Error: Glibc-version wasn't build. Build it first:"
    echo "./build_glibc $GLIBC_VERSION <#make-threads"
    exit
fi

ld_list=($OUTPUT_DIR/ld-*.so*)
target_interp="${ld_list[0]}"
curr_interp=$(readelf -l "$TARGET" | grep 'Requesting' | cut -d':' -f2 | tr -d ' ]')

if [[ $curr_interp != $target_interp ]];
then
    patchelf --set-interpreter "$target_interp" "$TARGET"
fi

"$TARGET"
