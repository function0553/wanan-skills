# Wanan Skills

面向小白的 AI 编程 Skills 套件，包含 Wanan V2.0、V2.1 与 V2.1 特供版，覆盖开发、验收与项目经验沉淀流程。强制学习、阶段考核、`经验学习.md`、历史模块补考和综合学习评分仅由 V2.1 特供版提供。

> 最新发布（2026-08-11）：V2.1 与 V2.1 特供版已升级执行节奏和受影响定向验收规则，发布 ZIP 已同步更新。

## 版本

| 版本 | 目录 | 说明 |
|---|---|---|
| V2.0 | `versions/v2.0/` | V2 系列基础版本，保留完整的基础 Skills 工作流，不包含学习与考核模块。 |
| V2.1 | `versions/v2.1/` | 当前最新版；采用完成即验收、立即提交合并和受影响定向测试，不包含学习与考核模块。 |
| V2.1 特供版 | `versions/v2.1-special/` | 当前学习增强版；包含 V2.1 最新执行节奏，并完整保留强制学习、阶段考核、`经验学习.md`、历史模块补考和综合学习评分。 |

## V2.1 最新更新

V2.1 与 V2.1 特供版现在共同采用以下执行规则：

- 两次上下文压缩只是未完成分支的防腐上限，不是必须等待的合并门槛。
- 功能完成后立即运行受影响范围的定向验收；通过后立即提交、合并并开启下一开发分支。
- 分支提交前只运行本次变更直接相关的单元测试、契约测试和验收测试。
- 不默认运行全库测试、全量回归或无关模块测试，也不在多个阶段重复同一批大范围检查。
- 不再为了等待上下文压缩而扩大安全审查、额外审计或回归范围。

V2.1 特供版同时完整保留强制学习轨道、聊天框完整教学、英文技术名词中文解释、`K1/K2/K3` 知识点编号、每模块 10 道混合选择题、历史模块补考、`REASSESSMENT_REQUIRED` 重新考核以及基于历史模块成绩的最终综合评分。

## 原始压缩包

`packages/` 目录保留三个版本的原始 ZIP，方便直接下载、备份和版本对比：

- `wanan-v2.0.zip`
- `wanan-v2.1.zip`
- `wanan-v2.1-special.zip`

## 核心目标

V2.0 与 V2.1 的核心目标是让 AI 编程过程在完成代码开发的同时，落实：

- 开发流程约束与质量检查
- 项目验收与问题复盘
- Harness、交接与 Git 检查点
- 专用工具预检与前端方向确认

V2.1 特供版在上述流程基础上独占新增：

- 强制学习
- 阶段考核
- 项目根目录 `经验学习.md`
- 历史模块补考
- 综合学习评分

## 使用建议

优先从最新的 `V2.1 特供版` 开始使用；如需查看功能演进，可对比 V2.0 与 V2.1 目录。

## 参与项目

欢迎参与 Wanan Skills 的持续改进：

- [提交 Issue](https://github.com/function0553/wanan-skills/issues/new) 反馈问题或提出建议。
- [提交 Pull Request](https://github.com/function0553/wanan-skills/pulls) 贡献改进。
- [申请成为项目维护者](https://github.com/function0553/wanan-skills/issues/new?template=maintainer_application.yml) 参与长期维护。
- 提交前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 仓库结构

```text
wanan-skills/
├─ README.md
├─ versions/
│  ├─ v2.0/
│  ├─ v2.1/
│  └─ v2.1-special/
└─ packages/
   ├─ wanan-v2.0.zip
   ├─ wanan-v2.1.zip
   └─ wanan-v2.1-special.zip
```
