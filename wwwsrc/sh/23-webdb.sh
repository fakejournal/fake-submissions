#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Ensure the output directory exists
mkdir -p wwwdist/webdb

# Base directory to scan
BASE_DIR="database"

# Check if required tools are installed
if ! command -v tomlq &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: 'tomlq' (from yq) and 'jq' are required to run this script." >&2
    exit 1
fi

echo "Processing database files..."

# Loop through the year directories using the explicit glob pattern
for year_dir in "$BASE_DIR"/*; do
    # Check if it's actually a directory
    [ -d "$year_dir" ] || continue
    
    # Extract just the year folder name
    year=$(basename "$year_dir")
    
    # Initialize an empty JSON array for the current year
    year_json="[]"
    file_found=false

    # Loop through the obj_id directories inside the year
    for info_file in "$year_dir"/*/info.toml; do
        # Handle cases where the glob matches nothing literal
        [ -f "$info_file" ] || continue
        file_found=true

        # Extract the obj_id from the parent directory name
        obj_id=$(basename "$(dirname "$info_file")")

        # Safely extract the title using tomlq
        # If .article.title doesn't exist, it defaults to null
        title=$(tomlq -r '.article.title // empty' "$info_file" 2>/dev/null || true)
        authors_simple=$(tomlq -r '.article.authors_simple // empty' "$info_file" 2>/dev/null || true)

        # Skip or handle missing titles gracefully (here we default to empty string if missing)
        if [ -z "$title" ]; then
            title="Untitled"
        fi

        # Append the new object to our temporary JSON array using jq
        year_json=$(echo "$year_json" | jq --arg id "$obj_id" --arg t "$title" --arg auth "$authors_simple" '. += [{"obj_id": $id, "title": $t, "authors_simple": $auth}]')
    done

    # If we successfully processed files for this year, write the JSON output
    if [ "$file_found" = true ]; then
        output_file="wwwdist/webdb/${year}.json"
        echo "$year_json" > "$output_file"
        echo "Saved: $output_file"
    fi
done

echo "Database compilation complete!"
