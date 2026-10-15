#!/bin/bash

# Create the .prompt directory if it doesn't exist
mkdir -p .prompt

rm -rf .prompt/*

# Find all files recursively, excluding .git and .prompt directories
find . -mindepth 1 \
  -not -path './.git*' \
  -not -path './.prompt*' \
  -type f | while read -r file; do

    # Strip the leading './' and replace all slashes with underscores
    clean_name=$(echo "$file" | sed 's|^\./||' | tr '/' '_')

    # Copy and rename into the target format
    cp "$file" ".prompt/template_output_${clean_name}"
done

# Generate the directory tree inside .prompt
tree -I '.git|.prompt' > .prompt/tree.txt
