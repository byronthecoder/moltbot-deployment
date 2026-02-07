#!/bin/bash
# scripts/check_secrets.sh
# Scans the repository for potential hardcoded credentials.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Scanning for potential hardcoded credentials...${NC}"

# Define patterns
# 1. Telegram Bot Token: numbers:alpha-numeric
TG_TOKEN_PATTERN="[0-9]\{8,12\}:[a-zA-Z0-9_-]\{35\}"
# 2. Google AI API Key: Starts with AIza
GOOGLE_API_PATTERN="AIzaSy[a-zA-Z0-9_-]\{33\}"
# 3. Webhook Secret (typical 64-char hex)
WEBHOOK_PATTERN="[a-f0-9]\{64\}"

EXIT_CODE=0

check_pattern() {
    local pattern=$1
    local name=$2
    local results
    
    # Search in all files except .env, .git, and this script itself
    results=$(grep -rnE "$pattern" . \
        --exclude=".env" \
        --exclude-dir=".git" \
        --exclude="check_secrets.sh" \
        --exclude="*.md" \
        --exclude="*.example" 2>/dev/null)
    
    if [ -n "$results" ]; then
        echo -e "${RED}❌ Found potential $name leakage:${NC}"
        echo "$results"
        EXIT_CODE=1
    else
        echo -e "${GREEN}✅ No $name patterns found in code/scripts.${NC}"
    fi
}

# Run checks
check_pattern "$TG_TOKEN_PATTERN" "Telegram Bot Token"
check_pattern "$GOOGLE_API_PATTERN" "Google API Key"
check_pattern "$WEBHOOK_PATTERN" "Webhook/Secret"

# Check .env files in .gitignore
if ! git check-ignore -q .env; then
    echo -e "${RED}❌ .env is NOT ignored by git!${NC}"
    EXIT_CODE=1
else
    echo -e "${GREEN}✅ .env is correctly ignored.${NC}"
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}✨ Sanity check passed! No obvious credentials leaked.${NC}"
else
    echo -e "\n${RED}⚠️  Sanity check failed. Please remove the credentials before pushing.${NC}"
fi

exit $EXIT_CODE
