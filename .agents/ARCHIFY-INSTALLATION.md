# Archify 项目安装

- 来源：https://github.com/tt-a1i/archify.git
- 上游提交：`25cf37080fc8b1dbe758a4efc3935b55f3327083`。
- 版本：`3.2.0`；技能名：`archify`；调用：`$archify` 加任务描述。
- 安装位置：`.agents/skills/archify/`，203个文件完整复制，SHA-256与上游一致。
- 功能：生成可交互的架构图、流程图、时序图、数据流图、状态图、ERD、类图、树图、时间线、瀑布图及单页说明HTML。
- 使用示例：`使用 $archify 把煤矿智能监控的人机协同流程画成可交互流程图。`

## 保留范围

所有现有24个技能保持不变。上游`.agents/skills/`中的`archify-review`、`archify-tuning`、`simplify-codebase`、`test-value`是上游维护开发辅助包，本次按其公开安装边界只安装主包`archify/`。MIT许可证及第三方许可文件已随包保留。未编辑上游SKILL.md、元数据或运行代码，也未全局安装或创建自动更新任务。

## 元数据与依赖

`name: archify`和740字符的description通过格式检查。上游未提供`agents/openai.yaml`；该文件对Codex技能发现是可选项，本次原生发现成功无需补造。运行要求为Node.js >=18，当前版本为`v24.19.0`；生成后的验证器与渲染器已自带，不需要为基本运行安装开发依赖。package.json中的部分开发/测试命令引用原仓库的上级scripts，它们不是发布技能的运行入口。

## 验证证据

新建本地Codex app-server进程，在仓库cwd运行`skills/list`并设置`forceReload=true`。`archify`返回`scope: repo`、`enabled: true`及正确SKILL.md路径，errors为空。检测进程使用隔离的可写CODEX_HOME，没有重启既有daemon，也没有运行模型任务。

在实际安装位置执行了以下检查，均退出0：

```sh
node .agents/skills/archify/bin/archify.mjs doctor
node .agents/skills/archify/bin/archify.mjs demo /workspace/skill-verification/archify-demo
```

示例HTML已实际渲染，HTML/SVG内容存在。未进行真实浏览器交互、完整finalize交付门槛或视觉审查，不据此声称它们已通过。文件哈希和发现回执见`ARCHIFY-VERIFICATION.json`。

## 会话与分支

安装提交在`work`分支。建议在该分支新建Codex会话后使用`$archify`；当前聊天热加载未验证。尚未合并的`main`分支不会自动包含本次安装。
