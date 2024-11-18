#!/bin/bash

set -e

# Configuration
ENV_DIR="env"
TEMP_DIR="/tmp/env_decrypt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check requirements
if [ ! -f "key.txt" ]; then
    echo -e "${RED}Error: key.txt not found in current directory${NC}"
    exit 1
fi

mkdir -p "$TEMP_DIR"

export SOPS_AGE_KEY_FILE="$PWD/key.txt"

decrypt_file() {
    local file="$1"
    local temp_file="$TEMP_DIR/$(basename "$file")"
    local decrypted_name="${file%.encrypted}"

    echo -e "${YELLOW}Decrypting: $file${NC}"

    if sops --input-type dotenv --output-type dotenv -d "$file" >"$temp_file" 2>/dev/null; then
        if mv "$temp_file" "$decrypted_name"; then
            echo -e "${GREEN}Successfully decrypted: $file -> $decrypted_name${NC}"
        else
            echo -e "${RED}Error: Failed to move decrypted file${NC}"
            mv "$backup_file" "$file"
            rm -f "$temp_file"
            return 1
        fi
    fi
}

echo "Starting environment files decryption..."

find "$ENV_DIR" -name "*.encrypted" -type f | while read -r file; do
    decrypt_file "$file"
done

rm -rf "$TEMP_DIR"

echo -e "${GREEN}Decryption process completed!${NC}"
