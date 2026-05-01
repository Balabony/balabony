import { createHash } from 'crypto';
import supabase from '../_lib/supabase.js';

const PLAN_MONTHS = { monthly: 1, yearly: 12 };

function verifySignature(data, signature) {
  const expected = createHash('sha1')
    .update(process.env.LIQPAY_PRIVATE_KEY + data + process.env.LIQPAY_PRIVATE_KEY)
    .digest('base64');
  return expected === signature;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { data, signature } = req.body ?? {};
  if (!data || !signature || !verifySignature(data, signature)) {
    return res.status(400).json({ error: 'Invalid signature' });
  }

  let payload;
  try {
    payload = JSON.parse(Buffer.from(data, 'base64').toString('utf8'));
  } catch {
    return res.status(400).json({ error: 'Invalid data payload' });
  }

  // Acknowledge non-success statuses without processing
  if (!['success', 'subscribed'].includes(payload.status)) {
    return res.status(200).json({ received: true });
  }

  // Idempotency: skip already-processed order IDs
  const { data: existing } = await supabase
    .from('subscriptions')
    .select('id')
    .eq('liqpay_order_id', payload.order_id)
    .maybeSingle();

  if (existing) {
    return res.status(200).json({ received: true });
  }

  // order_id format: <userId>_<timestamp>
  const userId = payload.order_id?.split('_')[0];
  if (!userId) {
    return res.status(400).json({ error: 'Invalid order_id format' });
  }

  const plan = payload.amount <= 99 ? 'monthly' : 'yearly';
  const expiresAt = new Date();
  expiresAt.setMonth(expiresAt.getMonth() + PLAN_MONTHS[plan]);

  // Expire any existing active subscription for this user
  await supabase
    .from('subscriptions')
    .update({ status: 'expired' })
    .eq('user_id', userId)
    .eq('status', 'active');

  const { error } = await supabase
    .from('subscriptions')
    .insert({
      user_id:           userId,
      status:            'active',
      plan,
      started_at:        new Date().toISOString(),
      expires_at:        expiresAt.toISOString(),
      liqpay_order_id:   payload.order_id,
      liqpay_payment_id: String(payload.payment_id),
    });

  if (error) {
    return res.status(500).json({ error: 'Failed to activate subscription', detail: error.message });
  }

  return res.status(200).json({ received: true });
}
