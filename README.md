# Harness 配置同步与运行环境安装

## Testkit 完整依赖与 Figma 安装

本仓库可独立部署 Codex / Claude Code / OpenCode。默认一并安装 Testkit 完整 skills、Python/移动端/浏览器/性能/视频/逆向工具依赖，并同步 Figma 插件安装来源。需要 Python 3.11+、Git；macOS 系统包通过已有 Homebrew 补齐。full 需要 Node 24+、npm 10+，缺少时尝试由 Homebrew 准备。

```bash
~/super/codex-configuration/sync.sh
~/super/codex-configuration/install.sh --dry-run
~/super/codex-configuration/install.sh
~/super/codex-configuration/install.sh --dependencies core
~/super/codex-configuration/install.sh --offline
```

- 普通安装默认 `--dependencies full`；core 仅准备核心 Python 和 mobile-mcp；none 跳过运行环境/MCP 构建。
- 默认安装并登记 mobile-mcp，full 另含 Playwright MCP；使用 SDK 和独立运行目录的实际路径，不只复制 JSON。
- 插件安装允许列表为 Testkit、Figma；其他本机 skills 不同步到 GitHub，也不卸载。插件缓存、依赖缓存和登录凭据不入库。
- 运行环境位于 `~/.local/share/harness-testkit/`；全局指令会补充 `source .../env.sh` 的使用约定。
- 覆盖前备份；保留原有设置、凭据与其他 MCP。`--dry-run` 无写入和下载；`--offline` 不联网安装，只部署配置并报告待安装项。
- Xcode、设备信任、SDK 许可、WDA 签名、Midscene 模型凭据和 Figma OAuth 仍需本机准备，安装失败会返回非零状态。

详见 [完整依赖与 MCP 配置](runtime/README.md)、[实际验证范围](VALIDATION.md)。验证命令：`python3 -B -m unittest discover -s ~/super/codex-configuration/tests -v`。

配置保持原有布局：Codex 位于根目录，其他工程位于 `harness/`；`.harness.json` 声明默认同步范围。`--home /path/to/home` 可指定目标用户目录。

[MIT License](LICENSE)
