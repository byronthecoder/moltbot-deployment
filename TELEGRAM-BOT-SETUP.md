# Complete Telegram Bot Setup for Moltbot

## Part 1: Create Telegram Bot (5 minutes)

### Step 1: Create Bot via BotFather

1. Open Telegram and search for **@BotFather**
2. Send: `/newbot`
3. Enter bot name (e.g., "My AI Assistant")
4. Enter bot username (must end in "bot", e.g., "myai_helper_bot")
5. **Copy the bot token** - looks like: `7123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`

### Step 2: Configure Bot Settings

Still in BotFather:
```
/setprivacy
→ Select your bot
→ Choose "Disable" (allows bot to see all messages in groups)

/setcommands
→ Select your bot
→ Send:
start - Start the bot
help - Get help
```

---

## Part 2: Configure Moltbot (10 minutes)

### Step 1: Check Your Current Agents

```bash
cat ~/.clawdbot/clawdbot.json | jq '.agents'
```

### Step 2: Add Telegram Channel to Your Main Agent

We'll update your existing agents to handle Telegram:

```bash
# Backup first
cp ~/.clawdbot/clawdbot.json ~/.clawdbot/clawdbot.json.backup

# Check if you have telegram agent
cat ~/.clawdbot/clawdbot.json | jq '.agents[] | select(.name=="telegram")'
```

If you already have a "telegram" agent, we just need to configure it. If not, let me know and I'll help add one.

### Step 3: Configure Telegram Bot Token

Run this command (replace YOUR_BOT_TOKEN with the token from BotFather):

```bash
clawdbot channel add telegram \
  --token "YOUR_BOT_TOKEN" \
  --agent "telegram"
```

Or manually edit the config:

```bash
# Edit the config
nano ~/.clawdbot/clawdbot.json
```

Look for the telegram agent and add the bot token:
```json
{
  "name": "telegram",
  "model": "github-copilot/claude-sonnet-4.5",
  "channels": [
    {
      "type": "telegram",
      "token": "YOUR_BOT_TOKEN_HERE"
    }
  ]
}
```

### Step 4: Restart Gateway

```bash
# Stop current gateway
pkill -f "clawdbot gateway"

# Start with new config
nohup clawdbot gateway > ~/gateway.log 2>&1 &

# Check it's running
ps aux | grep clawdbot
```

### Step 5: Test Your Bot

1. Open Telegram and search for your bot username
2. Send: `/start`
3. Send: "Hello!"
4. Bot should respond! 🎉

---

## Part 3: Setup Auto-Start Poller (After Bot Works)

Once your bot is responding to messages, then set up the poller to wake the Codespace:

1. Get your bot token (already have it)
2. Deploy poller script (see TELEGRAM-SETUP.md)
3. Test the full flow

---

## Quick Start If You Don't Have Telegram Agent Yet

Let me check your current setup and add the Telegram agent:

```bash
# Show me your current agents
cat ~/.clawdbot/clawdbot.json | jq '.agents'
```

Tell me what you see, and I'll help you add the Telegram configuration properly!

---

## Common Issues

### Bot doesn't respond
```bash
# Check gateway logs
tail -f ~/gateway.log

# Check if gateway is running
ps aux | grep clawdbot

# Verify bot token is correct
cat ~/.clawdbot/clawdbot.json | jq '.agents[] | select(.name=="telegram")'
```

### "Bot privacy mode" error
- Go back to @BotFather
- Send `/setprivacy`
- Select your bot
- Choose "Disable"

---

**Next:** Once your bot responds to messages, we'll add the poller for auto-wake!
