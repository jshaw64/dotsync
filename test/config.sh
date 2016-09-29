#!/bin/bash

test_set()
{
    echo "---------------"
    echo "Test: Set - Before"
    echo "---------------"

    config_print_active

    config_set $CONF_KEY_FSRC "test value 2"
    config_set $CONF_KEY_FDST "test value 3"
    config_set $CONF_KEY_DROOT "test value 3"
    config_set $CONF_KEY_DGROUP "test value 3"

    echo "---------------"
    echo "Test: Set - After"
    echo "---------------"

    config_print_active
}

test_get()
{
    echo "---------------"
    echo "Test: Get"
    echo "---------------"

    local fsrc=$(config_get $CONF_KEY_FSRC)
    local fdst=$(config_get $CONF_KEY_FDST)
    local droot=$(config_get $CONF_KEY_DROOT)
    local dgroup=$(config_get $CONF_KEY_DGROUP)

    echo "[${CONF_KEY_FSRC}] is [${fsrc}]"
    echo "[${CONF_KEY_FDST}] is [${fdst}]"
    echo "[${CONF_KEY_DROOT}] is [${droot}]"
    echo "[${CONF_KEY_DGROUP}] is [${dgroup}]"
}

test_parse()
{
    echo "---------------"
    echo "Test: Parse - Before"
    echo "---------------"

    config_print_active

    local i=0
    for entry in "${conf_static[@]}"; do
        echo "---------------"
        echo "Test: Parse - After ${i}"
        echo "---------------"
        config_parse $i
        config_print_active
        (( i++ ))
    done
}

main()
{
    test_parse
    test_set
    test_get
}

override()
{
    conf_static=(
      "${HOME}/Documents/test-data/src/.test1-basic"${CONF_FS}".tst01-renamed"${CONF_FS}"${HOME}/Documents/test-data/dst"${CONF_FS}"test01-basic"${CONF_FS}
      "${HOME}/Documents/test-data/src/.test2 with spaces in file"${CONF_FS}".tst02-renamed"${CONF_FS}"${HOME}/Documents/test-data/dst"${CONF_FS}"test02 with spaces"${CONF_FS}
      "${HOME}/Documents/test-data/src/with spaces in dir/.test3"${CONF_FS}".tst03-renamed"${CONF_FS}"${HOME}/Documents/test-data/dst/with spaces in dir"${CONF_FS}"test03"${CONF_FS}
    )
}

init()
{
    . "../config.sh"
    override

}

init
main
