#!/bin/bash

test_sync()
{
    local darchive="${HOME}/dotarchive"

    local i=0
    local size="${#conf_static[@]}"
    while [ $i -lt $size ]; do
        config_parse $i
        local fsrc=$(config_get "$CONF_KEY_FSRC")
        local fdst=$(config_get "$CONF_KEY_FDST")
        local droot=$(config_get "$CONF_KEY_DROOT")
        local dgroup=$(config_get "$CONF_KEY_DGROUP")
        validate_before "$fsrc" "$droot"
        [ $? -gt 0 ] && exit $?
        do_archive "$fsrc" "$darchive"
        do_link "$fsrc" "$fdst" "$droot" "$dgroup"
        validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darchive"
        (( i++ ))
    done
}

init()
{
    local ctx="${BASH_SOURCE%/*}"
    . "../config.sh"
    . "../sync.sh"
}

init
test_sync "$@"
