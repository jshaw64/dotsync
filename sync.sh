#!/bin/bash

E_FSRC=50
E_DROOT=51
E_FDST=52

sync_test()
{
	. ./config.sh

	echo "Hello-----"

	local darchive="${HOME}/Documents/test-data/dotarchive"

	local i=0
	local size="${#TEST_CONFIG_VALS[@]}"
	while [ $i -lt $size ]; do
		config_test_parse $i
		local fsrc=$(config_get "$CONF_KEY_FSRC")
		local fdst=$(config_get "$CONF_KEY_FDST")
		local droot=$(config_get "$CONF_KEY_DROOT")
		local dgroup=$(config_get "$CONF_KEY_DGROUP")
		validate_before "$fsrc" "$droot"
		[ $? -gt 0 ] && exit $?
		do_archive "$fsrc" "$darchive"
		do_link "$fsrc" "$fdst" "$droot" "$dgroup"
		validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darchive"
		(( i++ ))
	done
	echo "Hello-----"
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

	local dirdst="${droot}/${dgroup}"
	local filedst="${dirdst}/${fdst}"
	local linktarget="$(readlink "$fsrc")"
	local farchive="${archivedir}/${fsrc##*/}"

	echo "$fsrc"
	echo "$dirdst"
	echo "$filedst"
	echo "$linktarget"

	if [ ! -L "$fsrc" ]; then
		echo "Error: src symlink [$fsrc] not found"
		exit $E_FSRC
	elif [ ! "$linktarget" = "$filedst" ]; then
		echo "Error: src symlink target [$linktarget] does not point to filedst [$filedst]"
		exit $E_FSRC
	elif [ ! -e "$farchive" ]; then
		echo "Error: archive file [$farchive] not found"
		exit $E_FDST
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

main()
{
	[ "$1" = "test" ] && sync_test && exit 0

	. ./config.sh

	local darchive="${HOME}/dotarchive"

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
		do_archive "$fsrc" "$darchive"
		do_link "$fsrc" "$fdst" "$droot" "$dgroup"
		validate_after "$fsrc" "$fdst" "$droot" "$dgroup" "$darchive"
		(( i++ ))
	done
}

main "$@"

