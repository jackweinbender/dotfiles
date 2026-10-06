---
name: query
description: Run a read-only inspection command (bq, kubectl logs/get/describe/top, gcloud logging read, gcloud dns/projects/asset lists and describes, gcloud certificate and cluster lists, aws route53/route53domains/route53resolver lists and gets, aws acm/iam certificate lists, aws sts get-caller-identity) through a validated passthrough wrapper. Use instead of calling bq/kubectl/gcloud directly when you want the command to run without a permission prompt — it only executes if the tool+subcommand matches an explicit read-only allowlist.
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

`gcloud logging read` returns newest-first, so `--limit` silently truncates to the tail of your window. For counts or time series pass `--order=asc` with a bounded `timestamp>=… AND timestamp<=…` filter, and prefer `--format='csv[no-heading](timestamp,jsonPayload.field)'` over `--format=json` when you only need a few fields.

Unmatched commands are rejected before anything runs:

```
$ query kubectl delete pod my-pod
query: kubectl delete pod my-pod — does not match an allowed read-only prefix (not_allowed)
```

## Allowed prefixes

- `bq query`, `bq show`, `bq ls`, `bq head`
- `kubectl logs`, `kubectl get`, `kubectl describe`, `kubectl top`
- `gcloud logging read`
- `gcloud auth list`, `gcloud config list`, `gcloud organizations list`, `gcloud projects list`, `gcloud projects describe`, `gcloud asset search-all-resources`
- `gcloud dns` `managed-zones list|describe`, `record-sets list|describe`, `policies list|describe`, `response-policies list|describe`, `response-policies rules list`
- `gcloud compute networks list`, `gcloud compute ssl-certificates list`, `gcloud compute target-https-proxies list`, `gcloud domains registrations list|describe`
- `gcloud certificate-manager certificates list`, `gcloud certificate-manager maps list`, `gcloud container clusters list`
- `aws sts get-caller-identity`, `aws configure list-profiles`, `aws organizations list-accounts`, `aws organizations describe-organization`
- `aws acm list-certificates`, `aws acm describe-certificate`, `aws iam list-server-certificates`
- `aws route53` `list-hosted-zones`, `list-hosted-zones-by-name`, `list-hosted-zones-by-vpc`, `get-hosted-zone`, `list-resource-record-sets`, `list-vpc-association-authorizations`, `get-dnssec`, `list-query-logging-configs`, `list-health-checks`, `get-health-check`, `list-traffic-policies`, `list-traffic-policy-instances`, `list-tags-for-resource`
- `aws route53domains list-domains`, `aws route53domains get-domain-detail` (the Route 53 Domains API answers only in `--region us-east-1`)
- `aws route53resolver` `list-resolver-endpoints`, `list-resolver-rules`, `list-resolver-rule-associations`, `list-resolver-query-log-configs`

For `aws`, put global flags such as `--profile` and `--region` *after* the subcommand (`query aws route53 list-hosted-zones --profile prod`); the prefix match reads the first tokens, so `query aws --profile prod route53 …` is rejected.

Run `query --help` (or `query` with no args) to see this list from the CLI itself.

## Adding a new prefix

Edit `ALLOWLIST` in `skills/bin/query` (Ruby, stdlib only, same convention as `memory`/`workspace`) and add the tool+subcommand pair, e.g. `%w[gcloud sql instances describe]`. Keep entries scoped to genuinely read-only subcommands — this list is the entire security boundary, since `query` execs whatever matches with no further inspection of flags or arguments.

Don't add compound/convenience workflows here — this wrapper is a primitive (validate, then exec one command). Multi-step read workflows belong in a `recipes/` script or in the calling agent's own orchestration.
