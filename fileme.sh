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
KEY_ARCHIVE_DIR="arch_dir"

E_DIR=90
E_FILE=93
E_TASK_COPY=91
E_TASK_ARCHIVE=92
E_TASK_LINK=94

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
    esac
    (( i++ ))
  done

  IFS="$OIFS"

  config_set "$KEY_GROUP" "$group_name"
  config_set "$KEY_FILE_SRC_PATH" "$file_src_path"
  config_set "$KEY_FILE_DST_PATH" "$file_dst_path"
  config_set "$KEY_ARCHIVE_DIR" "$archive_dir"
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


  task_link_to_dst "$file_src_dir" "$file_dst_dir" "$file_src_name" "$file_dst_name"

  local archive_dir=$(config_get "$KEY_ARCHIVE_DIR")
  task_archive_src "$file_src_dir" "$archive_dir" "$file_src_name"
}

main "$@"

