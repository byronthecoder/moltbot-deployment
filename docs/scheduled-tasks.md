# Scheduled Tasks Configuration

**Date**: January 29, 2026

## Active Cron Jobs

### 1. Keepalive (Every Hour)
**Purpose**: Prevent Codespace auto-stop by generating terminal activity

**Command**:
```bash
clawdbot cron add --name "keepalive" \
  --description "Keep Codespace active" \
  --every "1h" \
  --system-event "keepalive" \
  --post-prefix "KeepAlive"
```

**Schedule**: Every 60 minutes  
**Status**: Enabled  
**Session**: main

---

### 2. Weather Forecast for Aix-en-Provence (Daily at 8 AM)
**Purpose**: Daily weather updates for Aix-en-Provence, France

**Command**:
```bash
clawdbot cron add --name "weather-aix" \
  --description "Daily weather forecast for Aix-en-Provence" \
  --cron "0 8 * * *" \
  --tz "Europe/Paris" \
  --session "isolated" \
  --message "What's the weather forecast for today in Aix-en-Provence, France? Provide a brief summary with temperature, conditions, and any weather alerts." \
  --deliver \
  --channel "last"
```

**Schedule**: 8:00 AM Paris time (Europe/Paris timezone)  
**Status**: Enabled  
**Session**: isolated  
**Delivery**: Last used channel

---

## Verify Status

```bash
# List all jobs
clawdbot cron list

# Check scheduler status
clawdbot cron status

# View run history
clawdbot cron runs
```
