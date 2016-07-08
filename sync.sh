#!/bin/bash

E_FSRC=50
E_DROOT=51

link()
{
  for file in $@; do
    local src="$DIR_SRC/$file"
    local dst="$DIR_DST/$file"
    echo "Moving $src to $dst"
    mv $src $dst
    echo "Linking $dst to $src"
    ln -s $dst $src
  done
}

pre_process_dir_dst()
{
  if [ ! -d "$1" ]; then
    echo "Error missing destination dir $1"
    exit $E_DIR
  else
    echo "Found destination dir $1"
  fi
}

pre_process_dir_src()
{

  for file in "${files[@]}"; do
#    local dir_src="${2[$i]}"
#    local dir_src="${dirs[$i]}"
echo $file
echo "hello"
    if [ ! -d "$dir_src" ]; then
      echo "Error missing source $dir_src"
      exit $E_DIR
    fi
    if [ ! -e "${dir_src}/${file}" ]; then
      echo "Error missing file $file"
      continue
    fi
    echo "Found file $file"
    to_backup_final+=("$file")
    (( i++ ))
  done
}

config_show()
{
  echo "Showing config from file.."
  while read line; do
    echo "$line"
  done < $config
  echo
  echo "Showing config processed.."
  for entry in "${config_processed[@]}"; do
    echo "$entry"
  done
  echo
}

run_link()
{

  local i=0
  local config="$@"

  for entry in ${config[@]}; do

    OIFS="$IFS"
    IFS=:=
    set -- $entry

    echo
    echo "Entry $i" && (( i++ ))

    echo "Entry is.."
    echo $entry
    echo "P1 is.."
    echo $1
    echo "P2 is.."
    echo $2

    local path_only=${1%/*}
    local alias_full="${DIR_DST}/${2}"

    echo "Path full is $1"
    echo "Path only is $path_only"
    echo "Alias only is $2"
    echo "Alias full is $alias_full"
    
    echo
    echo "Creating link from $1 to $2"
    
    cd "$path_only/a"
    ln -s $alias_full $path_full
    

    IFS="$OIFS"

  done

  echo

}

config_prepare()
{
  OIFS="$IFS"
  IFS=:

  local i=0

  while read path_full alias; do

    echo
    echo "Entry $i" && (( i++ ))
    local path_only=${path_full%/*}
    echo "Path is $path_full"
    echo "Path only is $path_only"
    echo "Alias is $alias"

    if [ ! -d "$path_only" ]; then
      echo "Error missing source $path_only"
      exit $E_DIR
    fi
    if [ ! -e "$path_full" ]; then
      echo "Error missing file $path_full"
      continue
    fi

    config_processed+=( "${path_full}:${alias}" )

  done < $1

  echo

  IFS="$OIFS"

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

main()
{
	. ./config.sh

	local i=0
	local size="${#CONFIG_VALS[@]}"
	while [ $i -lt $size ]; do
		config_parse $i
		local fsrc=$(config_get "$CONF_KEY_FSRC")
		local fdst=$(config_get "$CONF_KEY_FDST")
		local droot=$(config_get "$CONF_KEY_DROOT")
		local dgroup=$(config_get "$CONF_KEY_DGROUP")
		validate_before "$fsrc" "$droot"
		[ $? -gt 0 ] && exit $?
		(( i++ ))
	done


}

main "$@"

