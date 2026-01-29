# Quick Setup: Telegram → Codespace Auto-Start

## How It Works
```
Telegram Message → Poller Script → Cloudflare Webhook → Start Codespace → Moltbot Responds
```

The poller runs on a free server, checks for Telegram messages every 10 seconds, and wakes your Codespace when needed.

---

## Setup Steps (15 minutes)

### Step 1: Get Your Telegram Bot Token

You already have a Telegram bot configured with moltbot. Find your bot token:

```bash
# Check your moltbot config
cat ~/.clawdbot/clawdbot.json | jq '.agents[] | select(.name=="telegram")' 
```

Or get it from @BotFather on Telegram:
1. Message @BotFather
2. Send `/mybots`
3. Select your bot → API Token

Copy the token (format: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### Step 2: Deploy Poller to Railway (Free Tier)

**Option A: Use Railway (Recommended - Easy)**

1. **Install Railway CLI:**
   ```bash
   npm install -g @railway/cli
   ```

2. **Login:**
   ```bash
   railway login
   ```

3. **Deploy:**
   ```bash
   cd /workspaces/moltbot-deployment
   railway init
   railway up
   ```

4. **Set Environment Variables:**
   ```bash
   railway variables set TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
   railway variables set WEBHOOK_URL="https://codespace-autostarter.byron-zheng-yuan.workers.dev/"
   railway variables set WEBHOOK_SECRET="$(grep WEBHOOK_SECRET webhook-autostarter/.env | cut -d= -f2)"
   ```

5. **Keep it running:**
   ```bash
   railway run bash telegram-poller.sh
   ```

Railway free tier: 500 hours/month (plenty for 24/7 operation)

---

**Option B: Use Fly.io (Also Free)**

1. **Install Fly CLI:**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login:**
   ```bash
   flyctl auth login
   ```

3. **Create Dockerfile:**
   ```bash
   cat > Dockerfile.poller << 'EOF'
FROM alpine:latest
RUN apk add --no-cache bash curl jq
COPY telegram-poller.sh /app/telegram-poller.sh
RUN chmod +x /app/telegram-poller.sh
CMD ["/app/telegram-poller.sh"]
EOF
   ```

4. **Deploy:**
   ```bash
   flyctl launch --dockerfile Dockerfile.poller
   flyctl secrets set TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN"
   flyctl secrets set WEBHOOK_SECRET="YOUR_WEBHOOK_SECRET"
   flyctl secrets set WEBHOOK_URL="https://codespace-autostarter.byron-zheng-yuan.workers.dev/"
   ```

---

**Option C: Run on Your Own Server**

If you have any always-on machine (Raspberry Pi, old laptop, VPS):

```bash
# Download script
curl -O https://raw.githubusercontent.com/byronthecoder/moltbot-deployment/main/telegram-poller.sh
chmod +x telegram-poller.sh

# Set environment variables
export TELEGRAM_BOT_TOKEN="your_bot_token"
export WEBHOOK_SECRET="your_webhook_secret"
export WEBHOOK_URL="https://codespace-autostarter.byron-zheng-yuan.workers.dev/"

# Run in background
nohup ./telegram-poller.sh > telegram-poller.log 2>&1 &
```

To make it persistent, add to crontab:
```bash
@reboot cd /path/to/script && ./telegram-poller.sh >> telegram-poller.log 2>&1
```

---

## Step 3: Test It

1. **Stop your Codespace:**
   ```bash
   gh codespace stop -c orange-enigma-jqj77jg6gj42prv4
   ```

2. **Send a message to your Telegram bot**

3. **Wait 30-60 seconds** (Codespace startup time)

4. **Bot should respond!**

---

## What Happens When You Message Your Bot

```
1. Message sent to Telegram bot
   ↓
2. Poller detects new message (within 10 seconds)
   ↓
3. Poller triggers Cloudflare webhook
   ↓
4. Webhook calls GitHub API to start Codespace
   ↓
5. Codespace boots (~30 seconds)
   ↓
6. startup.sh runs automatically
   ↓
7. Moltbot gateway starts on port 18789
   ↓
8. Your bot processes the message and responds
```

**Total time:** 30-60 seconds for first message after Codespace stops

---

## Monitoring

### Check poller logs (Railway):
```bash
railway logs
```

### Check poller logs (Fly.io):
```bash
flyctl logs
```

### Check poller logs (own server):
```bash
tail -f telegram-poller.log
```

### Check Codespace was started:
```bash
gh codespace list
```

---

## Cost Summary

| Service | Cost | Purpose |
|---------|------|---------|
| Railway/Fly.io | $0 (free tier) | Run poller |
| Cloudflare Worker | $0 (free tier) | Handle webhook |
| GitHub Codespace | $11-22/month | On-demand (2-4 hrs/day) |
| **Total** | **$11-22/month** | 85% savings vs $130/month |

---

## Troubleshooting

### Poller not detecting messages
- Check bot token is correct
- Verify bot is not in privacy mode (talk to @BotFather)

### Webhook not triggering
- Check webhook secret is correct
- View webhook logs: `cd webhook-autostarter && npx wrangler tail`

### Codespace not starting
- Verify GitHub token has `codespace` scope
- Check token hasn't expired

### Bot not responding after 60 seconds
- SSH into Codespace: `gh codespace ssh`
- Check gateway: `ps aux | grep clawdbot`
- Check logs: `tail ~/gateway.log`

---

## Quick Reference

**Environment Variables for Poller:**
```bash
TELEGRAM_BOT_TOKEN=123456789:ABC...  # From @BotFather
WEBHOOK_URL=https://codespace-autostarter.byron-zheng-yuan.workers.dev/
WEBHOOK_SECRET=d64346eb8afb50339f691b4e682570787aeb99c8d27a00a5221b1a713962decc
```

**Files:**
- Poller script: `/workspaces/moltbot-deployment/telegram-poller.sh`
- Webhook secrets: `/workspaces/moltbot-deployment/webhook-autostarter/.env`

**Next:** After setup, configure 30-minute timeout at https://github.com/settings/codespaces
