#!/usr/bin/env zsh
# agents — set up the ~/Code orchestration config from this dotfiles topic.
#
#   templates/root/  → COMPILED (copied) into ~/Code: AGENTS.md, CLAUDE.md,
#                      .claude/settings.json, workspaces/ conventions. Build artifacts —
#                      edit templates/root/ and re-run; don't hand-edit the ~/Code copies.
#   skills/<name>/   → SYMLINKED live into ~/Code/.claude/skills/<name>/. Edit a SKILL.md
#                      and it's live immediately (still git-tracked here = change-controlled).
#                      skills/bin is on PATH (via zsh/lib/path.zsh), not linked here.
#   overlays         → any ~/.dotfiles-*/agents/skills/ (e.g. a private
#                      ~/.dotfiles-<name> repo) is linked the same way, after this topic's skills. A name
#                      already taken is skipped with a warning. Their bin/ is on PATH too.
#
#   memory topics    → configures the .gitattributes filter that keeps the memory skill's
#                      synced topic list out of git, then syncs it.
#
# Idempotent. NOT touched: ~/Code/memory, ~/Code/github.com, live ~/Code/workspaces/*.
# The workspace template (templates/workspace) is read straight from source by `workspace create`.
#
# Run on a fresh machine via osx/bootstrap.zsh, or by hand:
#   zsh ~/.dotfiles/agents/bootstrap.zsh

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
_ROOT="$DOTFILES/agents/templates/root"
_SKILLS="$DOTFILES/agents/skills"
_CODE="$HOME/Code"

if [[ -f "$DOTFILES/zsh/lib/helpers.zsh" ]]; then
  source "$DOTFILES/zsh/lib/helpers.zsh"
else
  function info { print -- "==> $*"; }
  function success { print -- "==> $*"; }
  function warn { print -- "==> $*"; }
fi

# replace dest with a fresh copy of src
_copy() {
  local src="$1" dest="$2"
  mkdir -p "${dest:h}"
  rm -rf "$dest"
  cp -R "$src" "$dest"
}

info "Setting up ~/Code config from ${DOTFILES/#$HOME/~}/agents ..."

# 1. orchestration config — COMPILED (copied): templates/root → ~/Code
_copy "$_ROOT/AGENTS.md"             "$_CODE/AGENTS.md"             && success "compiled ~/Code/AGENTS.md"
_copy "$_ROOT/CLAUDE.md"             "$_CODE/CLAUDE.md"             && success "compiled ~/Code/CLAUDE.md"
_copy "$_ROOT/claude/settings.json"  "$_CODE/.claude/settings.json" && success "compiled ~/Code/.claude/settings.json"
_copy "$_ROOT/opencode.json"         "$_CODE/opencode.json"         && success "compiled ~/Code/opencode.json"
_copy "$_ROOT/workspaces/AGENTS.md"  "$_CODE/workspaces/AGENTS.md"  && success "compiled ~/Code/workspaces/AGENTS.md"
_copy "$_ROOT/workspaces/CLAUDE.md"  "$_CODE/workspaces/CLAUDE.md"  && success "compiled ~/Code/workspaces/CLAUDE.md"

# 2. skills — SYMLINKED live: skills/<name>/ → ~/Code/.claude/skills/<name>/ (bin excluded; on PATH)
#    This topic first, then each overlay's agents/skills/ (~/.dotfiles-*, e.g. a private repo).
rm -rf "$_CODE/.claude/skills"
mkdir -p "$_CODE/.claude/skills"
for root in "$_SKILLS" "$HOME"/.dotfiles-*/agents/skills(/N); do
  for d in "$root"/*(/N); do
    name=${d:t}
    [[ "$name" == bin ]] && continue
    if [[ -e "$_CODE/.claude/skills/$name" ]]; then
      warn "skipped ${d/#$HOME/~}: ~/Code/.claude/skills/$name already linked"
      continue
    fi
    ln -s "$d" "$_CODE/.claude/skills/$name"
    success "linked ~/Code/.claude/skills/$name -> ${d/#$HOME/~}"
  done
done

# 3. memory topics — the skill's `Topics —` line is synced from private ~/Code/memory/TOPICS.md;
#    the clean filter (see .gitattributes) commits a placeholder so the real list stays local.
if git -C "$DOTFILES" config filter.memory-topics.clean "sed -E 's/^([[:space:]]*Topics — ).*/\\1none yet (read INDEX.md)./'" &&
   git -C "$DOTFILES" config filter.memory-topics.smudge cat; then
  success "configured memory-topics git filter"
fi
"$_SKILLS/bin/memory" topics --sync >/dev/null 2>&1 && success "synced memory topics into the memory skill"

success "Done. Config compiled; skills linked live; CLIs on PATH (skills/bin via zsh/lib/path.zsh)."
info "Untouched: ~/Code/memory, github.com, live workspaces."
