#!/bin/bash
#
# Moltbot Auto-Startup Script for GitHub Codespaces
# This script is triggered by .devcontainer/devcontainer.json postStartCommand
#

# Persistence log for debugging
DEBUG_LOG="/home/codespace/startup_debug.log"
echo "[$(date)] --- Startup script triggered ---" >> "$DEBUG_LOG"

# Ensure config persistence
PERSISTENT_CONFIG="/workspaces/moltbot-deployment/.clawdbot"
if [ ! -L "$HOME/.clawdbot" ]; then
    echo "[$(date)] Creating symlink for persistence" >> "$DEBUG_LOG"
    rm -rf "$HOME/.clawdbot"
    ln -s "$PERSISTENT_CONFIG" "$HOME/.clawdbot"
fi

# Wait for system to be ready
sleep 5


# Load environment variables manually
ENV_FILE="/workspaces/moltbot-deployment/.env.local"
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

echo "🤖 Starting Moltbot Auto-Startup..."

# Wakeup bot credentials (should be set via environment)
# WAKEUP_BOT_TOKEN="your_token_here"
# WAKEUP_CHAT_ID="your_chat_id_here"

# Helper to send Telegram notification via wakeup bot
send_notification() {
    local message="$1"
    echo "[$(date)] Notification: $message" >> "$DEBUG_LOG"
    if [ -n "$WAKEUP_BOT_TOKEN" ] && [ -n "$WAKEUP_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${WAKEUP_BOT_TOKEN}/sendMessage" \
          -d "chat_id=${WAKEUP_CHAT_ID}" \
          -d "text=${message}" >> "$DEBUG_LOG" 2>&1
    fi
}

# Notify: Codespace started
send_notification "✅ Codespace is UP! Now launching Moltbot gateway..."

# Check if clawdbot is installed
CLAWDBOT_CMD="/home/codespace/nvm/current/bin/clawdbot"
[ ! -f "$CLAWDBOT_CMD" ] && CLAWDBOT_CMD=$(type -P clawdbot)


if [ -z "$CLAWDBOT_CMD" ]; then
    echo "❌ clawdbot not found."
    send_notification "❌ Moltbot startup failed: clawdbot not found. Check logs for details."
    exit 1
fi

# Check if gateway already running
if pgrep -f "moltbot-gateway|clawdbot gateway" > /dev/null; then
    echo "✅ Gateway already running"
    send_notification "✅ Moltbot gateway is already running! Ready to chat. 🦞"
    exit 0
fi

# Start gateway
echo "🚀 Starting moltbot gateway..."
nohup "$CLAWDBOT_CMD" gateway > /home/codespace/gateway.log 2>&1 &
GATEWAY_PID=$!
disown $GATEWAY_PID

sleep 20

if pgrep -f "moltbot-gateway|clawdbot gateway" > /dev/null; then
    echo "✅ Success"
    send_notification "✅ Moltbot gateway is UP and ready! You can chat now. 🦞"
else
    echo "❌ Failed"
    # Get last few lines of gateway log for diagnostics
    ERROR_LOG=$(tail -n 5 /home/codespace/gateway.log 2>/dev/null | head -n 2)
    if [ -n "$ERROR_LOG" ]; then
        send_notification "❌ Moltbot gateway failed to start.

Error: $ERROR_LOG

Check ~/gateway.log for details."
    else
        send_notification "❌ Moltbot gateway failed to start. No error log available. Check ~/gateway.log"
    fi
fi
