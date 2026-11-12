#!/usr/bin/env bash
# 大場地：小型電商函式庫 shop，4 張有相依的單，考驗新模組、跨模組介面、有狀態邏輯與介面遷移。
# 用法：setup.sh <目錄>（目錄不能已存在）
set -euo pipefail
dir=${1:?用法：setup.sh <目錄>}
[[ -e $dir ]] && { echo "$dir 已存在" >&2; exit 1; }
mkdir -p "$dir"/{src/shop,tests,tasks,data}
dir=$(cd "$dir" && pwd)
cd "$dir"

cat > pyproject.toml <<'EOF'
[project]
name = "shop"
version = "0.1.0"
requires-python = ">=3.10"

[dependency-groups]
dev = ["pytest"]

[tool.pytest.ini_options]
pythonpath = ["src"]
EOF

: > src/shop/__init__.py

cat > src/shop/catalog.py <<'EOF'
import json
from pathlib import Path


def load_catalog(path: Path) -> "Catalog":
    data = json.loads(Path(path).read_text())
    return Catalog({item["sku"]: int(item["price_cents"]) for item in data["items"]})


class Catalog:
    def __init__(self, prices: dict[str, int]):
        self._prices = prices

    def get_price_cents(self, sku: str) -> int:
        return self._prices[sku]
EOF

cat > src/shop/cart.py <<'EOF'
from shop.catalog import Catalog


class Cart:
    def __init__(self, catalog: Catalog):
        self._catalog = catalog
        self._lines: dict[str, int] = {}

    def add(self, sku: str, qty: int) -> None:
        self._lines[sku] = self._lines.get(sku, 0) + qty

    def lines(self) -> dict[str, int]:
        return dict(self._lines)

    def total_cents(self) -> int:
        return sum(self._catalog.get_price_cents(sku) * qty for sku, qty in self._lines.items())
EOF

cat > data/catalog.json <<'EOF'
{"items": [
  {"sku": "TEA", "price_cents": 12000},
  {"sku": "MUG", "price_cents": 35000},
  {"sku": "PEN", "price_cents": 2500},
  {"sku": "BAG", "price_cents": 89000}
]}
EOF

cat > tests/test_cart.py <<'EOF'
from pathlib import Path

from shop.cart import Cart
from shop.catalog import load_catalog

CATALOG = load_catalog(Path(__file__).parent.parent / "data" / "catalog.json")


def test_total_sums_price_times_quantity():
    cart = Cart(CATALOG)
    cart.add("TEA", 2)
    cart.add("PEN", 1)
    assert cart.total_cents() == 2 * 12000 + 2500


def test_adding_same_sku_accumulates():
    cart = Cart(CATALOG)
    cart.add("MUG", 1)
    cart.add("MUG", 2)
    assert cart.lines() == {"MUG": 3}
EOF

cat > CLAUDE.md <<'EOF'
# shop

本檔與 jill425 plugin 的 task 契約疊加生效。

小型電商函式庫：商品目錄、購物車、促銷、訂單。金額以「分」為單位的整數計算，不用浮點數。

## 目錄

- `src/shop/`：套件本體。
- `data/`：商品與促銷的 JSON 資料。
- `tests/`：pytest 測試。

## 測試與 DoD

- `uv run pytest -q` 全綠。
EOF

cat > tasks/INDEX.md <<'EOF'
# Tasks

| id | title | status | dependencies |
|----|-------|--------|--------------|
| 1  | 修正購物車接受 0 或負數數量 | Not started | [] |
| 2  | 新增促銷規則 | Not started | [1] |
| 3  | 新增訂單與狀態流轉 | Not started | [2] |
| 4  | 金額改用 Money 型別 | Not started | [3] |
EOF

cat > tasks/task-1-cart-qty.md <<'EOF'
---
id: 1
title: 修正購物車接受 0 或負數數量
status: Not started
dependencies: []
---

## 背景
`Cart.add`（`src/shop/cart.py`）不檢查數量，加入 0 或負數都會被接受，總額可能變成負的。

重現：
```
PYTHONPATH=src uv run python -c "from pathlib import Path; from shop.catalog import load_catalog; from shop.cart import Cart; c = Cart(load_catalog(Path('data/catalog.json'))); c.add('TEA', -3); print(c.total_cents())"
```
實際輸出 `-36000`；期望 `add` 當下就拒絕。

## 目標
`Cart.add` 拒絕 0 與負數數量；購物車內容與總額不受影響。
- 範圍外：庫存檢查

## 做法
無。

## Test 方法
- [ ] 重現：`c.add('TEA', -3)` 修正前會被接受、修正後拋出 `ValueError`（或其子類別），且購物車維持原樣
- [ ] `c.add('TEA', 0)` 同樣被拒絕
- [ ] `uv run pytest -q` 全綠
- [ ] 測試有鑑別力：拿掉實作後新增的測試全紅（斷言失敗）、放回全綠（驗法見 tdd-evidence.md）

## 執行備註
## 結論
## 驗收結果
EOF

cat > tasks/task-2-promotions.md <<'EOF'
---
id: 2
title: 新增促銷規則
status: Not started
dependencies: [1]
---

## 背景
營運要做兩種促銷，之後還會再加別的種類，所以加一種新促銷時，應該只需要新增那種規則，購物車的計價程式不必跟著改。

## 目標
結帳金額套用促銷規則。
- **滿額折**：小計達到門檻（含）時折抵固定金額。
- **買 N 送 1**：指定商品每買 N 件，其中 1 件免費。
- 規則從 `data/promotions.json` 讀入。
- 多條規則同時成立時，先算買 N 送 1，再用折扣後的金額判斷滿額折。
- 範圍外：會員價、優惠券、規則的有效期間

