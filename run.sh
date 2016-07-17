#!/bin/bash

E_STATE=70

main()
{

    DEBUG=$(config_get "$CONF_KEY_DEBUG")
    VERBOSE=$(config_get "$CONF_KEY_VERBOSE")

    local i=0
    local size="${#conf_static[@]}"
    while [ $i -lt $size ]; do

        (( DEBUG || VERBOSE )) && echo "====================="
        (( DEBUG || VERBOSE )) && echo "Config index [${i}]"
        (( DEBUG || VERBOSE )) && echo "====================="

        (( DEBUG || VERBOSE )) && echo "Parsing config..."

        config_parse $i

        local fsrc=$(config_get "$CONF_KEY_FSRC")
        local fdst=$(config_get "$CONF_KEY_FDST")
        local droot=$(config_get "$CONF_KEY_DROOT")
        local dgroup=$(config_get "$CONF_KEY_DGROUP")
        local darch=$(config_get "$CONF_KEY_DARCH")

        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DARCH}], Value [${darch}]\n"

        (( DEBUG || VERBOSE )) && echo "Validating state (before)..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"

        validate_before "$fsrc" "$droot"
        if [ $? -gt 0 ]; then
            echo "Error: unable to validate state (before)"
            exit $E_STATE
        fi
        
        (( DEBUG || VERBOSE )) && printf "\tSuccessfully validated state (before)\n"

        (( DEBUG || VERBOSE )) && echo "Copying file to archive..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [darch], Value [${darch}]\n"

        do_archive "$fsrc" "$darch"

        (( DEBUG || VERBOSE )) && echo "Creating symlink..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"

        do_link "$fsrc" "$fdst" "$droot" "$dgroup"

        (( DEBUG || VERBOSE )) && echo "Validating state (after)..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [darch], Value [${darch}]\n"

        validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darch"
        if [ $? -gt 0 ]; then
            echo "Error: unable to validate state (after)"
            exit $E_STATE
        fi

        (( DEBUG || VERBOSE )) && printf "\tSuccessfully validated state (after)\n"

        (( i++ ))
    done
}

init()
{
    local ctx="${BASH_SOURCE%/*}"
    if [[ ! -d "$ctx" ]]; then ctx="$PWD"; fi
    . "$ctx/config.sh"
    . "$ctx/sync.sh"
}

init
main "$@"
