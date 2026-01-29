# Quick Reference Card

## 🔑 Secrets (in .env file - gitignored)
```bash
# View secrets
cat /workspaces/moltbot-deployment/webhook-autostarter/.env
```

## 🌐 Webhook URL
```
https://codespace-autostarter.byron-zheng-yuan.workers.dev/
```

## 🧪 Test Commands

### Test webhook (while Codespace running)
```bash
curl -X POST "https://codespace-autostarter.byron-zheng-yuan.workers.dev/" \
  -H "X-Webhook-Secret: $(grep WEBHOOK_SECRET /workspaces/moltbot-deployment/webhook-autostarter/.env | cut -d= -f2)" \
  -d '{"test": true}'
```

### Test auto-start (stop Codespace first)
```bash
# In another terminal/machine:
gh codespace stop -c orange-enigma-jqj77jg6gj42prv4

# Then trigger webhook and watch it start
```

### View webhook logs
```bash
cd /workspaces/moltbot-deployment/webhook-autostarter
npx wrangler tail --format pretty
```

### Check gateway status
```bash
ps aux | grep clawdbot
```

### View gateway logs
```bash
tail -f ~/gateway.log
```

### List cron jobs
```bash
clawdbot cron list
```

## 🚀 Deployment Commands

### Deploy webhook worker
```bash
cd /workspaces/moltbot-deployment/webhook-autostarter
npx wrangler deploy
```

### Update secrets
```bash
cd /workspaces/moltbot-deployment/webhook-autostarter
source .env
echo "$GITHUB_TOKEN" | npx wrangler secret put GITHUB_TOKEN
echo "$WEBHOOK_SECRET" | npx wrangler secret put WEBHOOK_SECRET
```

### Restart gateway manually
```bash
pkill -f "clawdbot gateway"
nohup clawdbot gateway > ~/gateway.log 2>&1 &
```

## 📋 Configuration Files

| File | Purpose |
|------|---------|
| `.env` | Secrets (gitignored) |
| `.env.example` | Template without secrets |
| `startup.sh` | Auto-start gateway on boot |
| `cloudflare-worker.js` | Webhook handler code |
| `wrangler.toml` | Cloudflare config |
| `.bashrc` | Calls startup.sh on connect |

## ⚙️ GitHub Settings

**Codespace Timeout:** https://github.com/settings/codespaces
- Set to: **30 minutes**

## 💰 Cost Tracking

Check actual usage:
```bash
# Hours this month (approximate)
echo "Hours active: $(gh codespace list --json name,state,createdAt | jq '.[0]')"
```

View billing: https://github.com/settings/billing

## 📚 Documentation

- [Implementation Complete](/workspaces/moltbot-deployment/docs/implementation-complete.md)
- [Telegram Integration](/workspaces/moltbot-deployment/docs/telegram-integration.md)
- [On-Demand Usage](/workspaces/moltbot-deployment/docs/on-demand-usage.md)
- [Deployment Success](/workspaces/moltbot-deployment/webhook-autostarter/DEPLOYMENT-SUCCESS.md)

## 🆘 Troubleshooting

### Webhook returns 403
Check User-Agent header is present in worker code

### Gateway not starting
```bash
/workspaces/moltbot-deployment/startup.sh
```

### Secrets not working
```bash
cd /workspaces/moltbot-deployment/webhook-autostarter
npx wrangler secret list
```

## ✅ Current Status

- [x] Webhook deployed and working
- [x] Secrets secured in .env (gitignored)
- [x] Auto-start script configured
- [x] Keepalive cron removed
- [x] **Auto-start flow tested and verified** ✅
- [x] **Gateway auto-start confirmed** ✅
- [ ] Codespace timeout set to 30 min
- [ ] Telegram integration configured
- [ ] Production monitoring active

---
Last updated: January 29, 2026