## 做法
- 促銷是新的模組，跟購物車、商品目錄分開。
- `Cart.total_cents()` 維持「未折扣的小計」；新增 `Cart.checkout_total_cents()` 回傳套用促銷後的金額。
- `data/promotions.json` 格式：
  ```json
  {"rules": [
    {"type": "threshold", "threshold_cents": 100000, "discount_cents": 10000},
    {"type": "buy_n_get_one", "sku": "PEN", "n": 3}
  ]}
  ```
- 格式錯誤（缺欄位、未知的 type、負數金額）在載入時就拋錯，錯誤訊息指出是第幾條規則。

## Test 方法
- [ ] 買 3 支 PEN（單價 2500）、規則為「PEN 買 3 送 1」：結帳金額 5000
- [ ] 小計 120000、規則為「滿 100000 折 10000」：結帳金額 110000；小計 99999 時不折
- [ ] 兩條規則都啟用、購物車是 6 支 PEN 加 1 個 BAG：結帳金額 99000（原價 104000；買 3 送 1 後 99000，未達門檻，不再折）
- [ ] 兩條規則都啟用、購物車是 3 支 PEN、1 個 BAG、1 個 TEA：結帳金額 96000（買 3 送 1 後 106000，達門檻再折 10000）
- [ ] 載入含未知 type 的規則檔時拋錯，錯誤訊息含該規則的序號
- [ ] `uv run pytest -q` 全綠
- [ ] 測試有鑑別力：拿掉實作後新增的測試全紅（斷言失敗）、放回全綠（驗法見 tdd-evidence.md）

## 執行備註
## 結論
## 驗收結果
EOF

cat > tasks/task-3-orders.md <<'EOF'
---
id: 3
title: 新增訂單與狀態流轉
status: Not started
dependencies: [2]
---

## 背景
購物車結帳後要成立訂單，並追蹤付款、出貨。付款通知可能因為網路重送而重複到達，同一筆付款不能被記兩次。

## 目標
- 從購物車成立訂單，金額為結帳金額，初始狀態「待付款」。
- 狀態流轉：待付款 → 已付款 → 已出貨 → 已完成；待付款與已付款可以取消。已付款後取消要留下一筆退款紀錄。
- 不合法的流轉（例如待付款直接出貨、已出貨後取消）拋出專用的錯誤型別，訂單狀態不變。
- 付款以 `payment_id` 識別：同一個 `payment_id` 重複付款只記一次；已付款的訂單收到不同的 `payment_id` 要拋錯。
- 範圍外：真的金流串接、庫存扣減、多幣別

## 做法
- 訂單是新的模組。
- 訂單透過 repository 介面讀寫；提供記憶體版實作給測試與現階段使用，之後會換成資料庫。

## Test 方法
- [ ] 成立訂單：金額等於購物車的結帳金額，狀態為待付款
- [ ] 合法流轉逐一可走完：待付款 → 已付款 → 已出貨 → 已完成
- [ ] 每一種不合法流轉都拋出同一個專用錯誤型別，且訂單狀態不變（測試涵蓋所有不合法的組合）
- [ ] 同一個 `payment_id` 呼叫兩次付款：只有一筆付款紀錄
- [ ] 已付款後取消：狀態為已取消，且有一筆退款紀錄
- [ ] `uv run pytest -q` 全綠
- [ ] 測試有鑑別力：拿掉實作後新增的測試全紅（斷言失敗）、放回全綠（驗法見 tdd-evidence.md）

## 執行備註
## 結論
## 驗收結果
EOF

cat > tasks/task-4-money.md <<'EOF'
---
id: 4
title: 金額改用 Money 型別
status: Not started
dependencies: [3]
---

## 背景
金額目前到處是裸的 int，參數名稱不一，曾有人把「分」當「元」傳進去。改成專用的金額型別，讓這類錯誤寫不出來。

## 目標
- 新增 `Money`：整數「分」加幣別（預設 TWD），不同幣別相加或比較時拋錯。
- 商品目錄、購物車、促銷、訂單全部改用 `Money`。
- 舊的介面全部移除：`Catalog.get_price_cents`、`Cart.total_cents`、`Cart.checkout_total_cents`，以及其他以 `_cents` 結尾、回傳裸 int 的公開方法。新的對應方法回傳 `Money`。
- 範圍外：匯率換算

## 做法
專案內部沒有外部使用者，不需要保留相容層。

## Test 方法
- [ ] `grep -rnE "get_price_cents|total_cents" src tests` 沒有結果
- [ ] `Money` 不同幣別相加拋錯；同幣別相加結果正確
- [ ] 原有的購物車、促銷、訂單行為測試改用 `Money` 後全部通過，期望金額不變
- [ ] `uv run pytest -q` 全綠

## 執行備註
## 結論
## 驗收結果
EOF

printf '.venv/\n__pycache__/\n.pytest_cache/\nuv.lock\n.e2e-run.log\n' > .gitignore
git init -q -b main
git config user.name e2e
git config user.email e2e@example.com
git config core.hooksPath /dev/null
git add -A
git commit -q -m "chore: init shop fixture"

registry=$HOME/.claude/task-backends/projects.md
mkdir -p "$(dirname "$registry")"
[[ -f $registry ]] || printf '# Task 後端登記表\n\n| 專案（remote 或路徑） | 後端 | 備註 |\n|---|---|---|\n' > "$registry"
printf '| `%s` | `local-files` | jill425 端到端測試場地，測完由 tests/e2e/cleanup.sh 移除 |\n' "$dir" >> "$registry"
echo "$dir"
