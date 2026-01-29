#!/bin/bash
#
# Telegram Polling Script - Wakes Codespace on Telegram Messages
# Deploy this on any free tier service (Railway, Fly.io, Oracle Cloud, etc.)
#

# Configuration - Set these as environment variables
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
WEBHOOK_URL="${WEBHOOK_URL:-https://codespace-autostarter.byron-zheng-yuan.workers.dev/}"
WEBHOOK_SECRET="${WEBHOOK_SECRET}"
CHECK_INTERVAL="${CHECK_INTERVAL:-10}"

if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$WEBHOOK_SECRET" ]; then
    echo "Error: TELEGRAM_BOT_TOKEN and WEBHOOK_SECRET must be set"
    exit 1
fi

OFFSET=0
LAST_TRIGGER=0
COOLDOWN=300  # 5 minutes cooldown between triggers

echo "🤖 Telegram Poller Started"
echo "   Bot Token: ${TELEGRAM_BOT_TOKEN:0:10}..."
echo "   Webhook: $WEBHOOK_URL"
echo "   Check Interval: ${CHECK_INTERVAL}s"
echo ""

while true; do
    # Get updates from Telegram
    RESPONSE=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=${OFFSET}&timeout=${CHECK_INTERVAL}")
    
    # Check if there are new messages
    MESSAGE_COUNT=$(echo "$RESPONSE" | jq -r '.result | length' 2>/dev/null || echo "0")
    
    if [ "$MESSAGE_COUNT" -gt 0 ]; then
        CURRENT_TIME=$(date +%s)
        TIME_SINCE_LAST=$((CURRENT_TIME - LAST_TRIGGER))
        
        # Only trigger if cooldown period has passed
        if [ $TIME_SINCE_LAST -gt $COOLDOWN ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] New message detected! Triggering Codespace wake-up..."
            
            # Trigger Codespace
            TRIGGER_RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
              -H "X-Webhook-Secret: $WEBHOOK_SECRET" \
              -H "Content-Type: application/json" \
              -d '{"source":"telegram-poller","timestamp":"'$(date -Iseconds)'"}')
            
            echo "   Webhook response: $TRIGGER_RESPONSE"
            LAST_TRIGGER=$CURRENT_TIME
        else
            REMAINING=$((COOLDOWN - TIME_SINCE_LAST))
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Message received but in cooldown (${REMAINING}s remaining)"
        fi
        
        # Update offset to mark messages as read
        OFFSET=$(echo "$RESPONSE" | jq -r '.result[-1].update_id + 1' 2>/dev/null || echo "$OFFSET")
    fi
    
    sleep 1
done
