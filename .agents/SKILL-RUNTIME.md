# Skills 运行环境

## 使用

项目使用隔离环境，不修改全局Python或系统软件包。执行技能的Python、R和Mermaid辅助程序前，在同一条Bash命令中运行：

```bash
cd /workspace/lunwen
source scripts/skill-runtime/activate.sh
```

Python位于`/workspace/.venvs/lunwen-skills/bin/python`。R和Mermaid的命令入口位于`/workspace/.tooling/lunwen-skills/bin/`。默认系统Python仍可能显示旧版lxml和缺少某些包，这不表示本项目隔离环境缺少它们。

重新安装或刷新：

```bash
bash /workspace/lunwen/scripts/skill-runtime/setup.sh
```

Python按含SHA-256的`requirements.lock`安装；npm使用提交的package-lock和完整性校验。R从签名验证的Debian 13仓库下载到隔离APT状态目录，以download-only方式提取到工作区；配置脚本仅作本地路径迁移。没有禁用TLS、签名或校验和检查，也没有全局降级lxml。

## 已验证

- 所有28条上游Python requirements条目满足约束；此前缺少的requests、toml、pybliometrics、defusedxml、openai、latex2mathml、mammoth均已安装，隔离环境lxml为5.4.0。
- Image2PPT官方doctor返回ok=true。
- DOCX转HTML、LaTeX转MathML实际转换成功。
- R 4.5.0可执行脚本，基础数学与SVG绘图成功。
- Mermaid CLI 11.4.0实际生成SVG和PNG。托管Chromium禁止file://页面，因此适配器仅将已安装Mermaid依赖目录以本机HTTP提供给浏览器；不向外暴露项目文件。
- 学术检索MCP真实stdio握手成功，列出16个工具，并通过实际工具调用验证无效输入处理。
- 学术检索上游已有的4个测试文件共10项测试通过；未以零测试运行作为通过证据。
- 安装脚本在当前准备好的环境中重复运行成功，复用已有效的包与运行时。

当前状态详见`SKILL-RUNTIME-STATUS.json`。检查不等于所有业务端到端功能都已验证，尤其不包括订阅API、OCR文字识别、图像API和真实论文结论。

## MCP配置与当前聊天的区别

`.codex/config.toml`提供项目级academic-search MCP配置。Codex只在项目被信任时加载项目配置；单纯写入文件不能证明当前聊天挂载了工具。

本地CLI可以使用进程级显式配置启动器，复用已有认证，不复制任何密钥：

```bash
bash scripts/skill-runtime/codex-with-skills.sh mcp list --json
bash scripts/skill-runtime/codex-with-skills.sh
```

原生`mcp list`已返回academic-search、enabled=true及真实启动命令。启动器不改变全局信任设置。MCP进程由客户端按需启动，不依赖上一次会话留下的后台进程。当前云端聊天的工具列表不会因配置文件写入而被视为已热加载。

运行适配器还移除了上游Crossref默认发送的示例联系邮箱，不编造用户邮箱。实际邮箱通过环境变量提供，不进入Git。

## 仍需外部条件

- 当前对Crossref、NCBI E-utilities和arXiv的实际HTTPS请求均被网络代理以403拒绝，尚不能声称联网检索成功。
- 已保存所需网络域名和PUBMED_EMAIL环境变量要求；环境设置的审阅、保存与发布由平台用户完成。保存配置草稿不会自动应用或发布运行环境。
- PUBMED_EMAIL尚待用户提供；未设置虚假邮箱。PubMed源码支持不带邮箱参数的请求，但当前网络阻断仍存在。
- Elsevier/Scopus订阅授权、PaddleOCR令牌和第三方图像API等私人凭据未配置；不得捏造。内置图像工具可用时按Image2PPT说明优先使用，不要求为此额外申请图像API密钥。
- 未配置PaddleOCR时，builtin-ink只测量文本几何，不识别文字；不能据doctor通过宣称OCR可用。
- R的基础运行时已验证；并未安装或测试所有可选R扩展包。

在work分支新建会话或发布当前准备好的环境后，先读取根目录AGENTS.md。每个任务使用现有隔离检出，除非用户要求，不创建Git worktree。
