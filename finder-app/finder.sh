

filesdir="$1"
searchstr="$2"

# Check if directory and search string are provided
if [ -z "$filesdir" ]; then
    echo "filesdir is not specified"
    exit 1
fi

if [ -z "$searchstr" ]; then
    echo "search string is not specified"
    exit 1
fi

# Check if the directory is valid
if [ ! -d "$filesdir" ]; then
    echo "Error: '$filesdir' is not a valid directory"
    exit 1
fi

# Count the number of files
files_number=$(find "$filesdir" -type f | wc -l)

# Count the number of matching lines
matching_lines=$(grep -r -l "$searchstr" "$filesdir" | wc -l )

# Print results
echo "The number of files are ${files_number} and the number of matching lines are ${matching_lines:-0}"

exit 0

