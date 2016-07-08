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
  "${HOME}/.bash_profile"${CONF_FS}".bash_profile"${CONF_FS}"${HOME}/dotfiles"${CONF_FS}"bash"${CONF_FS}
  "${HOME}/.bash_profile2"${CONF_FS}".bash_profile2"${CONF_FS}"${HOME}/dotfiles"${CONF_FS}"bash"${CONF_FS}
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
	[ "$1" = "test" ] && test_basic
}

init "$@"
