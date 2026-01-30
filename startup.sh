#!/bin/bash
#
# Moltbot Auto-Startup Script
# This script automatically starts the moltbot gateway when the Codespace starts
#
# Usage: Add to .bashrc or .devcontainer/devcontainer.json postStartCommand

echo "🤖 Starting Moltbot Auto-Startup..."

# Wait for system to be ready
sleep 3

# Check if clawdbot is installed
if ! command -v clawdbot &> /dev/null; then
    echo "❌ clawdbot not found. Please install first."
    exit 1
fi

# Check if gateway is already running
if pgrep -f "clawdbot gateway" > /dev/null; then
    echo "✅ Moltbot gateway already running"
    exit 0
fi

# Start the gateway in the background
echo "🚀 Starting moltbot gateway..."
nohup clawdbot gateway > ~/gateway.log 2>&1 &
GATEWAY_PID=$!

# Wait a moment and check if it started
sleep 5

if pgrep -f "clawdbot-gateway" > /dev/null; then
    echo "✅ Moltbot gateway started successfully!"
    echo "📋 Gateway URL: ws://0.0.0.0:18789"
    echo "📝 Logs: ~/gateway.log"
    echo "🔢 PID: $(pgrep -f 'clawdbot-gateway')"
else
    echo "❌ Failed to start moltbot gateway"
    echo "📝 Check logs: ~/gateway.log"
    # Don't exit 1 - allow bashrc to continue
fi
