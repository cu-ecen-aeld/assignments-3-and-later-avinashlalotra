

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <filepath> <text_string>"
	exit 1
fi

writefile="$1"
writestr="$2"

dirpath=$(dirname "$writefile")

if [ ! -d "$dirpath" ]; then
	if ! mkdir -p "$dirpath" ; then
		echo "Error : Could not create directory $dirpath "
		exit 1
	fi
fi

if ! echo "$writestr" > "$writefile" ; then
	echo "Error: Could not write to file $writefile "
	exit 1
fi

exit 0
