# Telegram Integration Guide

## Overview
Configure your Telegram bot to send webhooks to the Cloudflare Worker, which will auto-start your Codespace when a message arrives.

## Architecture
```
Telegram Message → Telegram Bot Webhook → Cloudflare Worker → GitHub API → Start Codespace
                                                                           ↓
                                                                     Moltbot Gateway Auto-starts
```

## Option 1: Using Telegram Bot API Webhook (Recommended)

### Prerequisites
- Telegram Bot Token (from @BotFather)
- Your bot must be set up with moltbot

### Setup Steps

1. **Set Telegram webhook to trigger Cloudflare Worker:**

```bash
TELEGRAM_BOT_TOKEN="your_bot_token_here"
WEBHOOK_URL="https://codespace-autostarter.byron-zheng-yuan.workers.dev/"
WEBHOOK_SECRET="d64346eb8afb50339f691b4e682570787aeb99c8d27a00a5221b1a713962decc"

curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d "{
    \"url\": \"${WEBHOOK_URL}\",
    \"max_connections\": 40,
    \"allowed_updates\": [\"message\"]
  }"
```

**Note:** Telegram's setWebhook doesn't support custom headers, so we need to modify the worker to accept webhooks without the secret for Telegram, or use Option 2.

## Option 2: Modify Moltbot to Trigger Webhook (Simpler)

Add a webhook call inside your moltbot Telegram message handler:

### Steps

1. **Find your Telegram bot configuration** in moltbot
2. **Add a pre-processing webhook** before message handling:

```javascript
// Pseudo-code for moltbot plugin/extension
async function onTelegramMessage(message) {
  // Trigger Codespace wake-up
  await fetch('https://codespace-autostarter.byron-zheng-yuan.workers.dev/', {
    method: 'POST',
    headers: {
      'X-Webhook-Secret': 'd64346eb8afb50339f691b4e682570787aeb99c8d27a00a5221b1a713962decc',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ source: 'telegram', user: message.from.id })
  });
  
  // Wait a moment for Codespace to start (if it was stopped)
  await sleep(2000);
  
  // Continue with normal message processing
  return processMessage(message);
}
```

## Option 3: External Proxy Service

Use a service like n8n, Zapier, or Make (Integromat) to:
1. Receive Telegram webhooks
2. Forward to Cloudflare Worker with secret header
3. Forward original message to moltbot gateway

## Option 4: Simple Polling Script

If webhook setup is complex, use a lightweight polling script:

```bash
#!/bin/bash
# telegram-poller.sh - Polls Telegram and wakes Codespace on new messages

TELEGRAM_BOT_TOKEN="your_token"
WEBHOOK_URL="https://codespace-autostarter.byron-zheng-yuan.workers.dev/"
WEBHOOK_SECRET="d64346eb8afb50339f691b4e682570787aeb99c8d27a00a5221b1a713962decc"
OFFSET=0

while true; do
  # Get updates from Telegram
  RESPONSE=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=${OFFSET}&timeout=30")
  
  # Check if there are new messages
  MESSAGE_COUNT=$(echo "$RESPONSE" | jq '.result | length')
  
  if [ "$MESSAGE_COUNT" -gt 0 ]; then
    echo "New message detected! Triggering Codespace wake-up..."
    
    # Trigger Codespace
    curl -X POST "$WEBHOOK_URL" \
      -H "X-Webhook-Secret: $WEBHOOK_SECRET" \
      -H "Content-Type: application/json" \
      -d '{"source":"telegram-poller"}'
    
    # Update offset
    OFFSET=$(echo "$RESPONSE" | jq '.result[-1].update_id + 1')
  fi
  
  sleep 1
done
```

Run this on a cheap always-on server ($5/month) or free tier service like:
- Railway.app (free tier)
- Fly.io (free tier)
- Oracle Cloud (always free tier)

## Testing

After configuring, test the integration:

1. Stop your Codespace manually
2. Send a message to your Telegram bot
3. Wait ~30 seconds
4. Check if Codespace has started
5. Verify bot responds

## Recommended Approach

For your use case, I recommend **Option 4 (Polling Script)** because:
- ✅ Simple to implement
- ✅ Works with standard Telegram Bot API
- ✅ No webhook URL requirements
- ✅ Can run on free tier services
- ✅ Costs ~$0-5/month for hosting the poller

The poller is lightweight and will quickly detect messages to wake your Codespace.

## Next Steps

1. Choose an integration option
2. Test the wake-up flow
3. Monitor for a week to verify cost savings
4. Adjust timeout if needed

---

**Webhook URL:** https://codespace-autostarter.byron-zheng-yuan.workers.dev/  
**Secret:** d64346eb8afb50339f691b4e682570787aeb99c8d27a00a5221b1a713962decc
