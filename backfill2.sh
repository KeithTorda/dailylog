#!/bin/bash

REPO_DIR="/var/www/auto-commit"
cd "$REPO_DIR"

mkdir -p backfill

echo "Creating backdated commits for the past year..."

# Create commits for each day in the past year
for i in $(seq 365 -1 1); do
    # Skip some days randomly (60% chance)
    if [ $((RANDOM % 10)) -gt 3 ]; then
        DATE=$(date -d "-${i} days" +%Y-%m-%d 2>/dev/null)
        HOUR=$((RANDOM % 14 + 8))
        MIN=$((RANDOM % 60))
        NUM=$((RANDOM % 11 + 10))

        for j in $(seq 1 $NUM); do
            TIMESTAMP="$DATE $HOUR:$(printf '%02d' $((MIN + j % 60))):00"
            MSG="System log: $DATE #$j"

            echo "$TIMESTAMP" > "backfill/$DATE-$j.tmp"
            GIT_AUTHOR_DATE="$TIMESTAMP" GIT_COMMITTER_DATE="$TIMESTAMP" \
                git add . && git commit -m "$MSG" 2>/dev/null
        done

        echo "$DATE: $NUM commits"
    fi
done

echo "Pushing..."
git push origin main 2>/dev/null
echo "Done!"
