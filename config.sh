#!/bin/bash

CONF_FS=":"
CONF_KEY_FSRC="srcfile"
CONF_KEY_FDST="dstfile"
CONF_KEY_DROOT="dirroot"
CONF_KEY_DGROUP="dirgroup"

CONFIG=(
  "${CONF_KEY_FSRC}${CONF_FS}"
  "${CONF_KEY_FDST}${CONF_FS}"
  "${CONF_KEY_DROOT}${CONF_FS}"
  "${CONF_KEY_DGROUP}${CONF_FS}"
)

CONFIG_VALS=(
  "${HOME}/.tstfile1"${CONF_FS}".tstfile-renamed"${CONF_FS}"${HOME}/dotfiles"${CONF_FS}"testdir"${CONF_FS}
)

TEST_CONFIG_VALS=(
  "${HOME}/Documents/test-data/src/.test1-basic"${CONF_FS}".tst01-renamed"${CONF_FS}"${HOME}/Documents/test-data/dst"${CONF_FS}"test01-basic"${CONF_FS}
  "${HOME}/Documents/test-data/src/.test2 with spaces in file"${CONF_FS}".tst02-renamed"${CONF_FS}"${HOME}/Documents/test-data/dst"${CONF_FS}"test02 with spaces"${CONF_FS}
  "${HOME}/Documents/test-data/src/with spaces in dir/.test3"${CONF_FS}".tst03-renamed"${CONF_FS}"${HOME}/Documents/test-data/dst/with spaces in dir"${CONF_FS}"test03"${CONF_FS}
)

test_basic()
{
	config_print
	config_set $CONF_KEY_FSRC "test value 1"
	config_print
	config_set $CONF_KEY_FDST "test value 2"
	config_print
	config_set $CONF_KEY_DROOT "test value 3"
	config_print
	config_set $CONF_KEY_DGROUP "test value 4"
	config_print
}

config_test_conf_vals()
{
	config_print
	local i=0
	local size="${#CONFIG_VALS[@]}"
	while [ $i -lt $size ]; do
		config_parse $i
		config_print
		(( i++ ))
	done
}

config_test_parse()
{
	local idx=$1
	local entry="${TEST_CONFIG_VALS[$idx]}"
	local parsed=()

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
				key="$CONF_KEY_DROOT"
				;;
			3 )
				key="$CONF_KEY_DGROUP"
				;;
		esac
		config_set "$key" $val
		(( i++ ))
	done
	IFS="$OIFS"
}

config_print()
{
	local i=0
	for entry in "${CONFIG[@]}" ; do
		local key=${entry%%:*}
		local value=${entry#*:}
		echo "[$i] Key: [$key] Value: [$value]"
		(( i++ ))
	done
}

config_parse()
{
	local idx=$1
	local entry="${CONFIG_VALS[$idx]}"
	local parsed=()

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
				key="$CONF_KEY_DROOT"
				;;
			3 )
				key="$CONF_KEY_DGROUP"
				;;
		esac
		config_set "$key" $val
		(( i++ ))
	done
	IFS="$OIFS"
}

config_get()
{
	local get_key="$1"
	local found=

	for entry in "${CONFIG[@]}" ; do
		local key=${entry%%:*}
		local value=${entry#*:}
		if [ $key = $get_key ]; then
			found="$value"
			break
		fi
	done

	echo "$found"
}

config_set()
{
	local set_key="$1"
	local set_val="$2"

	local i=0
	for entry in "${CONFIG[@]}" ; do
		local key=${entry%%:*}
		local value=${entry#*:}
		if [ "$key" = "$set_key" ]; then
			CONFIG[$i]="${key}:${set_val}"
			break
		fi
		(( i++ ))
	done

	#CONFIG+=( "${key}:${set_val}" )
}


init()
{
	[ "$1" = "test" ] && test_basic && config_test_conf_vals
}

init "$@"
