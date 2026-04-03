#!/bin/bash

OUT="obfuscate"

mkdir "$OUT"

find . -type f ! -path "./$OUT/*" | while read file; do
    rel="${file#./}"
    out="$OUT/$rel"

    mkdir -p "$(dirname "$out")"

    if [[ "$(basename "$file")" == "script.js" ]]; then
        echo "$rel"
        npx javascript-obfuscator "$file" --output "$out" > /dev/null 2>&1
    else
        cp "$file" "$out"
    fi
done
