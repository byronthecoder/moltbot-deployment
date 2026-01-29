# Webhook Auto-Starter for Codespace

This solution automatically starts your GitHub Codespace when messages arrive from Telegram or WhatsApp, ensuring your moltbot is always ready to respond while minimizing costs.

## Architecture

```
Telegram/WhatsApp Message → Cloudflare Worker → GitHub API → Start Codespace
                                    ↓
                            Check if already running
                            (avoid unnecessary restarts)
```

## Setup Instructions

### Step 1: Create GitHub Personal Access Token

1. Go to https://github.com/settings/tokens/new
2. Token name: `Codespace Auto-Starter`
3. Expiration: Choose your preference (recommend: 90 days)
4. Select scopes:
   - ✅ **codespace** (full access)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)

### Step 2: Deploy Cloudflare Worker (Free)

1. Sign up at https://dash.cloudflare.com/sign-up (free tier)
2. Go to Workers & Pages → Create Application → Create Worker
3. Name: `codespace-autostarter`
4. Click "Deploy" (default code doesn't matter)
5. Click "Edit Code"
6. Copy the contents of `cloudflare-worker.js` into the editor
7. Click "Save and Deploy"

### Step 3: Configure Environment Variables

1. In Cloudflare Worker dashboard, go to Settings → Variables
2. Add these environment variables:

   | Variable | Value | Type |
   |----------|-------|------|
   | `GITHUB_TOKEN` | Your GitHub PAT from Step 1 | Secret (encrypted) |
   | `CODESPACE_NAME` | `orange-enigma-jqj77jg6gj42prv4` | Text |
   | `WEBHOOK_SECRET` | Generate random string (see below) | Secret (encrypted) |

3. Generate webhook secret:
   ```bash
   openssl rand -hex 32
   # Or use: https://www.random.org/strings/
   ```

4. Save all variables

### Step 4: Get Worker URL

Your worker URL will be: `https://codespace-autostarter.YOUR_SUBDOMAIN.workers.dev`

Copy this URL for the next steps.

### Step 5: Configure Telegram Webhook (If using Telegram)

Moltbot likely has Telegram bot integration. You need to add a webhook forwarder:

**Option A: Modify moltbot to call webhook**
Add this to your Telegram message handler in moltbot config:

```javascript
// When message arrives, call webhook
await fetch('https://codespace-autostarter.YOUR_SUBDOMAIN.workers.dev', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Webhook-Secret': 'YOUR_WEBHOOK_SECRET'
  },
  body: JSON.stringify({
    source: 'telegram',
    timestamp: new Date().toISOString()
  })
})
```

**Option B: Use Telegram Bot API Webhook**
Configure your Telegram bot to send webhooks:

```bash
# Set webhook URL
curl "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=https://codespace-autostarter.YOUR_SUBDOMAIN.workers.dev"
```

Then modify the Cloudflare Worker to:
1. Receive Telegram webhook
2. Start codespace if needed
3. Forward message to moltbot gateway

### Step 6: Configure WhatsApp Webhook (If using WhatsApp)

WhatsApp Business API webhooks work similarly. Update your WhatsApp webhook configuration to point to the Cloudflare Worker.

## Testing

### Test the Worker Directly

```bash
# Test with curl
curl -X POST https://codespace-autostarter.YOUR_SUBDOMAIN.workers.dev \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: YOUR_WEBHOOK_SECRET" \
  -d '{"test": true}'

# Expected responses:
# - If codespace is running: {"status":"running","message":"Codespace already available"}
# - If codespace is stopped: {"status":"started","message":"Codespace is starting up"}
```

### Monitor Worker Logs

1. Go to Cloudflare Workers dashboard
2. Click on your worker
3. Go to "Logs" tab (real-time)
4. Send a test message
5. Watch for:
   - Webhook received
   - Codespace status check
   - Start command (if needed)

## Cost Analysis

### Cloudflare Worker (Free Tier)
- **100,000 requests/day FREE**
- Your usage: ~100-500 messages/day
- **Cost: $0/month**

### GitHub Codespace
- Only runs when you're actively using it
- Auto-starts on message: ~5 seconds boot time
- Auto-stops after 30 minutes of inactivity
- **Cost: $0.18/hour while running**

### Example Scenario
If you receive:
- 20 messages/day spread throughout the day
- Each triggers 2-hour session (30 min timeout + additional usage)
- Total: 2 hours/day = 60 hours/month
- **Cost: $10.80/month** (vs $130/month 24/7)
- **Savings: $119/month (91%)**

## How It Works

1. **Message arrives** → Telegram/WhatsApp sends webhook
2. **Worker receives** → Validates webhook secret
3. **Check status** → Queries GitHub API for codespace state
4. **If stopped** → Sends start command to GitHub API
5. **Boot time** → ~20-30 seconds until ready
6. **Auto-stop** → After 30 minutes of inactivity

## Optimization Tips

### Reduce Cold Start Impact

The codespace takes ~30 seconds to boot. To minimize this:

1. **Pre-warming**: If you know you'll use moltbot at certain times, set up a scheduled action to start it proactively (e.g., 7:30 AM daily)

2. **Longer timeout**: Keep codespace running longer (e.g., 60 minutes) to avoid frequent restarts during active periods

### GitHub Actions Pre-Warmer (Optional)

Create `.github/workflows/prewarm-codespace.yml`:

```yaml
name: Pre-warm Codespace

on:
  schedule:
    # Start at 7:30 AM Paris time (Mon-Fri)
    - cron: '30 6 * * 1-5'  # 6:30 UTC = 7:30 Paris winter
  workflow_dispatch:  # Allow manual trigger

jobs:
  start-codespace:
    runs-on: ubuntu-latest
    steps:
      - name: Start Codespace
        run: |
          curl -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${{ secrets.GH_PAT }}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/user/codespaces/orange-enigma-jqj77jg6gj42prv4/start
```

## Troubleshooting

### Worker returns 401 Unauthorized
- Check `X-Webhook-Secret` header matches environment variable
- Verify webhook secret is correctly set in Cloudflare

### Worker returns 500 Error
- Check Cloudflare Worker logs for detailed error
- Verify GitHub token has `codespace` scope
- Confirm codespace name is correct

### Codespace doesn't start
- Check GitHub token hasn't expired
- Verify codespace exists and you have access
- Check GitHub API status: https://www.githubstatus.com/

### Messages delayed
- Cold starts: First webhook may take 1-2 seconds longer
- Codespace boot: Always takes ~30 seconds
- Consider pre-warming for critical hours

## Security Considerations

1. **Webhook Secret**: Prevents unauthorized codespace starts
2. **GitHub Token**: Stored as encrypted secret in Cloudflare
3. **Rate Limiting**: Cloudflare automatically handles DDoS
4. **Token Rotation**: Rotate GitHub PAT every 90 days

## Alternative Solutions

If Cloudflare Workers doesn't fit your needs:

1. **AWS Lambda + API Gateway** (similar approach, AWS free tier)
2. **Google Cloud Functions** (similar approach, GCP free tier)
3. **Railway.app** (simple deployment, free tier)
4. **Vercel Edge Functions** (similar to Cloudflare Workers)

All follow the same pattern: receive webhook → check status → start if needed.

## Next Steps

After setup, test thoroughly:
1. Stop your codespace manually
2. Send a test message via Telegram/WhatsApp
3. Verify codespace starts automatically
4. Check logs for any issues
5. Monitor for 24 hours to ensure stability

Need help with setup? Check logs and error messages for debugging.
