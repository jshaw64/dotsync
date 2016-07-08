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
	ln -s $filedst $fsrc
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

