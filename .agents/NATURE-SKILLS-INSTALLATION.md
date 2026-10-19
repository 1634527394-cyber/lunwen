# Nature Skills 项目安装记录

## 来源与安装范围

- 来源：https://github.com/Yuan1z0825/nature-skills.git
- 上游固定提交：`233ed09957d32d8cf45dd96c495663c5c5d8e447`。
- 项目安装目录：`.agents/skills/`；23个包、22个可独立调用工作流、1个共享支持包，共794个源文件。
- 每个包完整复制，未编辑SKILL.md、agents、manifest、scripts、references或assets；所有源文件SHA-256与上游一致。
- 现有`research-paper-writing`的全部文件哈希保持不变；未发现同名技能或目标目录冲突。
- 上游Apache-2.0许可证保存在`.agents/NATURE-SKILLS-LICENSE.txt`，包内第三方许可和署名文件随包保留。

## 技能与调用

在仓库工作目录下使用 `$技能名` 加任务描述。

| 技能名 | 功能 | 调用 |
|---|---|---|
| `nature-academic-search` | 多来源文献检索、引文核对与文献管理 | `$nature-academic-search` |
| `nature-citation` | Nature/CNS文献支撑、主张与来源映射、书目导出 | `$nature-citation` |
| `nature-data` | 数据/代码可用性声明、共享方案与FAIR元数据 | `$nature-data` |
| `nature-downloader` | 通过开放获取或已有授权获取论文全文及补充材料 | `$nature-downloader` |
| `nature-experiment-log` | 将实验文字、图片或语音整理为结构化实验日志 | `$nature-experiment-log` |
| `nature-figure` | Python/R科研绘图、多面板图、图件审计与导出 | `$nature-figure` |
| `nature-image2ppt` | 将图片、截图或扫描页面重建为可编辑PPT | `$nature-image2ppt` |
| `nature-literature-pipeline` | 文献发现、评分、精读、摘要推送与归档流程 | `$nature-literature-pipeline` |
| `nature-paper-card` | 论文精读卡、方法拆解与证据链分析 | `$nature-paper-card` |
| `nature-paper-to-patent` | 论文或发明材料转中文专利草稿及技术交底书 | `$nature-paper-to-patent` |
| `nature-paper-trans` | 将英文论文PDF翻译为保留版式的中文图片型PDF | `$nature-paper-trans` |
| `nature-paper-xray` | 深入拆解单篇论文的研究路径、方法、公式与证据边界 | `$nature-paper-xray` |
| `nature-paper2ppt` | 从论文或阅读笔记生成中文学术汇报PPT | `$nature-paper2ppt` |
| `nature-polishing` | 学术润色、翻译、压缩与LaTeX排版调整 | `$nature-polishing` |
| `researchwrite` | 研究计划、开题报告与项目申请书撰写和审查 | `$researchwrite` |
| `nature-reader` | 生成中英对照论文阅读材料及来源关联问答 | `$nature-reader` |
| `nature-ref-verifier` | 逐条交叉核对参考文献元数据并生成报告 | `$nature-ref-verifier` |
| `nature-response` | 审稿意见逐点回复、返修信与修订材料整理 | `$nature-response` |
| `nature-reviewer` | 基于证据的模拟同行评审和投稿前自审 | `$nature-reviewer` |
| `nature-shared` | 共享参考资料、期刊格式与一致性规则支持包 | 由其他Nature技能按需读取；不作独立工作流 |
| `nature-social-science` | 社会科学选题、文献梳理、论证组织与学术表达 | `$nature-social-science` |
| `nature-statistics` | 统计方法、重复、误差、不确定性和图注统计审查 | `$nature-statistics` |
| `nature-writing` | 论文论证、章节结构重建、初稿及首次投稿材料 | `$nature-writing` |

## 名称、路径与共享依赖

- `nature-proposal-writer/`的上游frontmatter名称为`researchwrite`，与manifest和默认提示一致；原生发现也返回`researchwrite`。保留上游目录名称，通过`$researchwrite`调用。
- `nature-shared`保留`policy.allow_implicit_invocation: false`。安装它是为满足兄弟目录对`../nature-shared/`的依赖，不将其宣传为独立用户工作流。
- 所有manifest声明的相对路径已在安装位置重新验证。SKILL中的19处`core/...`为`static/core/...`简写，目标均存在；脚本命令后的参数不被误判为缺失文件。

## 验证结果及范围

- 上游元数据验证：23目录通过；上游仓库布局验证通过。
- 安装后重新检查每份frontmatter、agents元数据、manifest名称及路由路径，无错误。
- 178个Python源文件可语法解析；上游图件示例含无效转义SyntaxWarning，不影响本次语法解析。没有执行所有业务脚本。
- 原生验证：Codex CLI app-server `skills/list`，`forceReload=true`，仓库cwd为`/workspace/lunwen`。23个Nature包全部返回`scope: repo`、`enabled: true`、正确路径，errors为空；现有`research-paper-writing`也仍被发现。
- 此验证使用新建的本地检测进程及独立可写CODEX_HOME，不依赖SKILL文件存在性判断，没有运行模型任务，也没有重启现有daemon。当前聊天的热加载不在本次验证范围。
- 完整文件哈希、运行依赖清单及原生发现回执见`.agents/NATURE-SKILLS-VERIFICATION.json`。

## 尚未配置或验证的运行能力

技能目录安装和发现成功，不代表所有外部服务、辅助程序或输出格式已经可用。本次未安装下列额外依赖、未创建API凭据、未配置MCP服务、未启用定时推送或自动更新，也未联网执行学术检索/OCR/图像服务。

当前Python环境的具体缺项：

- `nature-academic-search` MCP：缺少`requests`、`toml`、`pybliometrics`、`defusedxml`；现有`lxml 6.1.1`不符合上游`>=4.9.0,<6.0.0`约束。
- `nature-image2ppt`：缺少`requests`、`openai`、`defusedxml`；OCR和外部图像服务凭据/兼容性未验证。
- `nature-paper-to-patent`：缺少`latex2mathml`、`mammoth`；Mermaid命令行`mmdc`未找到，CNIPA浏览器及登录配置未验证。
- R后端的`Rscript`未找到；`nature-figure`的Python依赖PyMuPDF符合声明要求，但未执行真实绘图任务。
- 文献自动推送需要用户确定研究主题、渠道与调度方式；安装文件不等于已创建cron或已对外发送消息。
- 即使requirements版本已满足，也没有据此声称业务功能经过端到端测试。各包内requirements及README均完整保留，可在需要时使用隔离虚拟环境安装并验证对应工作流，避免全局降级lxml。

## 会话与Git分支

安装提交在`work`分支。新建Codex会话时请选择该分支并以仓库为工作目录，再显式使用对应`$技能名`。若仍从尚未合并的`main`启动，不应假定包含本次安装。已有聊天可能需要重新创建会话才能更新技能目录。
