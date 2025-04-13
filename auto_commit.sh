#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Get the current timestamp for the commit message
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Stage all changes
git add .

# Only commit if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    # Commit with timestamp in message
    git commit -m "Auto-commit: $TIMESTAMP"
    
    # Push to GitHub
    git push origin main
    
    echo "Changes committed and pushed to GitHub at $TIMESTAMP"
fi
