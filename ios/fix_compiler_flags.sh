#!/bin/bash
# Script to fix the -G compiler flag issue in xcconfig files

cd "$(dirname "$0")"
echo "Fixing compiler flags in xcconfig files..."

# Find all xcconfig files
files=$(find "Pods/Target Support Files" -name "*.xcconfig")

# Remove the -G flag from all xcconfig files
for file in $files; do
  if grep -q "\-G" "$file"; then
    echo "Fixing $file"
    # Create a temporary file
    tmp_file=$(mktemp)
    # Replace the -G flag with empty string
    sed 's/-G / /g; s/ -G / /g; s/ -G$//g' "$file" > "$tmp_file"
    # Move the temp file back
    mv "$tmp_file" "$file"
  fi
done

echo "Done fixing compiler flags"
