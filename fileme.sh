#!/bin/bash

DEBUG=0
VERBOSE=0

E_FSRC=50
E_DROOT=51
E_FDST=52
E_ARCH=53
E_STATE=70

KEY_GROUP="group"
KEY_DIR_SRC="dir_src"
KEY_DIR_DST="dir_dst"
KEY_FILE_SRC="file_src"
KEY_FILE_DST="file_dst"

task_copy_to_dst()
{
   local file_src="$1"
   local file_dst="$2"
   local dir_src="$3"
   local dir_dst="$4"

    local dirdst="${droot}/${dgroup}"
    local filedst="${dirdst}/${fdst}"

    if [ ! -d "$dirdst" ]; then
        mkdir "$dirdst"
    fi

    cp "$fsrc" "$filedst"
}

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
    local should_copy=$6
    local should_link=$7

    local dirdst="${droot}/${dgroup}"
    local filedst="${dirdst}/${fdst}"
    local linktarget="$(readlink "$fsrc")"
    local farchive="${archivedir}/${fsrc##*/}"

    if [ $should_copy -eq 1 ]; then
        if [ ! -e "$filedst" ]; then
            echo "Error: dest file [$filedst] not found"
            exit $E_FSRC
        fi
    fi

    if [ $should_link -eq 1 ]; then
        if [ ! -L "$fsrc" ]; then
            echo "Error: src symlink [$fsrc] not found"
            exit $E_FSRC
        elif [ ! "$linktarget" = "$filedst" ]; then
            echo "Error: src symlink target [$linktarget] does not point to filedst [$filedst]"
            exit $E_FSRC
        fi
        if [ ! -d "$archivedir" ]; then
            echo "Error: archive dir [$archivedir] not found"
            exit $E_ARCH
        elif [ ! -e "$farchive" ]; then
            echo "Error: archive file [$farchive] not found"
            exit $E_ARCH
        fi
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

fileme_prepare_config()
{
  local config_values="$1"
  local group_name=
  local dir_src=
  local dir_dst=
  local file_src=
  local file_dst=

  local OIFS="$IFS"
  IFS=:
  local i=0

  for val in $config_values; do
    case $i in
      0 )
        group_name="$val"
        ;;
      1 )
        dir_src="$val"
        ;;
      2 )
        dir_dst="$val"
        ;;
      3 )
        file_src="$val"
        ;;
      4 )
        file_dst="$val"
        ;;
    esac
    (( i++ ))
  done

  IFS="$OIFS"

  config_set "$KEY_GROUP" "$group_name"
  config_set "$KEY_DIR_SRC" "$dir_src"
  config_set "$KEY_DIR_DST" "$dir_dst"
  config_set "$KEY_FILE_SRC" "$file_src"
  config_set "$KEY_FILE_DST" "$file_dst"
}



main()
{
    local ctx="${BASH_SOURCE%/*}"
    if [[ ! -d "$ctx" ]]; then ctx="$PWD"; fi
    . "$ctx/lib/fsutils/fsutils.sh"
    . "$ctx/lib/config/config.sh"


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

        local should_archive=$(config_get "$CONF_KEY_LINK")
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
        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_LINK}], Value [${should_link}]\n"

        validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darch" "$should_copy" "$should_link"
        if [ $? -gt 0 ]; then
            echo "Error: unable to validate state (after)"
            exit $E_STATE
        fi

        (( DEBUG || VERBOSE )) && printf "\tSuccessfully validated state (after)\n"

        (( i++ ))
    done
}

main "$@"
