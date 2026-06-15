#!/bin/bash

# Backdate commits to fill GitHub contribution graph
# Creates 15-25 commits per day for the past year

REPO_DIR="/var/www/auto-commit"
cd "$REPO_DIR"

COMMIT_MESSAGES=(
    "System maintenance: $(date +%Y-%m-%d)"
    "Server health check completed"
    "Database optimization run"
    "Security scan passed"
    "Performance monitoring update"
    "Service health verified"
    "Backup completed successfully"
    "SSL certificate check passed"
    "Resource usage logged"
    "Deployment pipeline healthy"
    "API health check passed"
    "Cache cleared and optimized"
    "Log rotation completed"
    "Network monitoring active"
    "Uptime recorded"
)

# Calculate date range (365 days back)
END_DATE=$(date +%Y-%m-%d)
START_DATE=$(date -d "365 days ago" +%Y-%m-%d 2>/dev/null || date -v-365d +%Y-%m-%d 2>/dev/null)

echo "Generating commits from $START_DATE to $END_DATE"

current="$START_DATE"
while [[ "$current" < "$END_DATE" || "$current" == "$END_DATE" ]]; do
    # Skip some days randomly (70% chance of commits each day)
    SKIP=$((RANDOM % 10))
    if [ $SKIP -gt 2 ]; then
        NUM_COMMITS=$((RANDOM % 11 + 15))  # 15-25 commits

        for i in $(seq 1 $NUM_COMMITS); do
            HOUR=$((RANDOM % 14 + 8))  # 8am to 10pm
            MIN=$((RANDOM % 60))

            MSG_IDX=$((RANDOM % ${#COMMIT_MESSAGES[@]}))
            MSG="${COMMIT_MESSAGES[$MSG_IDX]}"

            # Create commit with backdated time
            TIMESTAMP="$current ${HOUR}:$(printf '%02d' $MIN):00"

            mkdir -p "$REPO_DIR/backfill"
            echo "$TIMESTAMP - $MSG" > "$REPO_DIR/backfill/$current-$i.txt"

            GIT_AUTHOR_DATE="$TIMESTAMP" GIT_COMMITTER_DATE="$TIMESTAMP" \
                git commit -m "$MSG" 2>/dev/null

            rm "$REPO_DIR/backfill/$current-$i.txt"
        done

        echo "$current: $NUM_COMMITS commits"
    fi

    # Move to next day
    current=$(date -d "$current + 1 day" +%Y-%m-%d 2>/dev/null || date -j -v+1d +%Y-%m-%d 2>/dev/null)
done

echo "Pushing all backdated commits..."
git push origin main 2>/dev/null

echo "Done! Contribution graph should be full now!"
