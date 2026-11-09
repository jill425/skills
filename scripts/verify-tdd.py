#!/usr/bin/env python3
"""反向驗證：拿掉一張單的實作，確認它新增的每個測試都會紅；放回實作後全綠。

用法：
  verify-tdd.py --id 12                    # local-files：基底＝第一個 `#12 ` commit 的 parent
  verify-tdd.py --base develop             # issue 後端：基底＝與整合分支的 merge-base
  選項：--repo DIR  --workdir DIR  --copy PATH（可重複，未進版控但測試要用的檔）
        --runner "uv run pytest"（預設）

exit code：0 通過／1 未過／2 通過但有項目需人工看／3 無法驗證（環境）
v1 只支援 pytest；「新增的測試」以 `def test_*` 名稱比對基底版本，既有測試改了斷言不在檢查範圍。
"""
import argparse
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

TEST_DEF = re.compile(r"^\s*(?:async\s+)?def\s+(test\w*)\s*\(", re.M)
TEST_SIDE = re.compile(r"(^|/)(tests?|testing)/|(^|/)conftest\.py$|(^|/)test_[^/]*\.py$|_test\.py$")
TEST_FILE = re.compile(r"(^|/)test_[^/]*\.py$|_test\.py$")

PASS, FAIL, MANUAL, UNVERIFIABLE = 0, 1, 2, 3


def git(repo, *args, check=True):
    out = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True)
    if check and out.returncode != 0:
        sys.exit(f"git {' '.join(args)} 失敗：{out.stderr.strip()}")
    return out.stdout


def resolve_base(repo, task_id, base_ref, head):
    if base_ref:
        return git(repo, "merge-base", base_ref, head).strip(), None
    commits = git(repo, "log", "--reverse", "--format=%H", f"--grep=^#{task_id} ", head).split()
    if not commits:
        sys.exit(f"找不到 `#{task_id} ` 開頭的 commit")
    touched = set()
    for sha in commits:
        touched.update(git(repo, "show", "--name-only", "--format=", sha).split())
    return git(repo, "rev-parse", f"{commits[0]}^").strip(), touched


def changed_files(repo, base, head, touched):
    rows = git(repo, "diff", "--name-status", "--no-renames", base, head).splitlines()
    changes = [tuple(r.split("\t", 1)) for r in rows]
    return [(s, p) for s, p in changes if touched is None or p in touched]


def new_test_names(repo, base, head, path):
    after = TEST_DEF.findall(git(repo, "show", f"{head}:{path}"))
    before = git(repo, "show", f"{base}:{path}", check=False)
    return sorted(set(after) - set(TEST_DEF.findall(before)))


def module_of(path):
    return path[:-3].replace("/", ".")


def run_pytest(runner, wt, files, xml_path):
    cmd = shlex.split(runner) + [*files, "-q", "-p", "no:cacheprovider", "--continue-on-collection-errors", f"--junitxml={xml_path}"]
    env = {k: v for k, v in os.environ.items() if k != "VIRTUAL_ENV"}
    proc = subprocess.run(cmd, cwd=wt, env=env, capture_output=True, text=True)
    return proc.returncode, proc.stdout[-2000:] + proc.stderr[-2000:]


def parse_junit(xml_path):
    """回傳 ({(module, name): outcome}, {壞掉無法收集的 module})。"""
    results, broken = {}, set()
    if not Path(xml_path).exists():
        return results, broken
    for case in ET.parse(xml_path).iter("testcase"):
        cls, name = case.get("classname", ""), case.get("name", "")
        kinds = {child.tag for child in case}
        if not cls and "error" in kinds:
            broken.add(name)
            continue
        outcome = "failure" if "failure" in kinds else "error" if "error" in kinds else \
                  "skipped" if "skipped" in kinds else "passed"
        results[(cls, name.split("[")[0])] = outcome
    return results, broken


def outcome_for(results, broken, module, name):
    if module in broken:
        return "collect-error"
    hits = [o for (cls, n), o in results.items() if n == name and (cls == module or cls.startswith(module + "."))]
    if not hits:
        return "missing"
    for worst in ("passed", "skipped", "error", "failure"):
        if worst in hits:
            return worst
    return hits[0]


def import_leak(runner, wt, repo):
    """worktree 的測試若 import 到主目錄的 code，兩輪都在測錯的樹。"""
    argv = shlex.split(runner)
    if argv[-2:] == ["-m", "pytest"]:
        argv = argv[:-2]
    elif argv[-1] == "pytest":
        argv = argv[:-1] + ["python"]
    probe = "import site,sys;print('\\n'.join(site.getsitepackages()+[sys.prefix]))"
    env = {k: v for k, v in os.environ.items() if k != "VIRTUAL_ENV"}
    out = subprocess.run(argv + ["-c", probe], cwd=wt, env=env, capture_output=True, text=True).stdout
    for sp in out.split():
        for f in list(Path(sp).glob("*.pth")) + list(Path(sp).glob("*.dist-info/direct_url.json")):
            text = f.read_text(errors="ignore")
            if str(repo) in text and str(wt) not in text:
                return f"{f} 指向主目錄 {repo}"
    return None


