#!/bin/bash

DEBUG=0
VERBOSE=0

E_FSRC=50
E_DROOT=51
E_FDST=52
E_ARCH=53
E_STATE=70

DEF_CONFIG_FILE=".fileme"

DEF_GROUP="default"
DEF_FILE_SRC_PATH=./testdata/src/*
DEF_FILE_DST_PATH=./testdata/dst
DEF_ARCHIVE_DIR=./testdata/arch
DEF_MODE_COPY=1
DEF_MODE_LINK=0
DEF_MODE_ARCHIVE=0

KEY_CONFIG_FILE="conf"
KEY_GROUP_BEGIN="group_begin"
KEY_GROUP_END="group_end"
KEY_GROUP="group"
KEY_FILE_SRC_PATH="file_src"
KEY_FILE_DST_PATH="file_dst"
KEY_ARCHIVE_DIR="arch_dir"
KEY_MODE_COPY="mode_copy"
KEY_MODE_LINK="mode_link"
KEY_MODE_ARCHIVE="mode_archive"

E_DIR=90
E_FILE=93
E_TASK_COPY=91
E_TASK_ARCHIVE=92
E_TASK_LINK=94

parse_parms()
{

  local config_file="$DEF_CONFIG_FILE"
  local group_name="$DEF_GROUP_NAME"
  local file_src_path="$DEF_FILE_SRC_PATH"
  local file_dst_path="$DEF_FILE_DST_PATH"
  local archive_dir="$DEF_ARCHIVE_DIR"
  local mode_copy="$DEF_MODE_COPY"
  local mode_link="$DEF_MODE_LINK"
  local mode_archive="$DEF_MODE_ARCHIVE"
#
#  local OPTIND=1
#  while getopts "d:f:p:n:r:k:hDv" opt; do
#    case "$opt" in
#      h )
#        usage
#        exit 0
#        ;;
#      D )
#        DEBUG=1
#        ;;
#      v )
#        VERBOSE=1
#        ;;
#      d )
#        :
#        ;;
#    esac
#  done
#
  config_set "$KEY_CONFIG_FILE" "$config_file"
  config_set "$KEY_GROUP_NAME" "$group_name"
  config_set "$KEY_FILE_SRC_PATH" "$file_src_path"
  config_set "$KEY_FILE_DST_PATH" "$file_dst_path"
  config_set "$KEY_ARCHIVE_DIR" "$archive_dir"
  config_set "$KEY_MODE_COPY" "$mode_copy"
  config_set "$KEY_MODE_LINK" "$mode_link"
  config_set "$KEY_MODE_ARCHIVE" "$mode_archive"
}

task_archive_src()
{
  local dir_src="$1"
  local dir_dst="$2"
  local file_src="$3"

  fs_is_valid_dir "$dir_src"
  (( $? > 0 )) && exit $E_DIR

  fs_is_valid_dir "$dir_dst"
  (( $? > 0 )) && exit $E_DIR

  fs_is_valid_file "$dir_src" "$file_src"
  (( $? > 0 )) && exit $E_FILE

  fs_copy_file "$dir_src" "$dir_dst" "$file_src" "$file_dst"
  (( $? > 0 )) && exit $E_TASK_ARCHIVE

  fs_rm_file "$dir_src" "$file_src"
  (( $? > 0 )) && exit $E_TASK_ARCHIVE

  return 0
}

task_link_to_dst()
{
  local dir_dst="$1"
  local dir_src="$2"
  local file_src_name="$3"
  local file_src_path="${dir_src}/${file_src_name}"
  local file_dst_name="$4"
  local file_dst_path="${dir_dst}/${file_dst_name}"

  fs_is_valid_dir "$dir_src"
  (( $? > 0 )) && exit $E_DIR

  fs_is_valid_dir "$dir_dst"
  (( $? > 0 )) && mkdir "$dir_dst"

  fs_is_valid_dir "$dir_dst"
  (( $? > 0 )) && exit $E_DIR

  cd "$dir_dst"
  ln -s "$file_dst_path" "$file_src_path"

  fs_is_valid_link "$dir_src" "$file_src_name" "$dir_dst" "$file_dst_name"
  (( $? > 0 )) && exit $E_TASK_LINK
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

fileme_prepare_config()
{
  local config_values="$1"
  local group_name=
  local file_src_path=
  local file_dst_path=
  local archive_dir=
  local mode_copy=
  local mode_link=
  local mode_archive=

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
      3 )
        archive_dir="$val"
        ;;
      4 )
        mode_copy="$val"
        ;;
      5 )
        mode_link="$val"
        ;;
      6 )
        mode_archive="$val"
        ;;
    esac
    (( i++ ))
  done

  IFS="$OIFS"

  config_set "$KEY_GROUP" "$group_name"
  config_set "$KEY_FILE_SRC_PATH" "$file_src_path"
  config_set "$KEY_FILE_DST_PATH" "$file_dst_path"
  config_set "$KEY_ARCHIVE_DIR" "$archive_dir"
  config_set "$KEY_MODE_COPY" "$mode_copy"
  config_set "$KEY_MODE_LINK" "$mode_link"
  config_set "$KEY_MODE_ARCHIVE" "$mode_archive"
}



main()
{
  local ctx="${BASH_SOURCE%/*}"
  if [[ ! -d "$ctx" ]]; then ctx="$PWD"; fi
  . "$ctx/lib/fsutils/fsutils.sh"
  . "$ctx/lib/config/config.sh"

  parse_parms "$@"

  local config_file=$(config_get "$KEY_CONFIG_FILE")
  fs_is_valid_file "$config_file"
  if [ $? -gt 0 ]; then
  else
    while :; do
      local group_begin=$(config_get "$KEY_GROUP_BEGIN")
      local group_end=$(config_get "$KEY_GROUP_END")
      config_parse_file "$KEY_GROUP_BEGIN" "$KEY_GROUP_END" ".syncconf"
      local config_values=$(config_get 1)
      [ -z "$config_values" ] && break
      fileme_prepare_config "$config_values"
    done
  fi





  local group_name=$(config_get "$KEY_GROUP")
  local mode_copy=$(config_get "$KEY_MODE_COPY")
  local mode_link=$(config_get "$KEY_MODE_LINK")
  local mode_archive=$(config_get "$KEY_MODE_ARCHIVE")

  local file_src_path=$(config_get "$KEY_FILE_SRC_PATH")
  local file_src_dir=$(fs_parse_path_no_file "$file_src_path")
  local file_src_name=$(fs_parse_file_from_path "$file_src_path")
  local file_dst_path=$(config_get "$KEY_FILE_DST_PATH")
  local file_dst_dir=$(fs_parse_path_no_file "$file_dst_path")
  local file_dst_name=$(fs_parse_file_from_path "$file_dst_path")
  task_copy_to_dst "$file_src_dir" "$file_dst_dir" "$file_src_name" "$file_dst_name"


  task_link_to_dst "$file_src_dir" "$file_dst_dir" "$file_src_name" "$file_dst_name"

  local archive_dir=$(config_get "$KEY_ARCHIVE_DIR")
  task_archive_src "$file_src_dir" "$archive_dir" "$file_src_name"
}

main "$@"

