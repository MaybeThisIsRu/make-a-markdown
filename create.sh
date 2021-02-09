#!/bin/bash

supported_types=( "article" )

# Full current date including spaces in the format: YYYY-MM-DD HH:MM:SS +0530
get_full_date() {
    date "+%F\T%T%z"
}

get_short_date() {
    date "+%F"
}

# Takes a single argument of a single character
post_types_delimited() {
    echo ${supported_types[@]} | sed "s/ /$1/g"
}

validate_type_input() {
    # Type can only be article or note
    if [[  "${supported_types[@]}" =~ "${type}" ]]; then
        # Valid input
        echo "Post type OK."
    else
        # Invalid input
        echo "Incorrect post type specified!" >&2
        exit 1
    fi
}

# Get inputs as variables
get_input() {
    # TODO Default to article
    read -p "Type ($(post_types_delimited ', ')): " type
    validate_type_input
    read -p "Title: " title
    # TODO Automatically create a slug
    read -p "Slug: " slug
}

get_input

# Construct the location of the new content file
out_dir="./src/content/${type}s"
out_file="$(get_short_date)-${slug}.md"

if test -f "$out_dir/$out_file"; then
    # Redirect echo to STDERR
    echo "File already exists!" >&2
    # Exit with an error code of 1
    exit 1
else
    # Copy post type template to out location
    echo "Writing to $out"
    mkdir -p "$out_dir"
    cp "./content-template/$type" "$out_dir/$out_file"
fi

# The parantheses store the selection as '1' which we use later as \1
# \s denotes space
# Replace date
sed -i -E "s/(date:\s)/\1$(get_full_date)/" $out
# Replace title
sed -i -E "s/(title:\s)/\1\"$title\"/" $out
# Replace slug
sed -i -E "s/(slug\:\s)/\1\"$slug\"/" $out

echo "Done."

