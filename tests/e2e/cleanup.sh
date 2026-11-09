#!/usr/bin/env bash
# 移除測試場地在登記表的那一列，並刪掉場地目錄。
# 用法：cleanup.sh <場地目錄>
set -euo pipefail
dir=$(cd "${1:?用法：cleanup.sh <場地目錄>}" && pwd)
registry=$HOME/.claude/task-backends/projects.md
if [[ -f $registry ]]; then
  grep -vF "\`$dir\`" "$registry" > "$registry.tmp" && mv "$registry.tmp" "$registry"
fi
[[ -f $dir/tasks/task-1-mul.md && -f $dir/scripts/push_rates.sh ]] || { echo "$dir 看起來不是測試場地，不刪" >&2; exit 1; }
rm -r -- "$dir"
echo "已移除 $dir 與它的登記"