def remove_implementation(wt, base, impl_changes):
    for status, path in impl_changes:
        if status == "A":
            (Path(wt) / path).unlink(missing_ok=True)
        else:
            git(wt, "checkout", base, "--", path)


def judge(new_tests, head, reverted):
    rows, levels = [], {PASS}
    for path, names in new_tests.items():
        mod = module_of(path)
        for name in names:
            h = outcome_for(*head, mod, name)
            r = outcome_for(*reverted, mod, name)
            if h != "passed":
                verdict, level = f"✗ 有實作卻沒綠（{h}）", FAIL
            elif r == "failure":
                verdict, level = "✓", PASS
            elif r == "passed":
                verdict, level = "✗ 拿掉實作照樣過：測試沒鑑別力", FAIL
            elif r == "collect-error":
                verdict, level = "⚠ 拿掉實作後無法收集（多半是新模組），請人工看斷言", MANUAL
            else:
                verdict, level = f"⚠ 拿掉實作後是 {r}，不是斷言失敗，請人工看", MANUAL
            rows.append((path, name, r, h, verdict))
            levels.add(level)
    return rows, FAIL if FAIL in levels else max(levels)


def copy_untracked(repo, wt, extra):
    defaults = [p.name for p in Path(repo).glob(".env*") if p.is_file()]
    tracked = set(git(repo, "ls-files").split())
    for rel in [d for d in defaults if d not in tracked] + list(extra):
        src = Path(repo) / rel
        if src.exists():
            dst = Path(wt) / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            (shutil.copytree if src.is_dir() else shutil.copy2)(src, dst)


def verify(args, repo, workdir):
    head_sha = git(repo, "rev-parse", args.head).strip()
    base, touched = resolve_base(repo, args.id, args.base, head_sha)
    changes = changed_files(repo, base, head_sha, touched)
    tests = [p for s, p in changes if s != "D" and TEST_FILE.search(p)]
    impl = [(s, p) for s, p in changes if not TEST_SIDE.search(p)]
    new_tests = {p: n for p in tests if (n := new_test_names(repo, base, head_sha, p))}
    print(f"基底 {base[:8]}　驗收版本 {head_sha[:8]}　實作檔 {len(impl)} 個　測試檔 {len(tests)} 個　新增測試 {sum(map(len, new_tests.values()))} 個")
    if not new_tests:
        print("⚠ 這張單沒有新增 `def test_*`（可能只改了既有測試），請人工看")
        return MANUAL
    if not impl:
        print("⚠ 沒有實作檔可拿掉，無法反向驗證")
        return MANUAL

    wt = workdir / "wt"
    git(repo, "worktree", "add", "--detach", str(wt), head_sha)
    try:
        copy_untracked(repo, wt, args.copy)
        rc, log = run_pytest(args.runner, wt, tests, workdir / "head.xml")
        head = parse_junit(workdir / "head.xml")
        if not any(o == "passed" for o in head[0].values()):
            print(f"✗ HEAD 上沒有任何測試通過（exit {rc}），判為環境起不來：\n{log}")
            return UNVERIFIABLE
        if leak := import_leak(args.runner, wt, repo):
            print(f"✗ import 來源不在 worktree：{leak}")
            return UNVERIFIABLE
        remove_implementation(wt, base, impl)
        run_pytest(args.runner, wt, tests, workdir / "reverted.xml")
        rows, code = judge(new_tests, head, parse_junit(workdir / "reverted.xml"))
    finally:
        git(repo, "worktree", "remove", "--force", str(wt), check=False)

    print("\n| 測試 | 拿掉實作 | 有實作 | 判定 |\n|---|---|---|---|")
    for path, name, r, h, verdict in rows:
        print(f"| `{path}::{name}` | {r} | {h} | {verdict} |")
    print(f"\njunit 證據：{workdir}/head.xml、{workdir}/reverted.xml")
    return code


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    which = ap.add_mutually_exclusive_group(required=True)
    which.add_argument("--id")
    which.add_argument("--base")
    ap.add_argument("--head", default="HEAD", help="驗收的版本，預設 HEAD")
    ap.add_argument("--repo", default=".")
    ap.add_argument("--workdir")
    ap.add_argument("--copy", action="append", default=[])
    ap.add_argument("--runner", default="uv run pytest")
    args = ap.parse_args()
    repo = Path(git(args.repo, "rev-parse", "--show-toplevel").strip())
    workdir = Path(args.workdir or tempfile.mkdtemp(prefix="verify-tdd-")).resolve()
    workdir.mkdir(parents=True, exist_ok=True)
    code = verify(args, repo, workdir)
    print(["結果：通過", "結果：未過", "結果：通過，但有項目需人工看", "結果：無法驗證"][code])
    sys.exit(code)


if __name__ == "__main__":
    main()
