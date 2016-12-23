TEST=true
source=./test
output=./output

Run () {
    if [ "$TEST" ]; then
        echo "$*"
        return 0
    fi

    eval "$@"
}

echo "Making directory tree!"
for dir in `find $source -type d`; do
	Run mkdir -p "$output/${dir:2}"
done

echo "Symlinks"
for aLink in `find $source -type l`; do
	Run cp "$aLink" "$output/${aLink:2}"
done

echo "Real Files"
for aFile in `find $source -type f`; do
	Run ln "$aFile" "$output/${aFile:2}"
done