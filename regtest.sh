set -ex

mkdir -p shortterm longterm

touch shortterm/file-1-{1,2,3,4,5}
touch shortterm/file-2-{1,2,3}
./files.sh -s 4 -l 2

test $(ls shortterm | wc -l) = 4

echo 'juch!'
