#!/usr/bin/env bash
# PostToolUse(Bash) hook：agent 剛做完的 git commit 不符 task 契約〈git commit〉就 exit 2，把問題回饋給 agent 去 amend。
# 設 JILL425_COMMIT_CHECK=off 可關閉。只看 agent 的 commit，不裝 git hook、不改任何 git 設定。讀 git log -1 而不解析 -m；commit 超過 120 秒視為這次沒成功，不檢查舊 HEAD。
[[ ${JILL425_COMMIT_CHECK:-on} == off ]] && exit 0
command -v jq >/dev/null || { echo "commit-check：找不到 jq，略過 commit 格式檢查" >&2; exit 0; }
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)' <<<"$cmd" || exit 0

dir=$(jq -r '.cwd // "."' <<<"$input")
target=$(grep -oE '(cd|git -C)[[:space:]]+[^[:space:];&|]+' <<<"$cmd" | head -1 | awk '{print $NF}')
[[ -n $target ]] && { [[ $target = /* ]] && dir=$target || dir="$dir/$target"; }
dir=${dir/#\~/$HOME}
git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0
(( $(date +%s) - $(git -C "$dir" log -1 --format=%ct) > 120 )) && exit 0

msg=$(git -C "$dir" log -1 --format=%B)
subject=$(head -1 <<<"$msg")
grep -qE '^(Merge|Revert|fixup!|squash!|amend!)' <<<"$subject" && exit 0

problems=()
grep -qE '^(#[0-9]+ )?(feat|fix|refactor|test|docs|chore|perf)(\([^)]+\))?!?: [^ ]' <<<"$subject" \
  || problems+=("subject 要是 \`#<id> <type>(<scope>): <subject>\`，type ∈ feat|fix|refactor|test|docs|chore|perf")
(( $(printf '%s' "$subject" | wc -m) > 72 )) && problems+=("subject 超過 72 字元（含前綴）")
lines=$(grep -c . <<<"$msg")
(( lines > 2 )) && problems+=("訊息只能 1–2 行，目前 $lines 行")
grep -qiE '^[a-z]+(-[a-z]+)*-by: ' <<<"$msg" && problems+=("不加任何 trailer（含 Co-Authored-By）")
if ! grep -qE '^#[0-9]+ ' <<<"$subject" && git -C "$dir" log -30 --format=%s | grep -qE '^#[0-9]+ '; then
  problems+=("這個 repo 的 commit 帶 \`#<id>\`，這筆沒帶；屬於某張單就補上，純雜務可忽略")
fi
(( ${#problems[@]} == 0 )) && exit 0

{
  echo "剛才的 commit 不符 task 契約〈git commit〉（contract/task-contract.md）："
  printf -- '- %s\n' "${problems[@]}"
  echo "目前訊息：$subject"
  echo "尚未 push 就用 \`git commit --amend -m '<修正後訊息>'\` 改掉；已 push 的不要改，回報使用者。"
} >&2
exit 2
