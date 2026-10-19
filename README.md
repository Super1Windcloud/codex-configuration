# Harness 配置同步与 Testkit 安装

统一管理 Codex、Claude Code、OpenCode 的全局指令与配置；技能安装范围仅为 [Testkit](https://github.com/winhok/testkit)。

## 使用

需要 Python 3.11+、Git、对应工具的 CLI；OpenCode 依赖安装需要 npm。

```bash
# 同步配置与 Testkit 安装来源到仓库
~/super/codex-configuration/sync.sh

# 预览安装计划
~/super/codex-configuration/install.sh --dry-run

# 自动部署配置并安装 Testkit
~/super/codex-configuration/install.sh

# 只安装 Codex 对应配置与 Testkit
~/super/codex-configuration/install.sh --only codex

# 离线部署配置；报告尚未安装的 Testkit 和依赖
~/super/codex-configuration/install.sh --offline
```

配置继续采用原有布局：Codex 位于根目录，Claude Code 和 OpenCode 位于 `harness/claude/`、`harness/opencode/`。`.harness.json` 指定默认范围；`--home /path/to/home` 可指定导出或部署的用户目录。

## Testkit 范围

- `plugins.json` 仅保留 Testkit 插件标识和技能来源。
- Codex、OpenCode 从清单指定的 Testkit Git commit 拉取 `skills/`，部署为各自原生目录中的 `skills/<name>/SKILL.md`。
- Claude Code 使用 `claude plugin install testkit@testkit`，恢复插件附带的 skills。
- 插件安装只处理 Testkit；旧清单中其他插件也不会被安装。对应市场插件版本由市场决定。
- GitHub 不保存本机 skills 副本，包括 `.system`、figma-to-compose、find-skills、rongcloud-im、screenshot-to-html 及其素材。`sync.sh` 跳过所有本机 skills 目录，`.gitignore` 同时阻止重新入库。
- 本机已有的其他 skills 保留；安装脚本只部署 Testkit，不卸载其他用户资源。

## 配置保护

覆盖前备份到 `~/.harness-backups/<时间>/`。JSON 配置合并保留本机凭据，Codex 保留本机项目 trust 和运行时 marketplace 表；目标路径含软链接时拒绝覆盖。

按文件白名单导出模型、MCP、全局指令、状态栏、hooks 等配置，不导出登录状态、会话、日志、数据库、node_modules 和插件缓存。常见凭据字段会被过滤，仍需在提交前检查自定义配置。MCP 所需的 SDK、工具和客户端运行时由目标机器准备。

## 验证

```bash
python3 -B -m unittest discover -s ~/super/codex-configuration/tests -v
bash -n ~/super/codex-configuration/install.sh ~/super/codex-configuration/sync.sh
```

用例覆盖仅 Testkit 来源、排除其他 skills、旧清单安装过滤、原生 Testkit 部署、备份脱敏、预览无副作用和配置保护。

[MIT License](LICENSE)
