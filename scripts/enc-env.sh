#!/bin/bash

set -e

ENV_DIR="env"
BACKUP_DIR="$ENV_DIR/backup"
TEMP_DIR="/tmp/env_encrypt"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f "key.txt" ]; then
    echo -e "${RED}Error: key.txt not found in current directory${NC}"
    exit 1
fi

if [ ! -f ".sops.yaml" ]; then
    echo -e "${RED}Error: .sops.yaml not found. Run setup-sops-config.sh first${NC}"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMP_DIR"

export SOPS_AGE_KEY_FILE="$PWD/key.txt"
encrypt_file() {
    local file="$1"
    local encrypted_file="${file}.encrypted"
    local tmp="${TEMP_DIR}/$(basename "$file")"
    local backup_file="$BACKUP_DIR/$(basename "$file").$TIMESTAMP"

    cp "$file" "$backup_file"
    rm $tmp 2>/dev/null || true

    echo -e "${YELLOW}Encrypting: $file${NC}"

    if sops -e "$file" >"$tmp"; then
        mv "$tmp" "$encrypted_file"
        echo -e "${GREEN}Successfully encrypted: $file${NC}"
    else
        echo -e "${RED}Failed to encrypt: $file${NC}"
        cp "$backup_file" "$file"
        return 1
    fi
}

echo "Starting environment files encryption..."

find "$ENV_DIR" -name "*.env" -not -name "*.encrypted" -type f | while read -r file; do
    if grep -q "SOPS" "$file"; then
        echo -e "${YELLOW}Skipping already encrypted file: $file${NC}"
    else
        encrypt_file "$file"
    fi
done

rm -rf "$TEMP_DIR"

echo -e "${GREEN}Encryption process completed!${NC}"
echo "Backups stored in: $BACKUP_DIR"
