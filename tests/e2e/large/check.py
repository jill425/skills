#!/usr/bin/env python3
"""檢查大場地（shop）跑完 task-run 後留下的狀態。設計品質不在這裡判，交給獨立審查。

用法：check.py <場地目錄>；全部通過 exit 0，否則 exit 1。
"""
import re
import subprocess
import sys
from pathlib import Path

COMMIT = re.compile(r"^(#\d+ )?(feat|fix|refactor|test|docs|chore|perf)(\([^)]+\))?!?: \S")
TICKETS = (1, 2, 3, 4)


def sh(cwd, *cmd):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


def status(root, n):
    text = next((root / "tasks").glob(f"task-{n}-*.md")).read_text()
    return re.search(r"^status:\s*(\S+)", text, re.M).group(1), text


def checks(root):
    for n in TICKETS:
        s, text = status(root, n)
        yield f"單 {n} 完成", s in {"Verified", "Passed"}, s
        if n != 4:
            result = re.search(r"^## 驗收結果\n(.*?)(?=^## |\Z)", text, re.M | re.S)
            yield f"單 {n} 驗收結果有反向驗證的證據", bool(result and re.search(r"verify-tdd|鑑別|拿掉實作", result.group(1))), ""

    subjects = sh(root, "git", "log", "--reverse", "--format=%s").stdout.splitlines()
    bad = [s for s in subjects if not COMMIT.match(s) and not s.startswith("Merge")]
    yield "所有 commit 符合格式", not bad, "; ".join(bad[:3])
    first = {n: next((i for i, s in enumerate(subjects) if s.startswith(f"#{n} ")), None) for n in TICKETS}
    ordered = None not in first.values() and [first[n] for n in TICKETS] == sorted(first[n] for n in TICKETS)
    yield "四張單依相依順序開工", ordered, str(first)

    src = root / "src" / "shop"
    yield "促銷與訂單是新的模組", len(list(src.glob("*.py"))) + len(list(src.glob("*/*.py"))) > 3, str(sorted(p.name for p in src.rglob("*.py")))
    yield "data/promotions.json 存在", (root / "data" / "promotions.json").exists(), ""
    leftovers = sh(root, "grep", "-rnE", "get_price_cents|total_cents", "src", "tests").stdout.strip()
    yield "舊的 _cents 介面已全部移除", not leftovers, leftovers[:200]
    yield "Money 型別存在", bool(sh(root, "grep", "-rn", "class Money", "src").stdout), ""
    tests = sh(root, "uv", "run", "pytest", "-q")
    last = tests.stdout.strip().splitlines()[-1:] or [""]
    yield "uv run pytest -q 全綠", tests.returncode == 0, last[0]

    gitdir = Path(sh(root, "git", "rev-parse", "--git-common-dir").stdout.strip())
    gitdir = gitdir if gitdir.is_absolute() else root / gitdir
    yield "鎖檔已刪除", not (gitdir / "jill425" / "task-run.lock").exists(), ""
    dirty = [l for l in sh(root, "git", "status", "--porcelain").stdout.splitlines() if not l[3:].startswith(("tasks/", ".e2e-run.log"))]
    yield "工作目錄沒有遺留未 commit 的 code", not dirty, "; ".join(dirty[:3])


def main():
    root = Path(sys.argv[1]).resolve()
    failed = 0
    for name, ok, detail in checks(root):
        failed += not ok
        print(f"{'PASS' if ok else 'FAIL'}  {name}" + (f"  ({detail})" if detail and not ok else ""))
    print(f"\n{'全部通過' if not failed else f'{failed} 項未過'}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
