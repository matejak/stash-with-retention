#!/bin/bash

put_matching_files_in_directory_to_array()
{
	readarray -t "$3" < <(printf "%s\n" "$2/"$1 | sort)
	# TODO: consider
	# readarray -t "$3" < <(ls $ls_args)
}

# number of elements of array named $1 minus $2
get_offset()
{
	eval "printf \"%d\" \$((\${#$1[@]} - $2))"
}

get_first_n_from_array()
{
	eval "$1=(\"\${$3[@]:0:$2}\")"
}

get_last_n_from_array()
{
	local offset
	offset="$(get_offset "$3" "$2")"
	eval "$1=(\"\${$3[@]:$offset}\")"
}

get_past_n_from_array()
{
	eval "$1=(\"\${$3[@]:$2}\")"
}

divide_array_into_mis_and_matching()
{
	local _idx _value _len
	eval "$3=()"
	eval "$4=()"
	_len=$(eval "echo \${#$1[@]}")
	for _idx in $(seq 0 $((_len - 1)))
	do
		eval "_value=\${$1[$_idx]}"
		if printf "%s" "$_value" | grep -q "$2"
		then
			eval "$3+=($_value)"
		else
			eval "$4+=($_value)"
		fi
	done
}

# $1: shortterm match
# $2: shortterm directory
# $3: shortterm max count
# $4: longterm match
# $5: longterm directory
# $6: longterm max count
# $7: ...
# $8: ...
# $9: ...
handle_directory()
{
	local files_in_directory overflow_files files_to_delete files_to_relocate
	put_matching_files_in_directory_to_array "$1" "$2" 'files_in_directory'
	get_past_n_from_array 'overflow_files' "$3" 'files_in_directory'
	if test -n "$4"
	then
		divide_array_into_mis_and_matching 'overflow_files' 'files_to_relocate' 'files_to_delete' "$4"
		if test "${#files_to_relocate[*]}" -gt 0
		then
			mkdir -p "$5"
			mv -- "${files_to_relocate[@]}" "$5"
			shift 3
			handle_directory "$@"
		fi
	else
		files_to_delete=("${overflow_files[@]}")
	fi
	test "${#files_to_delete[*]}" -gt 0 && rm -- "${files_to_delete[@]}"
}
