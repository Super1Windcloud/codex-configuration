# Codex CLI Configuration

⚡ 面向极速开发、全场景感知与工程规范的 **OpenAI Codex CLI** 生产级全套配置套件。

---

## ✨ 核心优化与架构特性

### 1. 终端标题与状态栏全方位升级
- **终端标题（`terminal_title`）自适应**：
  采用 `["project-name", "git-branch", "run-state", "thread-title"]` 排版策略，彻底解决多 Tab / 分屏下（15~25 字符）被冗长路径塞满导致截断的问题，一眼即辨仓库与任务。
- **状态栏（`status_line`）双维度 Token 与进度透视**：
  不仅展示剩余百分比（`context-remaining`），更补齐绝对消耗量（`used-tokens`）与 Agent 任务步骤感知（`task-progress`），去除静态占位的冗余项。

### 2. 严格模式（`--strict-config`）零警告零废弃
- 全面清洗了在 `codex-cli 0.160.0` 中已废弃的 8 个历史死配置（WSL 标记、旧版内存缓存参数、无效网络字段等），保证配置 100% 结构化合法。

### 3. 全局 Agent 开发契约（`AGENTS.md`）
- 确立跨项目通用的行为防线：
  - 严禁裸 `cd` 命令；
  - 严格遵守 Conventional Commits 并输出结构化提交信息；
  - 保持目标工程编码风格一致性与增量构建友好性；
  - 交付前提供最小可验证证据。

### 4. 上下文极简与工程纯净度（Context Hygiene）
- **剔除办公文档插件污染**：默认关闭 `documents`、`presentations`、`spreadsheets`、`template-creator` 等非核心办公插件，每次交互**节省约 25KB 系统提示词与工具描述**，极大减少首字延迟并消除对核心代码逻辑的注意力干扰。
- **全栈原生工具链与运行时**：
  - 开启内置 `features.js_repl = true`，无需唤起外部 Node 进程即可极速运算 JS/JSON/正则；
  - 规则库（`default.rules`）原生覆盖 `bun`、`node`、`rustup`、`rustc`、`adb`、`sqlite3`，开箱即用。

### 5. 零侵入多模型分层架构（Profiles）
告别每次手动改动 `config.toml` 注释切换模型：
- 默认主干：`gpt-6-astra` (Reasoning: Medium)
- 高难架构与疑难调试（强推理）：`codex -p deep` (Reasoning: High, Priority Tier)
- 专业代码自查与门禁：`codex -p review` (gpt-5.5)
- 快速切换轻量模型：`codex -p fast`
- 快速切换 Grok：`codex -p grok`
- 快速切换 Gemini：`codex -p gemini`

### 6. 高频规则池收敛（`rules/default.rules`）
- 清理历史会话遗留的长篇一次性硬编码规则，收敛为通用的构建工具（`gradlew`、`cargo`、`brew`、`bun`、`node`、`adb`）、容器（`docker`、`podman`）与版本控制（`git`）前缀匹配。

---

## 🚀 一键安装

```bash
git clone git@github.com:Super1Windcloud/codex-configuration.git
cd codex-configuration
./install.sh
```

安装脚本将自动执行以下操作：
1. 自动备份现存的 `config.toml`、`AGENTS.md` 与 `default.rules` 为 `.bak`；
2. 部署优化版全局配置、Agent 指令集、Profile 分层包与执行规则；
3. 执行 `codex --strict-config` 自动化验收。

---

## 🛠️ 文件目录结构

```text
.
├── LICENSE                     # MIT 开源许可证
├── README.md                   # 详细使用与架构说明
├── install.sh                  # 一键部署与无缝升级脚本
├── .env.example                # 环境变量配置模板
├── config.toml                 # 核心主配置（已脱敏 API Token）
├── AGENTS.md                   # 全局 Agent 行为规范与全栈工程交付契约
├── profiles/                   # 模型分层 Profiles
│   ├── deep.config.toml        # 高推理重构与架构配置 (Reasoning: High)
│   ├── review.config.toml      # 代码质量门禁审计配置 (gpt-5.5)
│   ├── fast.config.toml        # 轻量极速模型配置 (gpt-5.5)
│   ├── gemini.config.toml      # Gemini 3.8 Flash 配置
│   └── grok.config.toml        # Grok 4.7 配置
└── rules/                      # 命令执行权限规则
    └── default.rules           # 精简收敛的通用规则白名单
```

---

## 💡 推荐 Zsh 终端集成

将以下别名添加到你的 `~/.zshrc` 中以获得丝滑交互体验：

```zsh
# 启用 Codex 官方 Zsh 自动补全
if command -v codex >/dev/null 2>&1; then
  eval "$(codex completion zsh)"
fi

# 常用高频别名
alias cx="codex"
alias cxr="codex resume --last"     # 一秒接续上次工作上下文
alias cxd="codex -p deep"           # 启动高推理深度模型（架构重构/死锁并发排查）
alias cxv="codex -p review"         # 启动代码审计评审
alias cxg="codex -p grok"           # 启动 Grok 模型
alias cxm="codex -p gemini"         # 启动 Gemini 模型
alias cxf="codex -p fast"           # 启动轻量快速模型
alias cxe="codex exec"              # 快速非交互运行
```

---

## 📄 License

[MIT](LICENSE) © SuperWindcloud
