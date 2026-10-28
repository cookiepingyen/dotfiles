---
name: db-migrate-skip
description: Mark already-applied migrations as done in schema_migrations, without re-running them. Use when `rails db:migrate` fails with PG::DuplicateTable / DuplicateColumn / "already exists" because the local DB was copied from production, or the user says "migration 跑不過 本機已有", "幫我跳過 migration", "db-migrate-skip".
---

# 跳過已生效的 migration

## 什麼情況用這個

本機 dev DB 是從**正式站複製**下來的，所以 schema 已經是新的，但
`schema_migrations` 只有正式站當下的版本記錄。跑 `db:migrate` 時，那些
正式站已經上線、但複製時間點之後才進 repo 的 migration 會重跑一次，然後炸：

```
PG::DuplicateTable: ERROR:  relation "xxx" already exists
```

修法不是砍表重跑（會弄丟複製下來的正式資料），是**補記錄**。

## 步驟

### 1. 列出所有 down 的 migration

```bash
bin/rails db:migrate:status 2>/dev/null | grep down
```

### 2. 確認每一筆「真的已經生效」

**這步不能跳過。** down 不代表已生效 —— 也可能是真的還沒跑的新 migration。
逐筆讀 migration 檔案，看它建什麼、改什麼，然後去 DB 驗：

```bash
bin/rails runner '
  # 建表的 → 表在不在，有沒有資料
  %w[table_a table_b].each { |t| puts "#{t}: #{ActiveRecord::Base.connection.table_exists?(t)}" }
  # 加欄位的 → 欄位在不在
  puts ActiveRecord::Base.connection.column_exists?(:table_a, :some_column)
  # seed 類的 → 資料筆數對不對
  puts ActiveRecord::Base.connection.select_value("select count(*) from table_a")
' 2>&1 | tail -10
```

判斷標準：

| migration 類型 | 已生效的證據 |
|---|---|
| create_table | 表存在 |
| add_column / add_index | 欄位 / index 存在 |
| seed 資料 | 表裡有對應筆數的資料 |
| 一次性 patch（改某筆資料） | 去查那筆資料，看是不是已經是改後的值 |

**只確認到一部分？** 只補確認過的那幾筆，其餘照常跑 `db:migrate`。

### 3. 補 schema_migrations 記錄

```bash
bin/rails runner '
  %w[20260628143859 20260628164215].each do |v|
    ActiveRecord::Base.connection.execute("insert into schema_migrations (version) values (#{v}) on conflict do nothing")
  end
  puts "done"
'
```

### 4. 驗證

```bash
bin/rails db:migrate 2>&1 | tail -20
bin/rails db:migrate:status 2>/dev/null | grep -c down   # 剩下的 down 數量
```

跑完 `db/schema.rb` 可能會變動（`define(version: ...)` 跟著最新版本號走）——
提醒使用者要不要 commit，不要自己決定。`db/structure.sql` 也會被
`lib/tasks/schema_dump.rake` 重新 dump，但它會刪掉 schema_migrations 的 INSERT，
補版本號本身不會讓它變。

## 不要做的事

- **不要 `db:migrate:reset` / `db:schema:load`** —— 會清掉從正式站複製下來的資料，
  那正是使用者要的東西。
- **不要沒驗證就整批補記錄** —— 混在裡面的新 migration 會被永久跳過，schema 從此不一致。
- **不要手改 migration 檔案加 `if table_exists?`** —— 那是改 repo 遷就本機狀態，
  正式站不需要這個判斷。

## 一次性 patch migration 要留意

這個 repo 有不少 patch 類 migration（`Patch r01005146 jul2026 gpm charge`、
`Sg jpro42900s revert cc 4235` 之類）。它們改的是特定資料，不是 schema。
複製正式站 DB 時這些改動**通常已經包含在資料裡**，但要真的去查那筆資料確認，
不能靠猜。查不出來就別跳過，讓它跑 —— 多數 patch migration 重跑會是 no-op
或直接報錯，都比跳過安全。
