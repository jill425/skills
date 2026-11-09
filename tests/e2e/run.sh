#!/usr/bin/env bash
# 在測試場地用非互動模式跑一輪 task-run，輸出存到 <場地>/.e2e-run.log。
# 用法：run.sh <場地目錄> [花費上限美元，預設 30] [主線模型，預設 sonnet]
# 主線只選單、派工、彙總，用 sonnet；executor 與 tester 的模型由契約〈模型分配〉依場景決定。
# 主體包在函式裡、最後才呼叫：bash 會先讀完整個函式再執行，跑到一半改這個檔也不會執行到殘缺的指令。
set -euo pipefail
main() {
  dir=$(cd "${1:?用法：run.sh <場地目錄> [上限]}" && pwd)
  budget=${2:-30}
  main_model=${3:-sonnet}
  cd "$dir"
  start=$(date +%s)
  claude -p --model "$main_model" --permission-mode auto --max-budget-usd "$budget" \
    '/jill425:task-run 把待辦做完。這是無人值守的執行，不要問我任何問題。' \
    > .e2e-run.log 2>&1 || echo "claude 結束碼 $?" >> .e2e-run.log
  echo "耗時 $(( $(date +%s) - start )) 秒；輸出：$dir/.e2e-run.log"
}
main "$@"
exit
