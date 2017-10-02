#!/bin/bash

filter_input()
{
	readarray -t "$1" < <(printf "%s\n" "$2/"$3 | sort)
}

get_offset()
{
	eval "printf \"%d\" \$((\${#$1[@]} - $2))"
}

from_array_get_first_n()
{
	local offset
	offset="$(get_offset "$1" "$3")"
	eval "$2=(\"\${$1[@]::$offset}\")"
}

from_array_get_last_n()
{
	local offset
	offset="$(get_offset "$1" "$3")"
	eval "$2=(\"\${$1[@]:$offset}\")"
}

from_array_first_n()
