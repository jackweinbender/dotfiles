#!/usr/bin/env zsh
# agents — set up the ~/Code orchestration config from this dotfiles topic.
#
#   templates/root/  → COMPILED (copied) into ~/Code: AGENTS.md, CLAUDE.md,
#                      .claude/settings.json, workspaces/ conventions. Build artifacts —
#                      edit templates/root/ and re-run; don't hand-edit the ~/Code copies.
#   skills/<name>/   → SYMLINKED live into ~/Code/.claude/skills/<name>/. Edit a SKILL.md
#                      and it's live immediately (still git-tracked here = change-controlled).
#                      skills/bin is on PATH (via zsh/lib/path.zsh), not linked here.
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
_copy "$_ROOT/workspaces/AGENTS.md"  "$_CODE/workspaces/AGENTS.md"  && success "compiled ~/Code/workspaces/AGENTS.md"
_copy "$_ROOT/workspaces/CLAUDE.md"  "$_CODE/workspaces/CLAUDE.md"  && success "compiled ~/Code/workspaces/CLAUDE.md"

# 2. skills — SYMLINKED live: skills/<name>/ → ~/Code/.claude/skills/<name>/ (bin excluded; on PATH)
rm -rf "$_CODE/.claude/skills"
mkdir -p "$_CODE/.claude/skills"
for d in "$_SKILLS"/*(/N); do
  name=${d:t}
  [[ "$name" == bin ]] && continue
  ln -s "$d" "$_CODE/.claude/skills/$name"
  success "linked ~/Code/.claude/skills/$name -> ${d/#$HOME/~}"
done

success "Done. Config compiled; skills linked live; CLIs on PATH (skills/bin via zsh/lib/path.zsh)."
info "Untouched: ~/Code/memory, github.com, live workspaces."
