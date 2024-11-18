#!/bin/bash
set -e

# Configuration
ENV_DIR="env"
BACKUP_DIR="$ENV_DIR/backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if ENV_DIR exists
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}Error: Environment directory not found: $ENV_DIR${NC}"
    exit 1
fi

# Check if BACKUP_DIR exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found: $BACKUP_DIR${NC}"
    exit 1
fi

list_backups() {
    local file="$1"
    local base_name=$(basename "$file")
    # Fix: Use array to store backups
    readarray -t backups < <(find "$BACKUP_DIR" -name "${base_name}.*" -type f | sort -r)

    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}No backups found for $base_name${NC}"
        return 1
    fi

    echo -e "${BLUE}Available backups for $base_name:${NC}"
    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        # Improved timestamp extraction
        local timestamp=$(basename "$backup" | grep -o '[0-9]\{8\}_[0-9]\{6\}' || echo "No timestamp")
        echo "[$i] $(basename "$backup") (${timestamp})"
    done

    return 0
}

# Function to rollback a single file
rollback_file() {
    local file="$1"
    local base_name=$(basename "$file")

    echo -e "\n${YELLOW}Processing: $base_name${NC}"

    if ! list_backups "$file"; then
        return 1
    fi

    # Fix: Use array to store backups
    readarray -t backups < <(find "$BACKUP_DIR" -name "${base_name}.*" -type f | sort -r)

    echo -e "${YELLOW}Enter backup number to restore [0-$((${#backups[@]} - 1))] or 'q' to skip: ${NC}"
    read -r selection

    if [[ "$selection" == "q" ]]; then
        echo -e "${YELLOW}Skipping $base_name${NC}"
        return 0
    fi

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#backups[@]}" ]; then
        echo -e "${RED}Invalid selection${NC}"
        return 1
    fi

    local selected_backup="${backups[$selection]}"

    # Verify backup file exists
    if [ ! -f "$selected_backup" ]; then
        echo -e "${RED}Error: Selected backup file not found: $selected_backup${NC}"
        return 1
    fi

    # Create a backup of current file before rollback
    local current_timestamp=$(date +%Y%m%d_%H%M%S)
    local pre_rollback_backup="$BACKUP_DIR/${base_name}.pre_rollback.${current_timestamp}"

    # Verify current file exists before backing up
    if [ -f "$file" ]; then
        echo -e "${YELLOW}Creating safety backup: $(basename "$pre_rollback_backup")${NC}"
        if ! cp "$file" "$pre_rollback_backup"; then
            echo -e "${RED}Error: Failed to create safety backup${NC}"
            return 1
        fi
    fi

    # Perform rollback
    echo -e "${YELLOW}Rolling back to: $(basename "$selected_backup")${NC}"
    if ! cp "$selected_backup" "$file"; then
        echo -e "${RED}Error: Failed to rollback file${NC}"
        return 1
    fi

    echo -e "${GREEN}Successfully rolled back $base_name${NC}"
}

# Main rollback process
echo "Starting environment files rollback..."

# Fix: Handle no .env files case
env_files=($(find "$ENV_DIR" -name "*.env" -type f))
if [ ${#env_files[@]} -eq 0 ]; then
    echo -e "${YELLOW}No .env files found in $ENV_DIR${NC}"
    exit 0
fi

# Process each .env file
for file in "${env_files[@]}"; do
    rollback_file "$file"
done

echo -e "\n${GREEN}Rollback process completed!${NC}"
