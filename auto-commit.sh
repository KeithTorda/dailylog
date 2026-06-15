#!/bin/bash

# Auto-commit multiple times daily for active GitHub contributions
# Random 15-25 commits per day at random times

REPO_DIR="/var/www/auto-commit"
LOG_DIR="$REPO_DIR/logs"
DAILY_DIR="$REPO_DIR/daily"

mkdir -p "$LOG_DIR" "$DAILY_DIR"

DATE=$(date +%Y-%m-%d)
NUM_COMMITS=$((RANDOM % 11 + 15))  # 15-25 commits

# Daily log header
cat > "$LOG_DIR/$DATE.md" << EOF
# Daily Log - $DATE

## System Activity
- Server: VPS3 (167.99.69.239)
- Uptime: $(uptime -p)
- Databases: $(mysql -u root -p'Keith082703.' -e 'SHOW DATABASES;' 2>/dev/null | wc -l) active
- Projects: $(ls /var/www/projects/ 2>/dev/null | wc -l) hosted
- Disk: $(df -h / | awk 'NR==2{print $3}')/$(df -h / | awk 'NR==2{print $2}')
- Memory: $(free -h | awk 'NR==2{print $3}')/$(free -h | awk 'NR==2{print $2}')

## Services
- Nginx: $(systemctl is-active nginx)
- MariaDB: $(systemctl is-active mariadb)
- PHP-FPM: $(systemctl is-active php8.3-fpm)

## Contributions: $NUM_COMMITS commits today
EOF

cd "$REPO_DIR"
git add .
git commit -m "Daily log: $DATE - System overview" 2>/dev/null

# Generate multiple random commits
COMMIT_MESSAGES=(
    "Update system status: $(date +%H:%M)"
    "Log server metrics: CPU $(cat /proc/loadavg | awk '{print $1}')"
    "Record disk usage: $(df -h / | awk 'NR==2{print $5}') used"
    "Track memory: $(free | awk 'NR==2{print $3}')MB allocated"
    "Monitor services: all systems operational"
    "Update project count: $(ls /var/www/projects/ | wc -l) active"
    "Log database status: $(mysql -u root -p'Keith082703.' -e 'SHOW DATABASES;' 2>/dev/null | wc -l) databases"
    "Record network: $(ss -tlnp | wc -l) active connections"
    "Track uptime: $(uptime -p)"
    "Monitor nginx: $(systemctl is-active nginx)"
    "Monitor mariadb: $(systemctl is-active mariadb)"
    "Monitor php-fpm: $(systemctl is-active php8.3-fpm)"
    "Log SSL certificates status"
    "Update deployment log"
    "Record system performance metrics"
    "Track resource allocation"
    "Monitor background processes"
    "Log cron job execution"
    "Update security scan results"
    "Record backup status"
    "Track user activity logs"
    "Monitor API response times"
    "Update health check status"
    "Log cache performance"
    "Record queue depths"
)

for i in $(seq 1 $NUM_COMMITS); do
    # Random commit message
    MSG_IDX=$((RANDOM % ${#COMMIT_MESSAGES[@]}))
    MSG="${COMMIT_MESSAGES[$MSG_IDX]}"

    # Create small file with random data
    RANDOM_FILE="$DAILY_DIR/$(date +%H%M%S)-$i.txt"
    echo "Commit $i of $NUM_COMMITS - $(date +%H:%M:%S)" > "$RANDOM_FILE"
    echo "Message: $MSG" >> "$RANDOM_FILE"
    echo "Random: $RANDOM" >> "$RANDOM_FILE"

    git add .
    git commit -m "$MSG" 2>/dev/null

    # Small delay to spread commits
    sleep 0.1
done

# Push all commits at once
git push origin main 2>/dev/null

echo "Done! $NUM_COMMITS commits pushed for $DATE"
