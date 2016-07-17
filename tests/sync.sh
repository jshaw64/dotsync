#!/bin/bash

test_sync()
{
    . ./config.sh

    echo "Hello-----"

    local darchive="${HOME}/Documents/test-data/dotarchive"

    local i=0
    local size="${#TEST_CONFIG_VALS[@]}"
    while [ $i -lt $size ]; do
        config_test_parse $i
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
    echo "Hello-----"
}

main()
{
    test_sync
}

init()
{
    . "../sync.sh"
}

init
main
