#!/bin/bash

put_matching_files_in_directory_to_array()
{
	local temp fname
	readarray -t temp < <(ls -r $ls_args -- "$2"  | grep -e "$1")
	eval "$3=()"
	for fname in "${temp[@]}"
	do
		eval "$3+=(\"$2/$fname\")"
	done
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
		if printf "%s" "$_value" | grep -q -e "$2"
		then
			eval "$3+=($_value)"
		else
			eval "$4+=($_value)"
		fi
	done
}


delete_file_or_directory()
{
	# delete recursive if directory, otherwise attempt to delete normally
	test -d "$1" && rm -r -- "$1" || rm -- "$1"
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
		divide_array_into_mis_and_matching 'overflow_files' "$4" 'files_to_relocate' 'files_to_delete'
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

	if test "${#files_to_delete[*]}" -gt 0
	then
		for entry in "${files_to_delete[@]}"
		do
			delete_file_or_directory "$entry"
		done
	fi
	true
}
