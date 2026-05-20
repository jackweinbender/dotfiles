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
    # Also open a fresh window for this terminal so each new terminal starts on
    # its own window rather than wherever the group was last viewed. The window
    # persists in "default" after the terminal closes.
    tmux new-session -t default -s "term-$$" \; new-window
  else
    # No "default" session exists yet — create it fresh.
    # Subsequent terminals will group themselves to this one.
    tmux new-session -s default
  fi

  # When this terminal window is closed, kill its grouped session.
  # This keeps `tmux ls` clean — without this, every closed terminal
  # leaves behind a dead "term-XXXX" session. The "default" session
  # itself is unaffected, and all windows/history remain intact.
  trap "tmux kill-session -t 'term-$$' 2>/dev/null" EXIT

fi
