# If we're not already inside a tmux session (i.e. this is a plain terminal window):
if [ -z "$TMUX" ]; then

  # Sweep any stale grouped sessions left over from terminals that died before
  # their EXIT trap could run (SIGKILL, crash, etc.).
  for s in $(tmux ls -F '#{session_name}' 2>/dev/null | grep '^term-'); do
    pid=${s#term-}
    kill -0 "$pid" 2>/dev/null || tmux kill-session -t "$s"
  done

  if tmux has-session -t default 2>/dev/null; then
    # A "default" session already exists — create a new session grouped to it.
    # Grouped sessions share the same windows but have independent active-window
    # state, so each terminal window can be looking at a different tmux window
    # simultaneously. $$ is this shell's PID, giving each terminal a unique name.
    #
    # Open a fresh window for this terminal so each new terminal starts on its
    # own window rather than wherever the group was last viewed. Capture its id
    # so the EXIT trap can remove it — otherwise every terminal leaks one window
    # into the shared "default" session, and they accumulate forever.
    win=$(tmux new-window -d -t default: -P -F '#{window_id}')
    trap "tmux kill-window -t '$win' 2>/dev/null; tmux kill-session -t 'term-$$' 2>/dev/null" EXIT
    tmux new-session -t default -s "term-$$" \; select-window -t "$win"
  else
    # No "default" session exists yet — create it fresh. This session is the
    # persistent base: it is NOT torn down on exit, so its windows survive for
    # the next terminal. Subsequent terminals group themselves to it (above).
    tmux new-session -s default
  fi

fi
