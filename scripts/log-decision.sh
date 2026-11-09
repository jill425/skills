#!/usr/bin/env bash
# 決策紀錄：在目前 repo 的 git 目錄下追加一行 TSV（不進版控，worktree 共用同一份）。
# 用法：log-decision.sh <單號> <角色> <決定> <為什麼> <證據> <結果>
#   單號沒有就填 -；證據是指標（commit sha、檔案:行、驗收輪次、指令），不是長文。
# 印出紀錄檔路徑。
set -euo pipefail
(( $# == 6 )) || { echo "用法：$0 <單號> <角色> <決定> <為什麼> <證據> <結果>" >&2; exit 2; }
dir="$(git rev-parse --git-common-dir)/jill425"
log="$dir/decisions.tsv"
mkdir -p "$dir"
[[ -f $log ]] || printf '時間\t單號\t角色\t決定\t為什麼\t證據\t結果\n' > "$log"
clean() { [[ $1 == - ]] && { printf -- -; return; }; printf '%s' "$1" | tr '\t\r\n' '   ' | sed -E 's/^([=+@-])/'"'"'\1/'; }
row=$(date '+%Y-%m-%dT%H:%M:%S%z')
for cell in "$@"; do row+=$'\t'"$(clean "$cell")"; done
printf '%s\n' "$row" >> "$log"
echo "$log"
