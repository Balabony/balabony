# Balabony

AI voice companion for Ukrainian seniors. Flutter web app with Node.js serverless backend on Vercel.

**Live:** [app.balabony.com](https://app.balabony.com)

## Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (web-only) |
| State | Riverpod |
| Backend | Vercel serverless functions (`api/`) |
| Database | Supabase (PostgreSQL) |
| Payments | LiqPay (hosted checkout + webhook) |
| Voice | ElevenLabs TTS |
| AI | OpenAI GPT-4o-mini |

## Architecture

```
lib/
  main.dart                  # Routes, app entry
  screens/                   # balabony_screen, stories_screen
  widgets/                   # paywall_dialog
  services/                  # subscription_service, stories_service, device_id
                             # elevenlabs_service, gpt_service, whisper_service
  providers/                 # subscription_provider (Riverpod)
  games/                     # Mini-games hub
  models/ data/              # Story model + static metadata

api/
  chat.js                    # POST → OpenAI proxy (subscription-gated)
  tts.js                     # POST → ElevenLabs proxy (subscription-gated)
  user.js                    # POST → upsert device in Supabase
  subscribe.js               # POST → create LiqPay payment (data + signature)
  restore-purchase.js        # POST → check existing active subscription
  get-story.js               # GET  → story text (premium stories gated)
  subscription/check.js      # POST → { is_premium, expires_at }
  subscription.js            # GET  → { active, plan, expires_at }
  webhook/liqpay.js          # POST → LiqPay payment webhook (SHA1 verified)
  _lib/
    supabase.js              # Supabase client (service-role, no session)
    checkSubscription.js     # isSubscribed(deviceId) helper

supabase/migrations/
  001_create_tables.sql      # app_users + app_subscriptions tables

scripts/
  pre-commit                 # Secret-scanning git hook
  install-hooks.sh           # Install hooks after clone
  test-webhook.js            # LiqPay webhook test runner
```

## Local Development

Flutter web targets the Vercel API — no local server needed.

```bash
# Install Flutter dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Build for web (output → build/web/)
flutter build web
```

Vercel deploys automatically on push to `main` using `build/web/` as the output directory (`vercel.json`).

## Vercel Serverless Functions

Node.js ES modules (`"type": "module"` in `package.json`):

```bash
npm install
```

### Test the LiqPay webhook

```bash
cp .env.example .env   # fill in your keys

node scripts/test-webhook.js https://app.balabony.com   # production
node scripts/test-webhook.js http://localhost:3000       # local (needs ngrok)
```

## Database Setup

Run once in **Supabase → SQL Editor**:

```sql
-- paste supabase/migrations/001_create_tables.sql
NOTIFY pgrst, 'reload schema';
```

This creates `app_users` and `app_subscriptions` tables with RLS (service-role only).

## Environment Variables

Set in **Vercel → Project → Settings → Environment Variables**. Copy `.env.example` to `.env` for local webhook testing only.

| Variable | Description |
|---|---|
| `OPENAI_API_KEY` | OpenAI API key — used by `/api/chat` |
| `ELEVENLABS_API_KEY` | ElevenLabs API key — used by `/api/tts` |
| `ELEVENLABS_VOICE_ID` | ElevenLabs voice ID |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Supabase service-role key (`sb_secret_...`) |
| `LIQPAY_PUBLIC_KEY` | LiqPay public key |
| `LIQPAY_PRIVATE_KEY` | LiqPay private key — server-side only |
| `APP_URL` | App URL, e.g. `https://app.balabony.com` |

> **Both LiqPay keys must belong to the same account** — a mismatch causes `invalid_signature`.

## Subscription Flow

1. App launch → `DeviceId.get()` returns a persistent UUID (SharedPreferences)
2. `/api/user` registers the device in `app_users`
3. Premium action → `isPremium()` hits `/api/subscription/check`
4. Not subscribed → `PaywallDialog` with monthly **99 ₴** / yearly **799 ₴**
5. Subscribe → `/api/subscribe` returns LiqPay `data`+`signature` → user pays
6. LiqPay POSTs to `/api/webhook/liqpay` → subscription written to `app_subscriptions`
7. "Restore purchase" → `/api/restore-purchase` re-checks active subscription

## Git Hooks

Blocks commits containing API keys or secrets:

```bash
bash scripts/install-hooks.sh
```

Emergency bypass: `SKIP_SECRET_CHECK=1 git commit`
