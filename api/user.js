import supabase from './_lib/supabase.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { device_id } = req.body ?? {};
  if (!device_id || typeof device_id !== 'string' || device_id.length > 64) {
    return res.status(400).json({ error: 'Invalid device_id' });
  }

  const { data, error } = await supabase
    .from('app_users')
    .upsert({ device_id }, { onConflict: 'device_id' })
    .select('id')
    .single();

  if (error) {
    return res.status(500).json({ error: 'Failed to register user' });
  }

  return res.status(200).json({ user_id: data.id });
}
