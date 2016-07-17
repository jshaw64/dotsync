#!/bin/bash

CONF_FS=":"
CONF_KEY_DEBUG="debug"
CONF_KEY_VERBOSE="verbose"
CONF_KEY_COPY="copytodst"
CONF_KEY_ARCH="archivesrc"
CONF_KEY_LINK="symlinksrc"
CONF_KEY_FSRC="srcfile"
CONF_KEY_FDST="dstfile"
CONF_KEY_DROOT="dirroot"
CONF_KEY_DGROUP="dirgroup"
CONF_KEY_DARCH="dirarchive"

conf_active=(
  "${CONF_KEY_FSRC}${CONF_FS}"
  "${CONF_KEY_FDST}${CONF_FS}"
  "${CONF_KEY_DGROUP}${CONF_FS}"
)

conf_global=(
  "${CONF_KEY_DROOT}${CONF_FS}${HOME}/Documents/test-data/dst"
  "${CONF_KEY_DARCH}${CONF_FS}${HOME}/Documents/test-data/arch"
  "${CONF_KEY_DEBUG}${CONF_FS}"1
  "${CONF_KEY_VERBOSE}${CONF_FS}"1
  "${CONF_KEY_COPY}${CONF_FS}"1
  "${CONF_KEY_ARCH}${CONF_FS}"1
  "${CONF_KEY_LINK}${CONF_FS}"1
)

conf_static=(
  "${HOME}/Documents/test-data/src/.test1-basic"${CONF_FS}".tst01-renamed"${CONF_FS}"test01-basic"${CONF_FS}
  "${HOME}/Documents/test-data/src/.test2 with spaces in file"${CONF_FS}".tst02-renamed"${CONF_FS}"test02 with spaces"${CONF_FS}
  "${HOME}/Documents/test-data/src/with spaces in dir/.test3"${CONF_FS}".tst03-renamed"${CONF_FS}"test03"${CONF_FS}
)

config_print_active()
{
    echo "Config: Print: Active"

    local i=0
    for entry in "${conf_active[@]}" ; do
        local key=${entry%%:*}
        local value=${entry#*:}
        printf "\t[$i] Key: [$key] Value: [$value]\n"
        (( i++ ))
    done
}

config_print_global()
{
    echo "Config: Print: Global"

    local i=0
    for entry in "${conf_global[@]}" ; do
        local key=${entry%%:*}
        local value=${entry#*:}
        printf "\t[$i] Key: [$key] Value: [$value]\n"
        (( i++ ))
    done
}

config_print_static()
{
    echo "Config: Print: Static"

    local i=0
    local size="${#conf_static[@]}"
    local entry=
    local idx=

    while [ $i -lt $size ]; do
        entry="${conf_static[$i]}"
        OIFS="$IFS"
        IFS=:
        local j=0
        for val in $entry; do
            local key=
            case $j in
                0 )
                    key="$CONF_KEY_FSRC"
                    ;;
                1 )
                    key="$CONF_KEY_FDST"
                    ;;
                2 )
                    key="$CONF_KEY_DGROUP"
                    ;;
            esac
            printf "\tKey: [${key}] Value: [${val}]\n"
            (( j++ ))
        done
        IFS="$OIFS"
        (( i++ ))
    done
}

config_print()
{
    config_print_active
    config_print_global
    config_print_static
}

config_get_active()
{

    local get_key="$1"
    local found=

    for entry in "${conf_active[@]}" ; do
        local key=${entry%%:*}
        local value=${entry#*:}
        if [ $key = $get_key ]; then
            found="$value"
            break
        fi
    done

    echo "$found"
}

config_get_global()
{
    local get_key="$1"
    local found=

    for entry in "${conf_global[@]}" ; do
        local key=${entry%%:*}
        local value=${entry#*:}
        if [ $key = $get_key ]; then
            found="$value"
            break
        fi
    done

    echo "$found"
}

config_get()
{

    local found="$(config_get_active "$@")"
    if [ -z "$found" ]; then
        found="$(config_get_global "$@")"
    fi
    echo "$found"
}

config_set()
{
    local set_key="$1"
    local set_val="$2"

    local i=0
    for entry in "${conf_active[@]}" ; do
        local key=${entry%%:*}
        local value=${entry#*:}
        if [ "$key" = "$set_key" ]; then
            conf_active[$i]="${key}:${set_val}"
            break
        fi
        (( i++ ))
    done

    #CONFIG+=( "${key}:${set_val}" )
}

config_parse()
{
    local idx=$1
    local entry="${conf_static[$idx]}"

    OIFS="$IFS"
    IFS=:
    local i=0
    for val in $entry; do
        local key=
        case $i in
            0 )
                key="$CONF_KEY_FSRC"
                ;;
            1 ) 
                key="$CONF_KEY_FDST"
                ;;
            2 ) 
                key="$CONF_KEY_DGROUP"
                ;;
        esac
        config_set "$key" $val
        (( i++ ))
    done
    IFS="$OIFS"
}
