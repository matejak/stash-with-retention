. lib.sh

create_directory_with_files()
{
	local dir
	dir="$1"
	mkdir -p "$dir"
	for fname in $2; do
		touch "$dir/$fname"
	done
}

set -e

testdir=foobar
files="xone-4 xone-1 xone-2 two-1 xone-0 one-3"
create_directory_with_files "$testdir" "$files"
output=()
put_matching_files_in_directory_to_array 'xone-.*' "$testdir" output 
test "${output[0]}" = "$testdir/xone-4"
test "${output[-1]}" = "$testdir/xone-0"
test "${#output[@]}" = 4

result=()
get_first_n_from_array result 3 output
test "${result[0]}" = "$testdir/xone-4"
test "${result[1]}" = "$testdir/xone-2"
test "${result[2]}" = "$testdir/xone-1"
test "${#result[@]}" = 3

get_last_n_from_array result 3 output
test "${result[0]}" = "$testdir/xone-2"
test "${result[1]}" = "$testdir/xone-1"
test "${result[2]}" = "$testdir/xone-0"
test "${#result[@]}" = 3

get_past_n_from_array result 2 output
test "${result[0]}" = "$testdir/xone-1"
test "${result[1]}" = "$testdir/xone-0"
test "${#result[@]}" = 2

get_last_n_from_array result2 3 result
test "${#result[@]}" = "${#result2[@]}"
for i in $(seq 0 ${#result[@]})
do
	test "${result[$i]}" = "${result2[$i]}"
done

divide_array_into_mis_and_matching output 'xone-[12]' xone12 xone04
test "${#xone12[@]}" = 2
test "${#xone04[@]}" = 2

test "${xone12[0]}" = "$testdir/xone-2"
test "${xone12[1]}" = "$testdir/xone-1"

test "${xone04[0]}" = "$testdir/xone-4"
test "${xone04[1]}" = "$testdir/xone-0"

divide_array_into_mis_and_matching output 'xone-[12]' xone12 xone04
test "${#xone12[@]}" = 2
test "${#xone04[@]}" = 2

rm -rf "$testdir"

echo "Tests have passed."
