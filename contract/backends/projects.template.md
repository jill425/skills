# Task 後端登記表

哪個專案的 task 記在哪。**這份表只存在本機**（`~/.claude/task-backends/projects.md`，不存在時由執行角色從本範本建立）——後端是個人工具設定，不進任何專案的版控，隊友不會、也不需要看到它。

比對鍵優先用 `git remote get-url origin`；沒有 remote 的專案用本機絕對路徑。

| 專案（remote 或路徑） | 後端 | task 位置 | 備註 |
|---|---|---|---|

- **後端**：`github-issues`、`gitlab-issues` 或 `local-files`。
- **task 位置**：issue 所在的 repo（GitHub 填 `owner/repo`，GitLab 填 `group/project`）；跟 code 同一個 repo 時可留空。`local-files` 留空。

**未登記的專案**：不要猜，問使用者 task 單放在哪——GitHub repo、GitLab repo，還是本機 `tasks/`；放在 repo 的，再問是哪個 repo。依答案補一列再開工。

**`tasks/` 存在不代表它是活的後端**——專案可能從本機檔改用 issue，舊資料夾就成了凍結的紀錄。以登記表為準，不把凍結的檔案當成待辦去改。
