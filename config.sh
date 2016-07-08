#!/bin/bash

CONF_SEPARATOR=":"
CONF_KEY_QUERY="query"
CONF_KEY_VALUE="value"
CONF_KEY_ACTION="action"
CONF_KEY_INFILE="infile"

CONFIG=(
  "${CONF_KEY_QUERY}${CONF_SEPARATOR}"
  "${CONF_KEY_VALUE}${CONF_SEPARATOR}"
  "${CONF_KEY_ACTION}${CONF_SEPARATOR}"
  "${CONF_KEY_INFILE}${CONF_SEPARATOR}"
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
		if [ $key = $set_key ]; then
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
