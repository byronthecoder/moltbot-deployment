# Running the Auto-Start Test

## From Your Local Machine

### Prerequisites

```bash
# Install GitHub CLI
brew install gh  # macOS
# or
winget install GitHub.cli  # Windows

# Install jq for JSON parsing
brew install jq  # macOS
sudo apt install jq  # Linux
```

### Authenticate with GitHub

```bash
gh auth login
```

### Run the Test

```bash
# Download the test script
curl -O https://raw.githubusercontent.com/byronthecoder/moltbot-deployment/main/test-auto-start.sh
chmod +x test-auto-start.sh

# Run with webhook secret
export WEBHOOK_SECRET="your_webhook_secret_here"
./test-auto-start.sh
```

Or run directly without downloading:

```bash
export WEBHOOK_SECRET="your_webhook_secret_here"
bash <(curl -s https://raw.githubusercontent.com/byronthecoder/moltbot-deployment/main/test-auto-start.sh)
```

### What the Test Does

1. ✅ Checks current Codespace status
2. 🛑 Stops Codespace if running
3. 🚀 Triggers webhook to start Codespace
4. ⏳ Monitors startup progress (30-60 seconds)
5. 🔍 Verifies moltbot gateway auto-started
6. 📋 Displays summary

### Expected Output

```
===================================
🧪 Testing Auto-Start Workflow
===================================

📊 Step 1: Checking current Codespace status...
   Current state: Available

🛑 Step 2: Stopping Codespace...
   Waiting for shutdown (10 seconds)...
   New state: Shutdown

🚀 Step 3: Triggering webhook to start Codespace...
   Response: {"status":"started","message":"Codespace is starting up"}

✅ Webhook triggered Codespace start successfully!

⏳ Step 4: Monitoring Codespace startup...
   [1/12] State: Starting
   [2/12] State: Starting
   [3/12] State: Starting
   [4/12] State: Available

✅ Codespace is now AVAILABLE!

🔍 Step 5: Verifying moltbot gateway auto-started...
   ✅ Gateway is running!

===================================
📋 Test Summary
===================================
✅ Webhook: Working
✅ Auto-start: Working
✅ Gateway: Running

🎉 Auto-start flow test complete!
```

## Alternative: Manual Test Steps

If you prefer to test manually:

### 1. Stop Codespace

```bash
gh codespace stop -c orange-enigma-jqj77jg6gj42prv4
```

### 2. Trigger Webhook

```bash
curl -X POST "https://codespace-autostarter.byron-zheng-yuan.workers.dev/" \
  -H "X-Webhook-Secret: your_webhook_secret_here" \
  -d '{"test":"manual"}'
```

### 3. Check Status

```bash
gh codespace list
```

### 4. SSH In and Check Gateway

```bash
gh codespace ssh -c orange-enigma-jqj77jg6gj42prv4
ps aux | grep clawdbot
```

## Troubleshooting

### "gh: command not found"

Install GitHub CLI: https://cli.github.com/

### "jq: command not found"

Install jq: https://stedolan.github.io/jq/download/

### "authentication required"

Run: `gh auth login`

### Codespace won't stop

Wait 30 seconds and try again, or force stop from GitHub web UI

### Webhook returns error

Check logs: `cd webhook-autostarter && npx wrangler tail`

---

**Next:** After successful test, configure Telegram integration
