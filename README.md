# trino-postgres-minio-federation

Small demo showing Trino querying two different data sources in a single SQL statement:
- **PostgreSQL** — structured user records (relational)
- **MinIO** — event log stored as Parquet files (S3-compatible object storage)
- **Hive Metastore** — keeps track of table schemas and file locations for the lake catalog

Everything runs locally via Docker Compose, no cloud setup needed.

## Stack

| Service | Image | Port |
|---|---|---|
| Trino | trinodb/trino:435 | 8080 |
| PostgreSQL | postgres:15-alpine | 5432 |
| MinIO | minio/minio:latest | 9000 / 9001 |
| Hive Metastore | apache/hive:3.1.3 | 9083 |

## Getting started

**1. Copy env file and start containers**
```bash
cp .env.example .env
docker compose up -d
```
Wait ~30 seconds for all health checks to pass.

**2. Create the lake table and insert sample data**
```bash
docker exec -i demo_trino trino < docs/create_lake_table.sql
```

**3. Run the federated queries**
```bash
docker exec -i demo_trino trino < docs/federated_query.sql
```
This joins `postgres.public.users` (PostgreSQL) with `lake.analytics.user_events` (MinIO Parquet) in one query.

**4. Or use the Trino CLI interactively**
```bash
docker exec -it demo_trino trino
```

## UIs

- Trino UI: http://localhost:8080
- MinIO console: http://localhost:9001 (user: `minioadmin`, pass: `minioadmin`)

## Project layout

```
docker-compose.yml
.env.example
init/postgres/01_app_tables.sql   # seeds postgres on first start
docs/create_lake_table.sql        # creates lake schema + table in trino
docs/federated_query.sql          # example queries joining both sources
trino/catalog/postgres.properties # trino → postgres connector
trino/catalog/lake.properties     # trino → minio via hive connector
trino/config/config.properties    # trino server settings
conf/hive/hive-site.xml           # hive metastore pointing at minio
```

## Notes

- Credentials are hardcoded for local dev only — don't use these in prod.
- `hive.s3.path-style-access=true` is required for MinIO; virtual-hosted style won't work.
- Derby is used as the Hive Metastore DB (embedded, auto-created on first run).
