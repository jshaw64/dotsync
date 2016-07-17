#!/bin/bash

E_FSRC=50
E_DROOT=51
E_FDST=52

do_archive()
{
    local fsrc="$1"
    local archivedir="$2"

    mv "$fsrc" "$archivedir"
}

do_link()
{
    local fsrc="$1"
    local fdst="$2"
    local droot="$3"
    local dgroup="$4"

    local dirdst="${droot}/${dgroup}"
    local filedst="${dirdst}/${fdst}"

    if [ ! -d "$dirdst" ]; then
        mkdir "$dirdst"
    fi

    cd "$dirdst"
    ln -s "$filedst" "$fsrc"
}

validate_after()
{
    local fsrc="$1"
    local fdst="$2"
    local droot="$3"
    local dgroup="$4"
    local archivedir="$5"

    local dirdst="${droot}/${dgroup}"
    local filedst="${dirdst}/${fdst}"
    local linktarget="$(readlink "$fsrc")"
    local farchive="${archivedir}/${fsrc##*/}"

    if [ ! -L "$fsrc" ]; then
        echo "Error: src symlink [$fsrc] not found"
        exit $E_FSRC
    elif [ ! "$linktarget" = "$filedst" ]; then
        echo "Error: src symlink target [$linktarget] does not point to filedst [$filedst]"
        exit $E_FSRC
    elif [ ! -e "$farchive" ]; then
        echo "Error: archive file [$farchive] not found"
        exit $E_FDST
    fi
}

validate_before()
{
    local fsrc="$1"

    if [ ! -e "$fsrc" ]; then
        echo "Error: source file [$fsrc] not found"
        exit $E_FSRC
    fi

    local droot="$2"

    if [ ! -d "$droot" ]; then
        echo "Error: root directory [$droot] not found"
        exit $E_DROOT
    fi

    return 0
}
