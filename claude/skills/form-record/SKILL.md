---
name: form-record
description: Record a browser form-filling session with Playwright codegen and save it as a replayable script. Use when the user wants to record filling a form, automate repetitive form entry, replay a form, or says "錄製表單", "form-record", "自動填表".
---

# Form Record

錄一次，之後 `node` 重播。不是測試，不進 CI。

腳本放 `e2e/playwright/forms/`。`playwright.config.js` 只收 `playwright/<site>/`，
所以這裡的東西不會被測試套件撿走。

## 錄製

先問使用者表單網址（沒給的話），然後請他在**自己的終端機**執行
（不要用 Bash 工具跑 — codegen 會開真的瀏覽器視窗並卡住直到關閉）：

```
npx playwright codegen --target=javascript -o e2e/playwright/forms/<name>.js <url>
```

告訴使用者：在 Claude Code 輸入框打 `! <指令>` 就能在這個 session 裡跑。

他照平常方式填完表單，關掉瀏覽器就會寫出檔案。

若表單要登入，先錄一次登入存成 session：

```
npx playwright codegen --save-storage=e2e/playwright/forms/.auth.json <login-url>
```

之後表單腳本開頭改成：

```js
const context = await browser.newContext({ storageState: '.auth.json' });
```

`.auth.json` 是活的 session cookie，加進 `.gitignore`，不要 commit。

## 整理錄出來的腳本

codegen 產出的東西很醜，錄完幫他改：

1. 刪掉重複的 `chromium.launch()` boilerplate，留一個。
2. `headless: false`，先加 `slowMo: 100` 讓他看得到在填什麼；穩了再拿掉。
3. 每次會變的欄位值拉成檔案最上面的變數。**要問使用者哪些欄位每次不一樣**，
   不要自己猜。
4. 最後送出前留 `page.pause()`，除非使用者明講要無人值守送出。
   真的送出表單是不可逆的。
5. codegen 有時會吐 `nth-child` 這種 CSS selector，換成
   `getByLabel` / `getByRole` — 前者下次改版面就壞。

腳本保持平舖直敘。不要 page object、不要抽 helper、不要為了一張表單做設定層。

## 重播

```
node e2e/playwright/forms/<name>.js
```
