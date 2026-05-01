import supabase from './supabase.js';

export async function isSubscribed(deviceId) {
  if (!deviceId) return false;

  const { data: user } = await supabase
    .from('app_users')
    .select('id')
    .eq('device_id', deviceId)
    .maybeSingle();

  if (!user) return false;

  const { data: sub } = await supabase
    .from('subscriptions')
    .select('id')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();

  return !!sub;
}
