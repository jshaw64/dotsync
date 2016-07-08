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


#config_print
#config_set "query" "CFBundleSomething"
#config_print
#config_set "infile" "./Info.plist"
#config_print
