set -ex

create()
{
	mkdir -p shortterm longterm
	touch shortterm/file-1-0{1,2,3,4,5}
	touch shortterm/file-2-0{1,2,3,4}
}

examine_count()
{
	test $(ls shortterm | wc -l) = $1
	test $(ls longterm | wc -l) = $2
}

files_exist()
{
	local where stem
	where="$1"
	shift
	for stem in "$@"
	do
		test -f "$where/$stem"
	done
}

longterm_exist()
{
	files_exist longterm "$@"
}

shortterm_exist()
{
	files_exist shortterm "$@"
}

cleanup()
{
	rm -rf shortterm longterm
}

cleanup

create
./apply-retention -s 4 -l 2
examine_count 4 1

shortterm_exist file-2-0{1,2,3,4}
longterm_exist file-1-01

cleanup

create
./apply-retention -s 3 -l 2 -r '-01$'
examine_count 3 2

shortterm_exist file-2-0{2,3,4}
longterm_exist file-1-01 file-2-01

cleanup

create
./apply-retention -s 3 -l 2 -r '.*'
examine_count 3 2

shortterm_exist file-2-0{2,3,4}
longterm_exist file-2-01 file-1-05

cleanup

echo 'Tests have passed!'
