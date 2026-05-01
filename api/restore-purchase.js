import supabase from './_lib/supabase.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const deviceId = req.headers['x-device-id'] ?? req.body?.device_id;
  if (!deviceId) {
    return res.status(400).json({ error: 'device_id required' });
  }

  const { data: user } = await supabase
    .from('app_users')
    .select('id')
    .eq('device_id', deviceId)
    .maybeSingle();

  if (!user) {
    return res.status(200).json({ restored: false });
  }

  const { data: sub } = await supabase
    .from('subscriptions')
    .select('plan, expires_at')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .gt('expires_at', new Date().toISOString())
    .order('expires_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (!sub) {
    return res.status(200).json({ restored: false });
  }

  return res.status(200).json({
    restored:   true,
    plan:       sub.plan,
    expires_at: sub.expires_at,
  });
}
