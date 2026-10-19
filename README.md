# Codex / Claude Code / OpenCode 配置同步

保留原有 Codex 仓库布局，统一同步三套 harness 的全局指令、配置、agents、skills 和插件来源。现有 Claude Code、OpenCode 仓库保持独立，本仓库不修改它们的 Git 状态，也不自动提交或推送。

需要 Python 3.11+、Git，以及需要安装插件的对应 CLI。OpenCode 本地插件依赖需要 npm。MCP 所依赖的 Android SDK、Homebrew 工具和 ChatGPT 桌面运行时仍需在目标机器准备。

## 同步本机配置到仓库

```bash
~/super/codex-configuration/sync.sh
```

从 `~/.codex`、`~/.claude`、`~/.config/opencode` 和 `~/.agents` 导出；完成后通过 `git diff` 审查，再自行提交。同步采用增量覆盖，不自动删除仓库中已维护的文件；停用资源需要显式从仓库移除。

| 仓库位置 | 同步内容 | 安装位置 |
| --- | --- | --- |
| `AGENTS.md`、`config.toml`、`profiles/`、`rules/`、`skills/`、`agents/` | Codex 全局指令、配置、模型 profiles、规则、用户及系统 skills、自定义 agents | `~/.codex/` |
| `harness/claude/` | `CLAUDE.md`、settings、状态栏、hooks、skills、agents、commands | `~/.claude/` |
| `harness/opencode/` | 全局 `AGENTS.md`（存在时）、配置、依赖锁文件、skills、agents、commands、plugins、tools、themes | `~/.config/opencode/` |
| `harness/shared/` | 全局 `AGENTS.md`（存在时）与共享 skills，包括配套 scripts、references、assets | `~/.agents/` |
| `plugins.json` | Codex / Claude 插件安装标识、来源和 Codex 启用状态；外部 skill 来源 | 通过对应 CLI 安装 |

可用 `sync.sh --home /path/to/home` 从指定用户目录导出。正常 skill 软链接会展开为实际文件，循环或失效链接会中止导出。旧 OpenCode `testkit` 失效链接有明确的上游来源，转为安装来源记录，在安装时恢复成 `skills/<name>/SKILL.md`。

## 自动安装

```bash
# 先预览；不改动本机配置、不联网安装
~/super/codex-configuration/install.sh --dry-run

# 安装全部 harness、共享 skills，并恢复有来源的第三方插件
~/super/codex-configuration/install.sh

# 仅安装 Codex 及共享 skills
~/super/codex-configuration/install.sh --only codex shared

# 离线部署仓库文件；输出尚未安装的插件和外部依赖
~/super/codex-configuration/install.sh --offline
```

新机器可以先克隆本仓库，再以绝对路径运行 `install.sh`。

- 覆盖前备份到 `~/.harness-backups/<时间>/`，保留原目录结构；不清空用户 skills、不删除其他配置文件。
- JSON 配置合并写入，保留本机未入库的凭据；Codex 保留本机项目 trust 与桌面运行时 marketplace 配置。
- 拒绝通过目标软链接覆盖文件，避免写入其他目录。
- 共享 skills 同时部署到所选 Claude Code、OpenCode 的原生 skills 目录；保留 skill 原始资源及测试样例。旧 OpenCode 链接移除后，再次同步仍保留已记录的外部 skill 来源。
- 有 Git 来源的 Codex 插件使用 `codex plugin add`；Claude 插件使用 `claude plugin install`，不会通过伪造 `installed_plugins.json` 冒充安装成功。
- 插件安装后恢复配置中的启用状态，包括已禁用的插件。失败会返回非零退出码，不会报告全部成功。
- OpenCode 外部 Testkit skills 按清单固定的 Git commit 恢复；依赖存在 npm 锁文件时使用 `npm ci`。`opencode.json` 的 npm 插件由 OpenCode 启动时自动安装。[OpenCode 官方说明](https://dev.opencode.ai/docs/plugins/)
- Codex 内置、远程账号或工作区管理的插件记录在清单中，但不搬运运行时缓存或绕过账号授权。没有可移植来源的项目会逐项列出，需要对应客户端或账号恢复；可移植插件使用官方 CLI。[Codex CLI 说明](https://learn.chatgpt.com/docs/cli/reference)

第三方 marketplace 插件恢复的是该市场当前提供的版本；清单不承诺固定所有插件版本。插件提供的 skills 随插件安装恢复，不再作为独立用户 skill 重复复制。Codex `.system` skills 已入库，但仍可能被未来客户端更新覆盖。

`install.sh --home /path/to/home` 可部署到指定用户目录，插件命令会使用对应 `HOME`、`CODEX_HOME`、`CLAUDE_CONFIG_DIR` 与 `XDG_CONFIG_HOME`。脚本不会安装 Codex、Claude Code、OpenCode CLI 本身，也不会启动模型会话或自动重启服务。

## 凭据与本机数据

采用文件白名单，不导出 `auth.json`、`service.json`、会话、日志、数据库、node_modules、插件缓存和 Git 元数据。JSON 配置剔除常见 API key、token、password、Authorization 字段；Codex TOML 剔除凭据字段、含密钥的注释和本机项目 trust。环境变量引用保留，配置及脚本中的用户主目录转为 `~/`，安装时展开。

自定义脚本、skills 和任意字段可能包含不符合常见格式的凭据，仍需审查导出结果。API 凭据由本机环境或客户端登录提供；外部市场认证与受账号管理的插件仍需目标机器具备对应权限。

## 验证

```bash
python3 -B -m unittest discover -s ~/super/codex-configuration/tests -v
bash -n ~/super/codex-configuration/install.sh ~/super/codex-configuration/sync.sh
~/super/codex-configuration/install.sh --dry-run
```

自动化用例覆盖凭据过滤、skill 软链接实体化、预览无副作用、覆盖备份、本机凭据/trust 保留、目标软链接保护、真实插件命令及启用状态恢复、插件失败返回。CLI 行为由模拟命令验证；联网安装应单独报告实际执行结果。

[MIT License](LICENSE)
