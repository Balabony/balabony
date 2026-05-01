import supabase from '../_lib/supabase.js';

export default async function handler(req, res) {
  if (req.method !== 'GET' && req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const deviceId = req.headers['x-device-id'] ?? req.body?.device_id;
  if (!deviceId) {
    return res.status(400).json({ error: 'device_id required' });
  }

  const { data: user } = await supabase
    .from('users')
    .select('id')
    .eq('device_id', deviceId)
    .maybeSingle();

  if (!user) {
    return res.status(200).json({ is_premium: false, expires_at: null });
  }

  const { data: sub } = await supabase
    .from('app_subscriptions')
    .select('expires_at')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();

  return res.status(200).json({
    is_premium: !!sub,
    expires_at: sub?.expires_at ?? null,
  });
}
