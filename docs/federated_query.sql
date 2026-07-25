-- joins postgres.public.users (JDBC) with lake.analytics.user_events (parquet/minio)
-- run after create_lake_table.sql:
--   docker exec -i demo_trino trino < docs/federated_query.sql

-- basic join across both sources
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

-- per-user event count and avg session time
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

-- only active users who made a purchase (shows filter pushdown)
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
