#!/bin/bash

set -e

ENV_DIR="env"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Environment Files Encryption Status:"
echo "-----------------------------------"

find "$ENV_DIR" -name "*.env" -type f | while read -r file; do
    if grep -q "SOPS" "$file"; then
        echo -e "${GREEN}[ENCRYPTED]${NC} $file"
    else
        echo -e "${RED}[DECRYPTED]${NC} $file"
    fi
done
