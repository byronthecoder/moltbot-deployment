/**
 * Cloudflare Worker: Auto-start Codespace on Telegram/WhatsApp messages
 *
 * Setup:
 * 1. Create GitHub Personal Access Token at https://github.com/settings/tokens
 *    - Required scope: "codespace"
 * 2. Deploy this worker to Cloudflare Workers (free tier)
 * 3. Set environment variables in Cloudflare dashboard:
 *    - GITHUB_TOKEN: Your GitHub PAT
 *    - CODESPACE_NAME: orange-enigma-jqj77jg6gj42prv4
 *    - WEBHOOK_SECRET: Random secret for validating webhook requests
 * 4. Configure Telegram/WhatsApp webhooks to point to this worker URL
 */

export default {
  async fetch(request, env, ctx) {
    return handleRequest(request, env);
  },
};

async function handleRequest(request, env) {
  // Only accept POST requests
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    // Parse incoming webhook
    const body = await request.json();

    // Validate webhook (optional but recommended)
    const secret = request.headers.get("X-Webhook-Secret");
    if (secret !== env.WEBHOOK_SECRET) {
      console.log("Invalid webhook secret");
      return new Response("Unauthorized", { status: 401 });
    }

    console.log("Webhook received:", JSON.stringify(body));

    // Check if codespace is running
    const status = await getCodespaceStatus(env);

    if (status === "Available") {
      console.log("Codespace already running");
      return new Response(
        JSON.stringify({
          status: "running",
          message: "Codespace already available",
        }),
        {
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Start the codespace
    console.log("Starting codespace...");

    // Send Telegram notification
    await sendTelegramNotification(
      env,
      "🚀 Starting your Codespace... This will take ~30-45 seconds.",
    );

    const startResult = await startCodespace(env);

    return new Response(
      JSON.stringify({
        status: "started",
        message: "Codespace is starting up",
        data: startResult,
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({
        status: "error",
        message: error.message,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
}

async function getCodespaceStatus(env) {
  const response = await fetch(
    `https://api.github.com/user/codespaces/${env.CODESPACE_NAME}`,
    {
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "Cloudflare-Worker-Codespace-Autostarter",
      },
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`GitHub API error: ${response.status} - ${errorBody}`);
  }

  const data = await response.json();
  return data.state; // Returns: "Available", "Shutdown", "Starting", etc.
}

async function startCodespace(env) {
  const response = await fetch(
    `https://api.github.com/user/codespaces/${env.CODESPACE_NAME}/start`,
    {
      method: "POST",
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "Cloudflare-Worker-Codespace-Autostarter",
      },
    },
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to start codespace: ${error}`);
  }

  return await response.json();
}

async function sendTelegramNotification(env, message) {
  const botToken = env.TELEGRAM_BOT_TOKEN;
  const chatId = env.TELEGRAM_CHAT_ID;
  
  if (!botToken || !chatId) {
    console.log('Telegram credentials not configured, skipping notification');
    return;
  }
  
  try {
    await fetch(`https://api.telegram.org/bot${botToken}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: message
      })
    });
  } catch (error) {
    console.error('Failed to send Telegram notification:', error);
  }
}
