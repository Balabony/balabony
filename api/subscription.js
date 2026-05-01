import supabase from './_lib/supabase.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const deviceId = req.headers['x-device-id'];
  if (!deviceId) {
    return res.status(200).json({ active: false });
  }

  const { data: user } = await supabase
    .from('app_users')
    .select('id')
    .eq('device_id', deviceId)
    .maybeSingle();

  if (!user) {
    return res.status(200).json({ active: false });
  }

  const { data: sub } = await supabase
    .from('subscriptions')
    .select('plan, expires_at')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();

  return res.status(200).json({
    active: !!sub,
    plan: sub?.plan ?? null,
    expires_at: sub?.expires_at ?? null,
  });
}
