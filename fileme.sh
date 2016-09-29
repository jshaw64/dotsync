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
KEY_FILE_SRC_PATH="file_src"
KEY_FILE_DST_PATH="file_dst"

E_DIR=90
E_TASK_COPY=91
E_TASK_ARCHIVE=92

task_archive_src()
{
  local dir_src="$1"
  local dir_dst="$2"
  local file_src="$3"

  fs_copy_file "$dir_src" "$dir_dst" "$file_src" "$file_dst"
  (( $? > 0 )) && exit $E_TASK_ARCHIVE

  fs_rm_file "$dir_src" "$file_src"
  (( $? > 0 )) && exit $E_TASK_ARCHIVE
}

task_copy_to_dst()
{
  local dir_src="$1"
  local dir_dst="$2"
  local file_src="$3"
  local file_dst="$4"

  fs_is_valid_dir "$dir_src"
  (( $? > 0 )) && exit $E_DIR

  fs_is_valid_dir "$dir_dst"
  (( $? > 0 )) && mkdir "$dir_dst"

  fs_is_valid_dir "$dir_dst"
  (( $? > 0 )) && exit $E_DIR

  fs_copy_file "$dir_src" "$dir_dst" "$file_src" "$file_dst"
  (( $? > 0 )) && exit $E_TASK_COPY

  return 0
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
  local file_src_path=
  local file_dst_path=

  local OIFS="$IFS"
  IFS=:
  local i=0

  for val in $config_values; do
    case $i in
      0 )
        group_name="$val"
        ;;
      1 )
        file_src_path="$val"
        ;;
      2 )
        file_dst_path="$val"
        ;;
    esac
    (( i++ ))
  done

  IFS="$OIFS"

  config_set "$KEY_GROUP" "$group_name"
  config_set "$KEY_FILE_SRC_PATH" "$file_src_path"
  config_set "$KEY_FILE_DST_PATH" "$file_dst_path"
}



main()
{
    local ctx="${BASH_SOURCE%/*}"
    if [[ ! -d "$ctx" ]]; then ctx="$PWD"; fi
    . "$ctx/lib/fsutils/fsutils.sh"
    . "$ctx/lib/config/config.sh"

    config_parse_file "sync_group_begin" "sync_group_end" ".syncconf"
    local config_values=$(config_get 1)

    fileme_prepare_config "$config_values"

    local group_name=$(config_get "$KEY_GROUP")
    local file_src_path=$(config_get "$KEY_FILE_SRC_PATH")
    local file_src_dir=$(fs_parse_path_no_file "$file_src_path")
    local file_src_name=$(fs_parse_file_from_path "$file_src_path")
    local file_dst_path=$(config_get "$KEY_FILE_DST_PATH")
    local file_dst_dir=$(fs_parse_path_no_file "$file_dst_path")
    local file_dst_name=$(fs_parse_file_from_path "$file_dst_path")

    task_copy_to_dst "$file_src_dir" "$file_dst_dir" "$file_src_name" "$file_dst_name"

  exit
#    local i=0
#    local size="${#conf_static[@]}"
#    while [ $i -lt $size ]; do
#
#        (( DEBUG || VERBOSE )) && echo "====================="
#        (( DEBUG || VERBOSE )) && echo "Config index [${i}]"
#        (( DEBUG || VERBOSE )) && echo "====================="
#
#        (( DEBUG || VERBOSE )) && echo "Parsing config..."
#
#        config_parse $i
#
#        local fsrc=$(config_get "$CONF_KEY_FSRC")
#        local fdst=$(config_get "$CONF_KEY_FDST")
#        local droot=$(config_get "$CONF_KEY_DROOT")
#        local dgroup=$(config_get "$CONF_KEY_DGROUP")
#        local darch=$(config_get "$CONF_KEY_DARCH")
#
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DARCH}], Value [${darch}]\n"
#
#        (( DEBUG || VERBOSE )) && echo "Validating state (before)..."
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
#
#        validate_before "$fsrc" "$droot"
#        if [ $? -gt 0 ]; then
#            echo "Error: unable to validate state (before)"
#            exit $E_STATE
#        fi
#        
#        (( DEBUG || VERBOSE )) && printf "\tSuccessfully validated state (before)\n"
#
#        local should_copy=$(config_get "$CONF_KEY_COPY")
#        if [ $should_copy -eq 1 ]; then
#            (( DEBUG || VERBOSE )) && echo "Copying src file to dst/group..."
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
#
#            do_copy "$fsrc" "$fdst" "$droot" "$dgroup"
#        fi
#
#        local should_archive=$(config_get "$CONF_KEY_LINK")
#        if [ $should_archive -eq 1 ]; then
#            (( DEBUG || VERBOSE )) && echo "Moving file to archive..."
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [darch], Value [${darch}]\n"
#
#            do_archive "$fsrc" "$darch"
#        fi
#
#        local should_link=$(config_get "$CONF_KEY_LINK")
#        if [ $should_link -eq 1 ]; then
#            (( DEBUG || VERBOSE )) && echo "Creating symlink..."
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
#            (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
#
#            do_link "$fsrc" "$fdst" "$droot" "$dgroup"
#        fi
#
#        (( DEBUG || VERBOSE )) && echo "Validating state (after)..."
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FSRC}], Value [${fsrc}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_FDST}], Value [${fdst}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DROOT}], Value [${droot}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DGROUP}], Value [${dgroup}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_DARCH}], Value [${darch}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_COPY}], Value [${should_copy}]\n"
#        (( DEBUG || VERBOSE )) && printf "\tKey [${CONF_KEY_LINK}], Value [${should_link}]\n"
#
#        validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darch" "$should_copy" "$should_link"
#        if [ $? -gt 0 ]; then
#            echo "Error: unable to validate state (after)"
#            exit $E_STATE
#        fi
#
#        (( DEBUG || VERBOSE )) && printf "\tSuccessfully validated state (after)\n"
#
#        (( i++ ))
#    done
}

main "$@"
