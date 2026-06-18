# gh queries for address-comments

The data layer is `gh`. Review threads and their resolution state are **GraphQL
only** (the REST `/pulls/{n}/comments` endpoint can't tell you `isResolved` or
give you a thread id to resolve). Issue-level comments are REST. Everything below
emits JSON to stdout — pipe through `jq`.

Preflight once: `gh auth status` must succeed and the repo must have a GitHub
remote. Set the vars used throughout:

```bash
# Current branch's PR (run from the worktree), or pass a number explicitly.
read OWNER REPO PR HEAD BASE < <(gh pr view --json number,headRefName,baseRefName,headRepositoryOwner,headRepository \
  --jq '[.headRepositoryOwner.login, .headRepository.name, (.number|tostring), .headRefName, .baseRefName] | @tsv')
```

## Fetch unresolved review threads (GraphQL)

Inline review comments, grouped into threads, with the one field that matters —
`isResolved` — and the `id` needed to reply/resolve. Paginate on
`reviewThreads`.

```bash
gh api graphql -f owner="$OWNER" -f repo="$REPO" -F pr="$PR" -f query='
query($owner:String!, $repo:String!, $pr:Int!, $cursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first:100, after:$cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first:50) {
            nodes {
              author { login __typename }
              body
              url
              createdAt
              diffHunk
            }
          }
        }
      }
    }
  }
}' --paginate --jq '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | { id, path, line, isOutdated,
      author: .comments.nodes[0].author.login,
      authorType: .comments.nodes[0].author.__typename,
      body: .comments.nodes[0].body,
      url: .comments.nodes[0].url }'
```

`--paginate` follows `pageInfo` automatically when the query exposes it as shown.
Each emitted object is one **unresolved thread**: `id` is what you reply to and
resolve; `author`/`authorType` drive bot-vs-human routing (see below).

## Fetch issue-level comments and review summaries (REST)

Some bots (bugbot, coderabbit) post a **summary** as an issue comment or a review
body rather than inline threads. These have no thread and can't be "resolved" —
you respond by posting a new comment if warranted, else just account for them.

```bash
# Issue-level comments (the PR's conversation tab):
gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate \
  --jq '.[] | { id, author: .user.login, authorType: .user.type, body, url: .html_url }'

# Top-level review summaries (CHANGES_REQUESTED / COMMENTED bodies):
gh api "repos/$OWNER/$REPO/pulls/$PR/reviews" --paginate \
  --jq '.[] | select(.body != "") | { id, author: .user.login, state, body, url: .html_url }'
```

## Bot vs human

A comment is from a **bot** when `authorType == "Bot"` (GraphQL `__typename`) /
REST `user.type == "Bot"`, **or** the login matches a known reviewer bot:

```
cursor, bugbot, cursor[bot], coderabbitai, coderabbitai[bot],
copilot-pull-request-reviewer, github-actions[bot], sonarcloud[bot], codecov[bot]
```

Treat anything matching as a bot finding (→ adversarial verification). Everything
else is a human (→ authoritative intent). When unsure, treat as human — the cost
of over-verifying a human is low; the cost of auto-dismissing one is high.

## Reply to a review thread (GraphQL mutation)

```bash
gh api graphql -f threadId="$THREAD_ID" -f body="$BODY" -f query='
mutation($threadId:ID!, $body:String!) {
  addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) {
    comment { id url }
  }
}'
```

## Resolve a review thread (GraphQL mutation)

```bash
gh api graphql -f threadId="$THREAD_ID" -f query='
mutation($threadId:ID!) {
  resolveReviewThread(input:{threadId:$threadId}) { thread { id isResolved } }
}'
```

Reply **before** resolving, so the rationale (especially for a dismissal) is
attached to the thread that's about to collapse. To reply to an issue-level
comment instead (no thread), post a normal issue comment:

```bash
gh api "repos/$OWNER/$REPO/issues/$PR/comments" -f body="$BODY"
```

## Notes

- `-f` passes string variables, `-F` passes typed ones (the `Int!` PR number).
  Bodies with newlines/quotes are safe via `-f body="$BODY"` (no shell-escaping
  of the GraphQL string itself).
- Resolving requires write access and that the thread isn't already resolved
  (the fetch already filtered to `isResolved == false`, so re-runs are safe —
  the work queue shrinks as threads resolve).
- `isOutdated == true` means the line the comment was on has since changed. Worth
  surfacing in triage: an outdated bot nit is often already moot.
