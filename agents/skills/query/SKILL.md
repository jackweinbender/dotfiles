---
name: query
description: Run a read-only inspection command (bq, kubectl logs/get/describe/top, gcloud logging read) through a validated passthrough wrapper. Use instead of calling bq/kubectl/gcloud directly when you want the command to run without a permission prompt — it only executes if the tool+subcommand matches an explicit read-only allowlist.
---

# query

`query` is a thin, validated passthrough for the read-only inspection commands you run most often — BigQuery lookups, pod logs, resource dumps. It exists so those commands can be allowlisted once (`Bash(query:*)`) instead of needing broad `Bash(bq:*)` / `Bash(kubectl:*)` grants that would also cover mutating subcommands.

## Usage

```bash
query <tool> <subcommand> [args...]
```

Everything after `query` is passed through **verbatim** to the real binary via `exec` — no shell involved, so there's no `;`/`|`/`&&`/backtick injection surface. `query` never interprets your arguments; it only checks that the first one or two tokens match an allowed prefix.

```bash
query bq query --use_legacy_sql=false 'SELECT COUNT(*) FROM `proj.dataset.table`'
query kubectl logs my-pod-abc123 -n prod --since=1h
query kubectl get pods -n prod -l app=my-service
query gcloud logging read 'resource.type="k8s_container"' --limit=50
```

Unmatched commands are rejected before anything runs:

```
$ query kubectl delete pod my-pod
query: kubectl delete pod my-pod — does not match an allowed read-only prefix (not_allowed)
```

## Allowed prefixes

- `bq query`, `bq show`, `bq ls`, `bq head`
- `kubectl logs`, `kubectl get`, `kubectl describe`, `kubectl top`
- `gcloud logging read`

Run `query --help` (or `query` with no args) to see this list from the CLI itself.

## Adding a new prefix

Edit `ALLOWLIST` in `skills/bin/query` (Ruby, stdlib only, same convention as `memory`/`workspace`) and add the tool+subcommand pair, e.g. `%w[gcloud sql instances describe]`. Keep entries scoped to genuinely read-only subcommands — this list is the entire security boundary, since `query` execs whatever matches with no further inspection of flags or arguments.

Don't add compound/convenience workflows here — this wrapper is a primitive (validate, then exec one command). Multi-step read workflows belong in a `recipes/` script or in the calling agent's own orchestration.
