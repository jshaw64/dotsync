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

        local should_copy=$(config_get "$CONF_KEY_COPY")
        if [ $should_copy -eq 1 ]; then
            (( DEBUG || VERBOSE )) && echo "Copying src file to dst/group..."
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"

            do_copy "$fsrc" "$fdst" "$droot" "$dgroup"
        fi

        local should_archive=$(config_get "$CONF_KEY_ARCH")
        if [ $should_archive -eq 1 ]; then
            (( DEBUG || VERBOSE )) && echo "Moving file to archive..."
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [darch], Value [${darch}]\n"

            do_archive "$fsrc" "$darch"
        fi

        local should_link=$(config_get "$CONF_KEY_LINK")
        if [ $should_link -eq 1 ]; then
            (( DEBUG || VERBOSE )) && echo "Creating symlink..."
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"

            do_link "$fsrc" "$fdst" "$droot" "$dgroup"
        fi

        (( DEBUG || VERBOSE )) && echo "Validating state (after)..."
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DARCH}], Value [${darch}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_COPY}], Value [${should_copy}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_ARCH}], Value [${should_archive}]\n"
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_LINK}], Value [${should_link}]\n"

        validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darch" "$should_copy" "$should_archive" "$should_link"
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
