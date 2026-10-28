---
name: ave-ck-inquiry
description: Create a reusable ave_ck inquiry in the local dev DB and print the online-application URL, so the form can be opened without going through the real inquiry flow. Use when the user wants to fill/open the ave_ck online application form, needs a fresh inquiry token, hits "Application not found, or has expired", or says "建 inquiry", "開 online app", "ave-ck-inquiry".
---

# ave_ck inquiry (dev)

建一筆固定 token 的 inquiry，讓使用者直接進 online application 表單。

跑這個（可重複執行，會先砍掉同 token 的舊資料）：

```bash
docker exec ave_ck-nerv_ave_ck-1 bin/rails runner "$(cat /project/scripts/inquiry/ave_ck_inquiry.rb)"
```

Ruby 本體在 `/project/scripts/inquiry/ave_ck_inquiry.rb`（Mac 的 `~/proj/scripts/inquiry/`），skill 和
Mac 的 `ave_ck_app.command` 共用這一份，要改資料就改那裡。

## 第二步：填表（可選）

填表腳本在 `/project/scripts/inquiry/ave_ck_app.mjs`。`/project` 是 Mac 的 `~/proj/`
掛進容器的目錄 —— Claude 讀寫這個路徑，使用者在 Mac 上跑 `~/proj/scripts/inquiry/`
的同一個檔案。只有一份，不用同步。

**刻意不放 repo**（內含個人填表資料），也不放 skill 資料夾（那在容器裡，Mac 讀不到）。

請使用者在 **Mac terminal** 跑：

```
node ~/proj/scripts/inquiry/ave_ck_app.mjs
```

需要 Mac 上有 node + `npx playwright install chromium`。容器沒瀏覽器也沒 display，
Claude 不能替使用者執行它，也不能替他開瀏覽器。

腳本會開瀏覽器、過密碼關、填完整張表，然後 `page.pause()` 停住等使用者檢查並
自己按 Submit。要改填入的值就編輯檔案最上面的三個物件
(`owner` / `plan` / `beneficiary`)。

## 建完一定要回報這兩樣

跑完建 inquiry 後，**每次都要同時給使用者網址和指令**，不要只給其中一個：

1. **網址 + 密碼**（要手動看表單時用）

   ```
   http://nerv_ave_ck.local.abagile.com/nerv/en/web/inquiry/application?editable=true&token=_token_ave_ck
   ```

   密碼：`_pass`

2. **Mac 上一鍵重建 inquiry + 填表**（Finder 點兩下，或 terminal 跑）

   ```
   ~/proj/scripts/inquiry/ave_ck_app.command
   ```

   它會自己 `docker exec` 建 inquiry 再跑 `node ave_ck_app.mjs`，不用先叫 Claude。
   只要填表、不重建的話：`node ~/proj/scripts/inquiry/ave_ck_app.mjs`

## 前提

- 容器 `ave_ck-nerv_ave_ck-1` 要活著（`docker ps` 確認）。
- 網址走 traefik：`Host(nerv_ave_ck.local.abagile.com) && PathPrefix(/nerv)` → port 3001。

## 兩個會踩的坑

跑的是 **development** 環境和 dev DB，不是 test。所以：

1. **Producer `180` 不存在**（那是 test fixture）。用 `Producer.find_by!(code: "AB032001")`
   抓 dev DB 裡真的有的 JP producer（region_code 03）。
2. **`submitted_at` 一定要設**。test 環境沒有 `enable_jp_video` 這個 Setting，
   `require_watch_video?` 第一行就 return false；dev DB 有，會往下走到
   `submitted_at > enable_jp_video_at` 然後 `undefined method '>' for nil`。

## 其他

- `expired_at` 是明天 —— 過期就重跑一次。
- 只動 `token: "_token_ave_ck"` 這一筆（以及它送出後產生的那張 BasicPlan），
  不會碰到 dev DB 其他 inquiry。
- test 環境另有一支 HTTP endpoint 做同樣的事
  (`POST /nerv/e2e_support/online_application/inquiry/ave_ck/setup`，
  見 `app/concepts/e2e_support/online_application/inquiry/ave_ck.rb`)，
  但只在 `Rails.env.test?` 掛載，dev 用不到。

## 填表腳本的已知缺口

`/project/scripts/inquiry/ave_ck_app.mjs` 是從一次 codegen 錄製整理出來的，還沒實跑驗證過。
已知：

- **select2 改寫過** — codegen 錄到的 `#select2-result-label-360` 是每次 render
  重編的流水號，重播必壞。改綁 `#s2id_<欄位id>`（同 Capybara 版的做法）。
- **日期欄位掛 jasny input mask** — `fill()` 繞過鍵盤事件所以吃不進去，
  要用 `pressSequentially` 逐字打 + 點完等 300ms（同 Capybara 版
  `fill_masked_date`）。值傳純數字，連字號 mask 自己補。吃不進去就把
  delay 調大。
- 完整的填表邏輯另有 Capybara 版
  (`test/integration/online_application/_fill_in_components.rb`)，涵蓋更多分支
  (region_code、Feature flag)，但綁在 Rails test 環境裡。
