## Cloudflare Worker Setup Steps

### Step 1: Create Worker
1. On the page you're on, click **"Create Worker"** button
2. Worker name: `codespace-autostarter` (or any name you prefer)
3. Click **"Deploy"** button (ignore the default Hello World code)

### Step 2: Edit Code
1. After deployment, you'll see a success message
2. Click **"Edit Code"** button (top right)
3. Delete ALL existing code in the editor
4. Copy the code from: /workspaces/moltbot-deployment/webhook-autostarter/cloudflare-worker.js
5. Paste it into the Cloudflare editor
6. Click **"Save and Deploy"** button

### Step 3: Add Environment Variables
1. Click the **"<- Back"** arrow or go to your worker's main page
2. Click **"Settings"** tab
3. Scroll down to **"Variables and Secrets"** section
4. Click **"Add variable"** button

Add these 3 variables one by one:

**Variable 1:**
- Variable name: `GITHUB_TOKEN`
- Value: `your_github_pat_here`
- Type: **Encrypt** (check the box)
- Click **"Save"**

**Variable 2:**
- Variable name: `CODESPACE_NAME`
- Value: `orange-enigma-jqj77jg6gj42prv4`
- Type: Regular (no encryption needed)
- Click **"Save"**

**Variable 3:**
- Variable name: `WEBHOOK_SECRET`
- Value: `your_webhook_secret_here` (generate with: `openssl rand -hex 32`)
- Type: **Encrypt** (check the box)
- Click **"Save"**

### Step 4: Get Worker URL
After saving all variables:
1. Go back to worker overview
2. Your worker URL will be shown (format: `https://codespace-autostarter.YOUR_ACCOUNT.workers.dev`)
3. Copy this URL - you'll need it for testing

When done, paste your worker URL here and we'll test it!
