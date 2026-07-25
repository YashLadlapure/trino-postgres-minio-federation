-- run inside trino CLI after containers are up
--   docker exec -it demo_trino trino
--   paste below, or:
--   docker exec -i demo_trino trino < docs/create_lake_table.sql

-- schema maps to s3a://warehouse/analytics/ in minio
CREATE SCHEMA IF NOT EXISTS lake.analytics
WITH (location = 's3a://warehouse/analytics/');

-- parquet table backed by minio; location must match schema prefix
CREATE TABLE IF NOT EXISTS lake.analytics.user_events (
    event_id        BIGINT,
    user_id         INTEGER,
    event_type      VARCHAR,
    page            VARCHAR,
    session_id      VARCHAR,
    duration_ms     INTEGER,
    event_timestamp TIMESTAMP
)
WITH (
    format   = 'PARQUET',
    location = 's3a://warehouse/analytics/user_events/'
);

-- user_id 1-10 match the seeded rows in postgres.public.users
INSERT INTO lake.analytics.user_events VALUES
    (1001, 1,  'page_view', '/home',         'sess-aaa-001', 4200,  TIMESTAMP '2024-09-01 08:05:00'),
    (1002, 1,  'purchase',  '/checkout',     'sess-aaa-001', 12000, TIMESTAMP '2024-09-01 08:18:00'),
    (1003, 2,  'page_view', '/pricing',      'sess-bbb-002', 6500,  TIMESTAMP '2024-09-01 09:10:00'),
    (1004, 3,  'page_view', '/dashboard',    'sess-ccc-003', 8100,  TIMESTAMP '2024-09-02 11:05:00'),
    (1005, 3,  'logout',    '/logout',       'sess-ccc-003', 300,   TIMESTAMP '2024-09-02 11:22:00'),
    (1006, 4,  'page_view', '/settings',     'sess-ddd-004', 3100,  TIMESTAMP '2024-09-03 14:15:00'),
    (1007, 5,  'page_view', '/home',         'sess-eee-005', 5200,  TIMESTAMP '2024-09-03 07:50:00'),
    (1008, 5,  'purchase',  '/checkout',     'sess-eee-005', 9800,  TIMESTAMP '2024-09-03 08:03:00'),
    (1009, 6,  'page_view', '/features',     'sess-fff-006', 7400,  TIMESTAMP '2024-09-04 16:30:00'),
    (1010, 7,  'page_view', '/home',         'sess-ggg-007', 2900,  TIMESTAMP '2024-09-05 10:00:00'),
    (1011, 8,  'page_view', '/docs',         'sess-hhh-008', 15000, TIMESTAMP '2024-09-05 13:05:00'),
    (1012, 8,  'logout',    '/logout',       'sess-hhh-008', 200,   TIMESTAMP '2024-09-05 13:28:00'),
    (1013, 9,  'page_view', '/pricing',      'sess-iii-009', 4800,  TIMESTAMP '2024-09-06 09:20:00'),
    (1014, 10, 'purchase',  '/checkout',     'sess-jjj-010', 11200, TIMESTAMP '2024-09-06 17:45:00'),
    (1015, 10, 'page_view', '/confirmation', 'sess-jjj-010', 3000,  TIMESTAMP '2024-09-06 18:00:00');

SELECT COUNT(*) AS total_events FROM lake.analytics.user_events;
