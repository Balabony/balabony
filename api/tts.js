import { isSubscribed } from './_lib/checkSubscription.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  if (!await isSubscribed(req.headers['x-device-id'])) {
    return res.status(403).json({ error: 'Subscription required' });
  }

  try {
    const response = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${process.env.ELEVENLABS_VOICE_ID}`,
      {
        method: 'POST',
        headers: {
          'xi-api-key': process.env.ELEVENLABS_API_KEY,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: JSON.stringify(req.body),
      }
    );
    const arrayBuffer = await response.arrayBuffer();
    res.setHeader('Content-Type', 'audio/mpeg');
    return res.status(response.status).send(Buffer.from(arrayBuffer));
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
}
