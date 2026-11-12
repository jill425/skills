#!/usr/bin/env bash
# 移除測試場地在登記表的那一列，並刪掉場地目錄。只處理登記表上標為端到端測試場地的目錄。
# 用法：cleanup.sh <場地目錄>
set -euo pipefail
dir=$(cd "${1:?用法：cleanup.sh <場地目錄>}" && pwd)
registry=$HOME/.claude/task-backends/projects.md
marker="jill425 端到端測試場地"
grep -F "\`$dir\`" "$registry" 2>/dev/null | grep -qF "$marker" || { echo "$dir 不是登記過的測試場地，不刪" >&2; exit 1; }
grep -vF "\`$dir\`" "$registry" > "$registry.tmp" && mv "$registry.tmp" "$registry"
rm -r -- "$dir"
echo "已移除 $dir 與它的登記"
