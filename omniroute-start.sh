#!/bin/bash
# omnicode - one-command launcher for OmniRoute + Claude Code on Termux/Android
# Run this from inside your Ubuntu proot-distro environment.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 24 > /dev/null 2>&1

nohup omniroute serve > ~/omniroute.log 2>&1 &
disown

echo "Starting OmniRoute..."
total=40
for i in $(seq 1 $total); do
  percent=$((i * 100 / total))
  filled_len=$((percent * 40 / 100))
  filled=$(printf '%*s' "$filled_len" '' | tr ' ' '#')
  empty=$(printf '%*s' "$((40 - filled_len))" '' | tr ' ' '-')
  printf "\r[%s%s] %d%%" "$filled" "$empty" "$percent"

  if curl -s http://localhost:20128/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d '{"model":"auto","messages":[{"role":"user","content":"ping"}]}' \
      | grep -q "choices\|content"; then
    printf "\r[%s] 100%% Ready!      \n" "$(printf '%*s' 40 '' | tr ' ' '#')"
    echo ""
    echo "=========================================="
    echo "  Dashboard: http://localhost:20128"
    echo "=========================================="
    echo ""
    echo "Launching Claude Code in 3 seconds..."
    sleep 3
    omniroute launch
    exit 0
  fi
  sleep 1
done

echo -e "\nOmniRoute failed to start. Check ~/omniroute.log for details."
exit 1
