# Harness 配置同步与运行环境安装

安装与同步仅操作 `~/.codex/`，不读写其他 agent 或 `~/.agents/` 的配置。`--only` 仅接受本仓库所属 agent，跨 agent 参数会在执行前报错；`--repo` 不会扩大范围。 Testkit 运行环境独立存放于 `~/.local/share/harness-testkit/codex/`；系统工具仍复用本机安装。

## Testkit 完整依赖与 Figma 安装

本仓库仅部署 Codex。默认一并安装 Testkit 完整 skills、Python/移动端/浏览器/性能/视频/逆向工具依赖，并同步 Figma 插件安装来源。需要 Python 3.11+、Git；macOS 系统包通过已有 Homebrew 补齐。full 需要 Node 24+、npm 10+，缺少时尝试由 Homebrew 准备。

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
- 运行环境位于 `~/.local/share/harness-testkit/codex/`；全局指令会补充 `source .../env.sh` 的使用约定。
- 覆盖前备份；保留原有设置、凭据与其他 MCP。`--dry-run` 无写入和下载；`--offline` 不联网安装，只部署配置并报告待安装项。
- Xcode、设备信任、SDK 许可、WDA 签名、Midscene 模型凭据和 Figma OAuth 仍需本机准备，安装失败会返回非零状态。

详见 [完整依赖与 MCP 配置](runtime/README.md)、[实际验证范围](VALIDATION.md)。验证命令：`python3 -B -m unittest discover -s ~/super/codex-configuration/tests -v`。

Codex 配置位于根目录；`harness/` 中的历史跨 agent 配置不参与安装或同步。`.harness.json` 记录本仓库范围。`--home /path/to/home` 可指定目标用户目录。

[MIT License](LICENSE)

Codex 插件同步只读取 config.toml 的显式声明，并保留禁用标志；缓存目录不会作为安装来源。插件清单仅导出本仓库负责的 Codex 范围。


## mitmproxy MCP

默认安装会增量接入 [snapspecter/mitmproxy-mcp](https://github.com/snapspecter/mitmproxy-mcp)。需要已安装 `uv`（提供 `uvx`）；使用 Python 3.13、固定 PyPI 版本 `0.6.1`，额外约束 `mcp<2`，避免该版本误装不兼容的 MCP SDK 2.x。首次运行由 uv 准备 Python 和依赖，后续复用 uv 缓存。

仅接入此 MCP（不重装其他工具或插件）：

```sh
python3 ~/super/codex-configuration/scripts/mitmproxy_setup.py --dry-run
python3 ~/super/codex-configuration/scripts/mitmproxy_setup.py
```

脚本仅修改本仓库所属客户端的一条 MCP 配置；覆盖前保存到 `~/.harness-backups/mitmproxy-*`，保留其他 MCP、凭据与项目设置，拒绝向软链接目标写入。`--offline` 只写配置、不下载或验证依赖；`--dry-run` 不写入、不下载。完整安装的 `--dependencies none` 跳过此步骤。

抓包数据库位于 `~/.local/share/harness-mitmproxy/<agent>/`（私有目录），不写入工作项目或 GitHub。启动 MCP 不会自动启动代理；需要抓包时调用 `set_scope`、`start_proxy`（默认 `127.0.0.1:8080`），完成后调用 `stop_proxy`。多个 agent 同时抓包应使用不同端口；应用代理、HTTPS 证书信任按目标设备配置。本次接入不更改系统代理或证书信任。客户端重启或新会话后加载新 MCP。
