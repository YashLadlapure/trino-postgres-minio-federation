-- runs on first postgres start via /docker-entrypoint-initdb.d/
-- trino reads this as postgres.public.users

\connect appdb;

CREATE TABLE IF NOT EXISTS public.users (
    user_id     SERIAL          PRIMARY KEY,
    username    VARCHAR(50)     NOT NULL UNIQUE,
    email       VARCHAR(255)    NOT NULL UNIQUE,
    full_name   VARCHAR(100)    NOT NULL,
    country     VARCHAR(50)     NOT NULL DEFAULT 'Unknown',
    plan        VARCHAR(20)     NOT NULL DEFAULT 'free'
                                CHECK (plan IN ('free', 'pro', 'enterprise')),
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE  public.users IS 'Registered application users';
COMMENT ON COLUMN public.users.plan IS 'Subscription tier: free | pro | enterprise';

INSERT INTO public.users (username, email, full_name, country, plan, created_at) VALUES
    ('alice_w',  'alice@example.com',  'Alice Walker',     'US', 'pro',        '2024-01-15 08:00:00+00'),
    ('bob_s',    'bob@example.com',    'Bob Singh',        'IN', 'free',       '2024-02-10 09:30:00+00'),
    ('carol_m',  'carol@example.com',  'Carol Martinez',   'MX', 'enterprise', '2024-03-01 11:00:00+00'),
    ('dave_k',   'dave@example.com',   'Dave Kim',         'KR', 'pro',        '2024-03-22 14:00:00+00'),
    ('eve_l',    'eve@example.com',    'Eve Liu',          'CN', 'free',       '2024-04-05 07:45:00+00'),
    ('frank_t',  'frank@example.com',  'Frank Taylor',     'GB', 'enterprise', '2024-04-18 16:20:00+00'),
    ('grace_o',  'grace@example.com',  'Grace Osei',       'GH', 'free',       '2024-05-02 10:10:00+00'),
    ('harry_v',  'harry@example.com',  'Harry Visser',     'NL', 'pro',        '2024-06-11 13:00:00+00'),
    ('irene_p',  'irene@example.com',  'Irene Papadaki',   'GR', 'free',       '2024-07-19 09:00:00+00'),
    ('james_r',  'james@example.com',  'James Rodrigues',  'BR', 'enterprise', '2024-08-03 17:30:00+00')
ON CONFLICT DO NOTHING;

SELECT COUNT(*) AS seeded_users FROM public.users;
