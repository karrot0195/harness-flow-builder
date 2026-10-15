#!/bin/bash

mkdir -p .prompt
rm -rf .prompt/*

find . -mindepth 1 \
  -not -path './.git*' \
  -not -path './.prompt*' \
  -type f | while read -r file; do
    clean_name=$(echo "$file" | sed 's|^\./||' | tr '/' '_')
    cp "$file" ".prompt/template_output_${clean_name}"
done

tree -I '.git|.prompt' > .prompt/tree.txt
