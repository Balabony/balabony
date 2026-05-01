import { createHash } from 'crypto';
import supabase from './_lib/supabase.js';

const PLANS = {
  monthly: { amount: 99,  description: 'Balabony Premium — 1 місяць' },
  yearly:  { amount: 799, description: 'Balabony Premium — 1 рік'    },
};

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { device_id, plan = 'monthly' } = req.body ?? {};
  if (!device_id || !PLANS[plan]) {
    return res.status(400).json({ error: 'device_id and valid plan required' });
  }

  const { data: user, error } = await supabase
    .from('users')
    .upsert({ device_id }, { onConflict: 'device_id' })
    .select('id')
    .single();

  if (error || !user) {
    return res.status(500).json({ error: 'Failed to resolve user' });
  }

  const orderId = `${user.id}_${Date.now()}`;
  const { amount, description } = PLANS[plan];

  const params = {
    version: 3,
    public_key:  process.env.LIQPAY_PUBLIC_KEY,
    action:      'pay',
    amount,
    currency:    'UAH',
    description,
    order_id:    orderId,
    result_url:  process.env.APP_URL,
    server_url:  `${process.env.APP_URL}/api/webhook/liqpay`,
  };

  const data = Buffer.from(JSON.stringify(params)).toString('base64');
  const signature = createHash('sha1')
    .update(process.env.LIQPAY_PRIVATE_KEY + data + process.env.LIQPAY_PRIVATE_KEY)
    .digest('base64');

  return res.status(200).json({ data, signature });
}
