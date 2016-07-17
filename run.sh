#!/bin/bash

main()
{
    local darchive="${HOME}/dotarchive"

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

        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"

        (( DEBUG || VERBOSE )) && echo "Validating state (before)..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"

        validate_before "$fsrc" "$droot"
        [ $? -gt 0 ] && exit $?
        
        (( DEBUG || VERBOSE )) && printf "\tSuccessfully validated state (before)\n"

        (( DEBUG || VERBOSE )) && echo "Copying file to archive..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [darchive], Value [${darchive}]\n"

        do_archive "$fsrc" "$darchive"

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
        (( DEBUG || VERBOSE )) && printf "\tKey [darchive], Value [${darchive}]\n"

        validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darchive"

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
