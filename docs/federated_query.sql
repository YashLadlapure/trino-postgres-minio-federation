-- =============================================================================
-- Federated Query: Trino joining PostgreSQL + MinIO in one SQL statement
--
-- postgres.public.users        → read from PostgreSQL via JDBC
-- lake.analytics.user_events   → read from MinIO Parquet files via Hive connector
--
-- Prerequisites:
--   1. All containers running:  docker compose up -d
--   2. Lake table created:      run docs/create_lake_table.sql
--
-- Run:
--   docker exec -i demo_trino trino < docs/federated_query.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Query 1: Basic federated join
-- ---------------------------------------------------------------------------
SELECT
    u.user_id,
    u.username,
    u.full_name,
    u.country,
    u.plan,
    e.event_type,
    e.page,
    e.duration_ms,
    e.event_timestamp
FROM
    postgres.public.users           AS u
    JOIN lake.analytics.user_events AS e ON u.user_id = e.user_id
ORDER BY
    e.event_timestamp;

-- ---------------------------------------------------------------------------
-- Query 2: Aggregated — events + avg session time per user and plan
-- ---------------------------------------------------------------------------
SELECT
    u.username,
    u.full_name,
    u.country,
    u.plan,
    COUNT(e.event_id)                             AS total_events,
    ROUND(AVG(e.duration_ms) / 1000.0, 2)         AS avg_duration_sec,
    COUNT(CASE WHEN e.event_type = 'purchase' THEN 1 END) AS purchase_count
FROM
    postgres.public.users           AS u
    LEFT JOIN lake.analytics.user_events AS e ON u.user_id = e.user_id
GROUP BY
    u.user_id, u.username, u.full_name, u.country, u.plan
ORDER BY
    total_events DESC;

-- ---------------------------------------------------------------------------
-- Query 3: Active users with purchase events only (filter pushdown demo)
-- ---------------------------------------------------------------------------
SELECT
    u.username,
    u.plan,
    e.event_timestamp,
    e.page
FROM
    postgres.public.users           AS u
    JOIN lake.analytics.user_events AS e ON u.user_id = e.user_id
WHERE
    e.event_type = 'purchase'
    AND u.is_active = TRUE
ORDER BY
    e.event_timestamp;
