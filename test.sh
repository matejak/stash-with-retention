. src.sh

create_directory_with_files()
{
	local dir
	dir="$1"
	mkdir -p "$dir"
	for fname in $2; do
		touch "$dir/$fname"
	done
}

set -ex

testdir=foobar
files="xone-4 xone-1 xone-2 two-1 xone-0 one-3"
create_directory_with_files "$testdir" "$files"
output=()
filter_input output "$testdir" 'xone-*'
test "${output[0]}" = "$testdir/xone-0"
test "${output[-1]}" = "$testdir/xone-4"
test "${#output[@]}" = 4

result=()
from_array_get_first_n output result 2
test "${result[0]}" = "$testdir/xone-0"
test "${result[1]}" = "$testdir/xone-1"
test "${#result[@]}" = 2

from_array_get_last_n output result 3
test "${result[0]}" = "$testdir/xone-1"
test "${result[1]}" = "$testdir/xone-2"
test "${result[2]}" = "$testdir/xone-4"
test "${#result[@]}" = 3

rm -rf "$testdir"
