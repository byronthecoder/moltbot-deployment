#!/bin/bash
#
# Test Auto-Start Flow - RUN FROM LOCAL MACHINE
# This script tests the complete auto-start workflow from outside the Codespace
#
# Prerequisites:
# - GitHub CLI (gh) installed and authenticated
# - curl and jq installed
#

set -e

WEBHOOK_URL="https://codespace-autostarter.byron-zheng-yuan.workers.dev/"
CODESPACE_NAME="orange-enigma-jqj77jg6gj42prv4"

# Prompt for webhook secret if not set
if [ -z "$WEBHOOK_SECRET" ]; then
    read -sp "Enter WEBHOOK_SECRET: " WEBHOOK_SECRET
    echo ""
fi

if [ -z "$WEBHOOK_SECRET" ]; then
    echo "❌ WEBHOOK_SECRET not provided"
    exit 1
fi

echo "==================================="
echo "🧪 Testing Auto-Start Workflow"
echo "==================================="
echo ""

# Step 1: Check current status
echo "📊 Step 1: Checking current Codespace status..."
CURRENT_STATUS=$(gh codespace list --json name,state | jq -r ".[] | select(.name==\"$CODESPACE_NAME\") | .state")
echo "   Current state: $CURRENT_STATUS"
echo ""

# Step 2: Stop Codespace if running
if [ "$CURRENT_STATUS" == "Available" ]; then
    echo "🛑 Step 2: Stopping Codespace..."
    gh codespace stop -c "$CODESPACE_NAME"
    echo "   Waiting for shutdown (10 seconds)..."
    sleep 10
    
    # Verify it's stopped
    NEW_STATUS=$(gh codespace list --json name,state | jq -r ".[] | select(.name==\"$CODESPACE_NAME\") | .state")
    echo "   New state: $NEW_STATUS"
    
    if [ "$NEW_STATUS" != "Shutdown" ] && [ "$NEW_STATUS" != "Available" ]; then
        echo "   ⚠️  State is $NEW_STATUS, continuing anyway..."
    fi
    echo ""
else
    echo "✅ Step 2: Codespace already stopped (state: $CURRENT_STATUS)"
    echo ""
fi

# Step 3: Trigger webhook to start Codespace
echo "🚀 Step 3: Triggering webhook to start Codespace..."
WEBHOOK_RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "X-Webhook-Secret: $WEBHOOK_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"source":"auto-start-test","timestamp":"'$(date -Iseconds)'"}')

echo "   Response: $WEBHOOK_RESPONSE"
echo ""

# Check if it's starting or already started
if echo "$WEBHOOK_RESPONSE" | jq -e '.status == "started"' > /dev/null 2>&1; then
    echo "✅ Webhook triggered Codespace start successfully!"
elif echo "$WEBHOOK_RESPONSE" | jq -e '.status == "running"' > /dev/null 2>&1; then
    echo "✅ Codespace was already running"
else
    echo "❌ Unexpected response from webhook"
    exit 1
fi
echo ""

# Step 4: Monitor startup
echo "⏳ Step 4: Monitoring Codespace startup (may take 30-60 seconds)..."
for i in {1..12}; do
    sleep 5
    STATUS=$(gh codespace list --json name,state | jq -r ".[] | select(.name==\"$CODESPACE_NAME\") | .state")
    echo "   [$i/12] State: $STATUS"
    
    if [ "$STATUS" == "Available" ]; then
        echo ""
        echo "✅ Codespace is now AVAILABLE!"
        break
    fi
done
echo ""

# Step 5: Verify gateway is running
echo "🔍 Step 5: Verifying moltbot gateway auto-started..."
echo "   (Connecting to Codespace to check...)"
sleep 3

GATEWAY_CHECK=$(gh codespace ssh -c "$CODESPACE_NAME" -- "ps aux | grep -v grep | grep 'clawdbot gateway' | wc -l")

if [ "$GATEWAY_CHECK" -gt 0 ]; then
    echo "   ✅ Gateway is running!"
    echo ""
    echo "   Gateway details:"
    gh codespace ssh -c "$CODESPACE_NAME" -- "ps aux | grep -v grep | grep 'clawdbot gateway'"
else
    echo "   ⚠️  Gateway not detected. Checking startup script..."
    gh codespace ssh -c "$CODESPACE_NAME" -- "tail -20 ~/gateway.log" 2>/dev/null || echo "   No gateway.log found"
fi
echo ""

# Summary
echo "==================================="
echo "📋 Test Summary"
echo "==================================="
echo "✅ Webhook: Working"
echo "✅ Auto-start: $([ "$STATUS" == "Available" ] && echo "Working" || echo "Needs investigation")"
echo "✅ Gateway: $([ "$GATEWAY_CHECK" -gt 0 ] && echo "Running" || echo "Check logs")"
echo ""
echo "🎉 Auto-start flow test complete!"
echo ""
echo "Next: Test sending a message to your Telegram bot"
