// Usage:
//   node scripts/test-webhook.js                        (targets localhost:3000)
//   node scripts/test-webhook.js https://your.vercel.app (targets production)

import { createHash } from 'crypto';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// ─── Load .env ───────────────────────────────────────────────────────────────
try {
  const raw = readFileSync(resolve('.env'), 'utf8');
  for (const line of raw.split('\n')) {
    const eq = line.indexOf('=');
    if (eq > 0) {
      const key = line.slice(0, eq).trim();
      const val = line.slice(eq + 1).trim();
      if (key && !process.env[key]) process.env[key] = val;
    }
  }
} catch { /* no .env — rely on environment */ }

// ─── Config ──────────────────────────────────────────────────────────────────
const PRIVATE_KEY = process.env.LIQPAY_PRIVATE_KEY;
const PUBLIC_KEY  = process.env.LIQPAY_PUBLIC_KEY;
const BASE_URL    = process.argv[2] ?? 'http://localhost:3000';
const WEBHOOK_URL = `${BASE_URL}/api/webhook/liqpay`;
const TEST_USER   = '00000000-0000-4000-8000-000000000001';

if (!PRIVATE_KEY) {
  console.error('\n✗ LIQPAY_PRIVATE_KEY not set — add it to .env\n');
  process.exit(1);
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
function sign(data) {
  return createHash('sha1')
    .update(PRIVATE_KEY + data + PRIVATE_KEY)
    .digest('base64');
}

function buildPayload(params) {
  const data = Buffer.from(JSON.stringify(params)).toString('base64');
  return { data, signature: sign(data) };
}

async function post(label, body, expect) {
  let res, json;
  try {
    res  = await fetch(WEBHOOK_URL, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(body),
    });
    json = await res.json().catch(() => ({}));
  } catch (e) {
    console.log(`✗ ${label}`);
    console.log(`  → connection refused (is the server running at ${BASE_URL}?)\n`);
    return;
  }

  const pass = expect ? res.status === expect : true;
  console.log(`${pass ? '✓' : '✗'} ${label}`);
  console.log(`  → HTTP ${res.status}  ${JSON.stringify(json)}\n`);
}

// ─── Banner ──────────────────────────────────────────────────────────────────
console.log('\nLiqPay Webhook Test Runner');
console.log('══════════════════════════════════════════════════════');
console.log(`Sending to:  ${WEBHOOK_URL}`);
console.log(`Private key: ${PRIVATE_KEY.slice(0, 6)}${'*'.repeat(12)}`);
console.log('══════════════════════════════════════════════════════');
console.log('\nLiqPay sandbox server_url to configure:');
console.log(`  ${process.env.APP_URL ?? '<your Vercel URL>'}/api/webhook/liqpay`);
console.log('\n  Dashboard → My Business → Edit → "Server URL" field');
console.log('  (for local testing expose port 3000 with: npx ngrok http 3000)\n');
console.log('══════════════════════════════════════════════════════\n');

// ─── Test 1: Successful monthly payment ──────────────────────────────────────
const orderId = `${TEST_USER}_${Date.now()}`;

await post(
  'Successful monthly payment (99 UAH)  → expect 200, subscription activated',
  buildPayload({
    version:     3,
    public_key:  PUBLIC_KEY,
    action:      'pay',
    status:      'success',
    amount:      99,
    currency:    'UAH',
    description: 'Balabony Premium — 1 місяць',
    order_id:    orderId,
    payment_id:  100001,
  }),
  200,
);

// ─── Test 2: Idempotency — same order_id ─────────────────────────────────────
await post(
  'Duplicate order_id (idempotency)      → expect 200, DB write skipped',
  buildPayload({
    version:    3,
    public_key: PUBLIC_KEY,
    action:     'pay',
    status:     'success',
    amount:     99,
    currency:   'UAH',
    order_id:   orderId,    // same as test 1
    payment_id: 100001,
  }),
  200,
);

// ─── Test 3: Successful yearly payment ───────────────────────────────────────
await post(
  'Successful yearly payment (799 UAH)   → expect 200, 12-month subscription',
  buildPayload({
    version:     3,
    public_key:  PUBLIC_KEY,
    action:      'pay',
    status:      'success',
    amount:      799,
    currency:    'UAH',
    description: 'Balabony Premium — 1 рік',
    order_id:    `${TEST_USER}_${Date.now() + 1}`,
    payment_id:  100002,
  }),
  200,
);

// ─── Test 4: Failed payment ───────────────────────────────────────────────────
await post(
  'Failed payment                         → expect 200, no subscription',
  buildPayload({
    version:    3,
    public_key: PUBLIC_KEY,
    action:     'pay',
    status:     'failure',
    amount:     99,
    currency:   'UAH',
    order_id:   `${TEST_USER}_${Date.now() + 2}`,
    payment_id: 100003,
  }),
  200,
);

// ─── Test 5: Invalid signature ───────────────────────────────────────────────
await post(
  'Tampered signature                     → expect 400, rejected',
  {
    data:      Buffer.from(JSON.stringify({ status: 'success', amount: 99 })).toString('base64'),
    signature: 'dGhpc2lzZmFrZQ==',
  },
  400,
);

// ─── Test 6: Missing fields ───────────────────────────────────────────────────
await post(
  'Missing data/signature fields          → expect 400, rejected',
  { foo: 'bar' },
  400,
);
