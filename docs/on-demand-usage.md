# Cost-Optimized On-Demand Codespace Usage

## Problem
Running moltbot 24/7 in GitHub Codespace costs approximately **$130/month** ($0.18/hour × 720 hours), which is too expensive for your usage patterns.

## Solution: On-Demand Sleep/Wake Strategy

### 1. Allow Auto-Stop (Remove Keepalive)

The hourly keepalive cron job prevents the desired auto-stop behavior. Remove it to allow the Codespace to auto-stop after inactivity:

```bash
# Remove the keepalive cron job
clawdbot cron rm keepalive

# Verify removal
clawdbot cron list
```

### 2. Set Optimal Idle Timeout

Configure your Codespace to auto-stop after a reasonable period of inactivity:

1. Go to https://github.com/settings/codespaces
2. Set "Default idle timeout" to **30 minutes** (recommended)
   - Balances responsiveness with cost savings
   - After 30 minutes of inactivity, it will auto-stop
3. Save the setting

**Note**: Maximum timeout is 240 minutes (4 hours). With webhook auto-start enabled, 30 minutes is optimal.

### 3. Wake Codespace On-Demand

#### Option A: Web UI (Easiest)
1. Visit https://github.com/codespaces
2. Find "orange-enigma-jqj77jg6gj42prv4"
3. Click the "Start" button
4. Wait ~30 seconds for boot
5. Access via browser or VS Code

#### Option B: GitHub CLI (Fastest)
```bash
# Start the codespace
gh codespace start -c orange-enigma-jqj77jg6gj42prv4

# Connect via SSH (optional)
gh codespace ssh -c orange-enigma-jqj77jg6gj42prv4

# Open in VS Code (optional)
gh codespace code -c orange-enigma-jqj77jg6gj42prv4
```

#### Option C: GitHub REST API (For Automation)
```bash
# Get GitHub token (create at https://github.com/settings/tokens)
# Needs "codespace" scope

# Start codespace via API
curl -L -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/codespaces/orange-enigma-jqj77jg6gj42prv4/start

# Check status
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/codespaces/orange-enigma-jqj77jg6gj42prv4
```

### 4. Manual Stop (When Done)

To immediately stop the Codespace when you're finished:

```bash
# Via GitHub CLI
gh codespace stop -c orange-enigma-jqj77jg6gj42prv4

# Via API
curl -L -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/codespaces/orange-enigma-jqj77jg6gj42prv4/stop
```

Or simply close VS Code/browser and wait for auto-stop.

## Cost Savings Breakdown

### Current Cost (24/7 with Keepalive)
- **$0.18/hour × 720 hours/month = $130.08/month**
- Plus storage: ~$0.07/GB × 15GB = ~$1.05/month
- **Total: ~$131/month**

### Optimized Cost (On-Demand)
Assuming 2-4 hours of actual usage per day:

| Usage Pattern | Hours/Month | Compute Cost | Storage Cost | Total Cost | **Savings** |
|---------------|-------------|--------------|--------------|------------|-------------|
| 2 hrs/day     | 60 hrs      | $10.80       | $1.05        | **$11.85** | **$119 (91%)** |
| 3 hrs/day     | 90 hrs      | $16.20       | $1.05        | **$17.25** | **$114 (87%)** |
| 4 hrs/day     | 120 hrs     | $21.60       | $1.05        | **$22.65** | **$108 (83%)** |
| 6 hrs/day     | 180 hrs     | $32.40       | $1.05        | **$33.45** | **$98 (74%)** |

**Note**: Storage cost ($1.05/month) is incurred even when stopped, but compute charges only apply while running.

### Free Tier
GitHub Free includes **120 hours/month free** for 2-core machines. If you use less than 4 hours/day, you stay within the free tier!

## Recommended Workflow

### Daily Usage Pattern
1. **Morning**: Start Codespace via `gh codespace start -c orange-enigma-jqj77jg6gj42prv4`
2. **Work**: Use moltbot for tasks (Telegram/WhatsApp chats, weather forecasts, etc.)
3. **Lunch/Break**: Let it auto-stop after 1-2 hours of inactivity
4. **Afternoon**: Restart if needed
5. **Evening**: Manually stop via `gh codespace stop` or let auto-stop handle it

### Important Notes
- **Data Persistence**: All your work (configs, env files, etc.) is saved automatically
- **Boot Time**: ~20-30 seconds from stopped to ready state
- **Gateway State**: You'll need to restart the gateway after each boot:
  ```bash
  cd /workspaces/moltbot-deployment
  nohup clawdbot gateway > gateway.log 2>&1 &
  ```

## Advanced: Auto-Start on Webhook

**✅ IMPLEMENTED** - See [webhook-autostarter/README.md](../webhook-autostarter/README.md) for complete setup instructions.

This feature automatically starts your Codespace when Telegram/WhatsApp messages arrive:
- Cloudflare Worker (free tier) receives webhooks
- Checks if Codespace is already running
- Starts Codespace only if stopped
- ~30 second boot time before message processing

Combined with 30-minute auto-stop, this provides optimal cost savings while maintaining near-instant availability.

## Monitoring Usage

Track your Codespace usage:
```bash
# Check current state
gh codespace list

# View recent activity
gh codespace logs -c orange-enigma-jqj77jg6gj42prv4
```

Or visit https://github.com/settings/billing to see monthly usage statistics.

## Weather Forecast Cron Job

The daily weather forecast cron job will **not run** when the Codespace is stopped. Options:

1. **Accept it**: Start Codespace in morning, get weather at 8 AM if running
2. **Remove it**: Delete weather cron since it's not essential
3. **Move to external scheduler**: Use GitHub Actions scheduled workflow to:
   - Start Codespace
   - Trigger weather forecast
   - Stop Codespace (optional)

## Summary

✅ **Remove keepalive cron**: Allow auto-stop after inactivity  
✅ **Set 60-120 min timeout**: Balance convenience and cost  
✅ **Start on-demand**: Use `gh codespace start` or web UI  
✅ **Manual stop when done**: `gh codespace stop` or let auto-stop handle it  
✅ **Expected savings**: 74-91% cost reduction ($98-119 saved per month)  

With this approach, you only pay for the compute time you actually use, while maintaining full functionality when needed.
