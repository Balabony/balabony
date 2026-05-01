-- Run this in the Supabase SQL editor (Dashboard → SQL Editor → New query)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS app_users (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id  TEXT        UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS app_subscriptions (
  id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID        NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  status             TEXT        NOT NULL DEFAULT 'inactive'
                                 CHECK (status IN ('active', 'inactive', 'expired', 'cancelled')),
  plan               TEXT        NOT NULL DEFAULT 'monthly'
                                 CHECK (plan IN ('monthly', 'yearly')),
  started_at         TIMESTAMPTZ,
  expires_at         TIMESTAMPTZ,
  liqpay_order_id    TEXT        UNIQUE,
  liqpay_payment_id  TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_subscriptions_user_id     ON app_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_app_subscriptions_user_status ON app_subscriptions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_app_users_device_id           ON app_users(device_id);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER app_subscriptions_updated_at
  BEFORE UPDATE ON app_subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- All access is via service-role key from serverless functions only
ALTER TABLE app_users         ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_role_only" ON app_users
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "service_role_only" ON app_subscriptions
  FOR ALL USING (auth.role() = 'service_role');

NOTIFY pgrst, 'reload schema';
