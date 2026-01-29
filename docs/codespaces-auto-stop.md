# GitHub Codespaces Auto-Stop Report

**Date**: January 29, 2026

## Key Findings

### Timeout Limits
- **Default**: 30 minutes of inactivity
- **Maximum**: 240 minutes (4 hours)
- **Hard limit**: Cannot exceed 4 hours regardless of settings

### What Prevents Auto-Stop
✅ Terminal output/input activity  
✅ User interaction (typing, mouse)  
❌ Background processes without terminal output

### Cost for 24/7 Operation (2-core)
- **Hourly**: $0.18
- **Daily**: $4.32
- **Monthly**: ~$130
- **Free tier**: 120 hours/month (GitHub Free), 180 hours/month (GitHub Pro)

### Solution Implemented
**Hourly keepalive cron job** that generates terminal activity every 60 minutes, resetting the idle timeout counter indefinitely.

## References
- [Setting timeout period](https://docs.github.com/en/codespaces/setting-your-user-preferences/setting-your-timeout-period-for-github-codespaces)
- [Codespaces billing](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-codespaces/about-billing-for-github-codespaces)
