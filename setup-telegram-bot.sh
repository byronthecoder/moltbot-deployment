#!/bin/bash
#
# Interactive Telegram Bot Setup for Moltbot
#

echo "=================================="
echo "🤖 Telegram Bot Setup for Moltbot"
echo "=================================="
echo ""

# Step 1: Get bot token
echo "📱 Step 1: Create Telegram Bot"
echo ""
echo "1. Open Telegram and search for @BotFather"
echo "2. Send: /newbot"
echo "3. Follow the prompts to create your bot"
echo "4. Copy the bot token (looks like: 123456789:ABC...)"
echo ""
read -p "Enter your Telegram bot token: " BOT_TOKEN

if [ -z "$BOT_TOKEN" ]; then
    echo "❌ Bot token is required"
    exit 1
fi

echo ""
echo "✅ Bot token received: ${BOT_TOKEN:0:15}..."
echo ""

# Step 2: Use clawdbot to configure
echo "📝 Step 2: Configuring Telegram channel..."
echo ""
echo "Run this command to add Telegram to your moltbot:"
echo ""
echo "clawdbot configure"
echo ""
echo "Then in the interactive wizard:"
echo "  1. Select 'Channels & Devices'"
echo "  2. Choose 'Add a channel'"
echo "  3. Select 'Telegram'"
echo "  4. Paste your bot token: $BOT_TOKEN"
echo "  5. Save and exit"
echo ""
read -p "Press Enter to open the configuration wizard..."

clawdbot configure

echo ""
echo "=================================="
echo "✅ Configuration Complete!"
echo "=================================="
echo ""
echo "🧪 Test your bot:"
echo "  1. Open Telegram"
echo "  2. Search for your bot"
echo "  3. Send: /start"
echo "  4. Send: Hello!"
echo ""
echo "If bot responds, proceed to setup auto-wake poller!"
echo ""
echo "📖 Next steps: See TELEGRAM-SETUP.md for poller setup"
