---
name: docker-compose-restart-doesnt-reload-env-file
description: "docker compose restart is a stop+start of the existing container — it does NOT re-read env_file. Updating an env file then docker compose restart looks successful (Container Restarted, Up X seconds, service still healthy) but the new env vars never reach the process. Only docker compose up -d recreates the container with the new env. Verify via docker exec <container> env, not by whether the restart succeeded."
metadata:
  type: feedback
---

GOV-10 LORNA token rotation work (2026-05-15): added `FINANCIALS_API_TOKEN` to `/opt/lorna-financials/.env` to turn on Lorna's app-layer auth, then ran `docker compose restart` on the lorna-financials stack. The container restarted cleanly (`Container lorna-financials-financials-1 Started`, `Up 4 seconds`), Lorna stayed reachable, casey-junior calls kept returning 200 OK — but the auth tests failed in a way that revealed the bug: `curl http://192.168.0.98:8901/api/financials/deals` returned 200 OK even with NO Authorization header. It should have returned 401 (verify_token in Lorna's auth.py raises HTTPException(401) when API_TOKEN is set and the header doesn't match). Confirmed via `docker exec lorna-financials-financials-1 env | grep FINANCIALS_API_TOKEN` — the var was NOT in the container's env despite being in `/opt/lorna-financials/.env`. Followed up with `docker compose up -d` which recreated the container; immediately the auth tests started returning 401 for missing/wrong tokens and 200 for the right one. Total wasted-loop cost: one extra round-trip + nearly missing that auth wasn't actually on.

**Why:** `docker compose restart` is equivalent to `docker stop && docker start` of an existing container — it reuses the same container instance with its original env (captured at create time). `docker compose up -d` checks the compose config + env files against the current container; if anything changed, it recreates the container with the new config, which is when env_file changes get picked up. The trap is that `restart` LOOKS like the right operation ("I changed config, restart to pick it up") and the indirect signals all look successful — but the underlying env never actually moved.

Same family as [[cascade-rc-rename-consumer-runtime-gap]] (source landed, consumer runtime didn't pick it up — a `pip install -e .` would have caught the bridge break before deploy, just as `docker compose up -d` would have caught this env-file change). Same family as [[fix-without-action-surface-reconciliation]] (the surface that confirms the fix landed — in this case `docker exec ... env` — has to be checked, not just whether the restart looked clean). Same family as [[canonical-source-per-fact]] (the canonical source for "what env does this container have" is `docker exec ... env`, NOT the env_file on the host; those can diverge silently after a `restart`).

**How to apply:**

- **After modifying any `env_file` referenced in a `docker-compose.yml`: ALWAYS `docker compose up -d`, never `docker compose restart`.** The recreate is what picks up the env change.
- **When verifying that an env-file change took effect, check the container's runtime env (`docker exec <container> env | grep <var>`)**, not the host's env_file content. The two can diverge silently after a `restart`.
- The same gotcha applies to docker-compose.yml `environment:` blocks — but those changes ARE caught by `docker compose up -d` because compose detects config drift. The trap is specifically `env_file` changes, which compose treats as opaque external state.
- For plain `docker run` containers (no compose), the equivalent is: env changes require `docker rm && docker run` with the new env, not just `docker restart`.
- For systemd-managed services using `EnvironmentFile=`, the equivalent operation IS `systemctl restart` — systemd re-reads EnvironmentFile on each start. (This is one of systemd's quiet advantages over `docker compose restart`.)

Related: [[cascade-rc-rename-consumer-runtime-gap]], [[fix-without-action-surface-reconciliation]], [[canonical-source-per-fact]].
