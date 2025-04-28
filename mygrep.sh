#!/bin/bash
# mygrep.sh - A mini version of grep supporting case-insensitive search,
# line numbering (-n), invert match (-v), and a help message (--help).

usage="Usage: $0 [OPTIONS] search_pattern file
Options:
  -n        Show line numbers for each match.
  -v        Invert match (print lines that do not match).
  --help    Display this help message."

# Check for help flag.
if [[ "$1" == "--help" ]]; then
    echo "$usage"
    exit 0
fi

# Initialize flags for options.
line_numbers=false
invert_match=false

# Parse options using getopts.
while getopts ":nv" opt; do
    case $opt in
        n)
            line_numbers=true
            ;;
        v)
            invert_match=true
            ;;
        \?)
            echo "Error: Invalid option -$OPTARG"
            echo "$usage"
            exit 1
            ;;
    esac
done

# Remove processed options from the arguments list.
shift $((OPTIND - 1))

# Validate that we have exactly two remaining arguments: search_pattern and file.
if [ "$#" -ne 2 ]; then
    echo "Error: Missing arguments."
    echo "$usage"
    exit 1
fi

search="$1"
file="$2"

# Check if the file exists.
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Initialize the line counter.
line_num=0

# Read the file line by line.
while IFS= read -r line; do
    ((line_num++))
    # Enable case-insensitive matching.
    shopt -s nocasematch
    if [[ "$line" == *"$search"* ]]; then
        is_match=true
    else
        is_match=false
    fi
    shopt -u nocasematch

    # Handle the invert (-v) option.
    if [ "$invert_match" = true ]; then
        if [ "$is_match" = true ]; then
            continue
        fi
    else
        if [ "$is_match" = false ]; then
            continue
        fi
    fi

    # Print the matching line, optionally with its line number.
    if [ "$line_numbers" = true ]; then
        echo "${line_num}:$line"
    else
        echo "$line"
    fi
done < "$file"

exit 0
