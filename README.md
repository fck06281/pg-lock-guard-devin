# pg-lock-guard-devin

Automated PostgreSQL zero-downtime migration guard designed for Devin Bots.

## How it works
1. Triggers on any PR touching `migrations/*.sql`.
2. Spins up a sandbox Postgres instance with simulated concurrent read/write traffic.
3. Enforces `lock_timeout = 200ms` and inspects `pg_locks` for `AccessExclusiveLock` blocking.
4. On failure, Devin Bot rewrites the unsafe DDL into a two-phase zero-downtime migration (`NOT VALID` + `VALIDATE CONSTRAINT` / `CONCURRENTLY`) and re-runs the check.
