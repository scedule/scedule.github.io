#!/bin/bash

TARGET="beta/updates.json"

if [ ! -f "$TARGET" ]; then
    echo "Error: $TARGET not found."
    exit 1
fi

if [ $# -lt 2 ]; then
    echo "Usage: $0 \"Version\" \"Change 1\" \"Change 2\" ..."
    exit 1
fi

VERSION="$1"
shift

TODAY=$(date +"%-m/%-d")

# Pass changes safely as jq array
jq --arg version "$VERSION" \
   --arg today "$TODAY" \
   --argjson changes "$(printf '%s\n' "$@" | jq -R . | jq -s .)" '

# If first entry is current and there is a previous entry
if (length > 1 and .[0].date == "current") then

    # Get end date from second entry
    (.[1].date | split("-") | .[1]) as $prevEnd |

    # Update first entry to proper range
    .[0].date = ($prevEnd + "-" + $today)

else
    .
end

# Insert new entry at top
| [ { version: $version,
      date: "current",
      changes: $changes } ] + .
' "$TARGET" > "$TARGET.tmp" && mv "$TARGET.tmp" "$TARGET"

# Remove any accidental date entries from changes arrays
jq 'map(.changes |= map(select(test("^[0-9]{1,2}/[0-9]{1,2}-[0-9]{1,2}/[0-9]{1,2}$") | not)))' "$TARGET" > "$TARGET.tmp" \
    && mv "$TARGET.tmp" "$TARGET"


echo "Released $VERSION"
