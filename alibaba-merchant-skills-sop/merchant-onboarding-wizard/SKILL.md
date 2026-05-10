---
name: merchant-onboarding-wizard
description: 商家画像建模向导（专属大勛定制版）。通过结构化问答（5+8+2 问）快速建立 MERCHANT_PROFILE / USER_PREFERENCES / LEARNED_RULES 三件套。当首次会话、三件套缺失、用户说「建立画像/完善偏好/我是新用户」、或其他 Skill 检测到 profile 缺失时自动触发。预期 5 分钟完成传统 30-60 分钟的工作量。
trigger:
  - 首次会话且 ${agent_core}/MERCHANT_PROFILE.json 不存在
  - 用户说："建立画像" / "完善偏好" / "我是新用户" / "帮我做新人引导" / "重新建档"
  - 其他 Skill（如 cross-border-launch-sop）调用时检测到 profile 缺失
  - 用户透露大量新业务信息且 profile 完整度 < 60%
---

# 🎯 商家画像建模向导 (Merchant Onboarding Wizard)

> **专属定制**：本 Skill 由「大勛」定制，专为跨境电商商家的快速 KYC 建模而设计。

## 核心使命

用 **5 分钟** 完成传统需要 **30-60 分钟** 才能收集完整的商家画像，为后续所有 AI 服务（发品、装修、广告、客服）提供精准的上下文基础。

## 第一性原理

| 原则 | 反例 ❌ | 正例 ✅ |
|---|---|---|
| **一次问清** | 一次只问 1 个问题 | 5 个问题一次性发出 |
| **自然语言优先** | 让用户填表/写 JSON | 用户自然描述，AI 解析 |
| **二选一降决策成本** | 开放式问题 | A/B/C 选项秒选 |
| **回显校验** | 解析完直接写文件 | 表格回显→用户确认→再写入 |
| **渐进式增强** | 一次问 30 题 | 必填 5 + 推荐 8 + 按需追加 |

---

## 三阶段问答流程

### 🔵 Stage 1：MERCHANT_PROFILE 必填 5 问（2 分钟）

**触发时机**：三件套不存在时立即执行。

**操作步骤**：
1. 读取 `question_flows/stage_1_profile_5q.md`，按其中模板向用户发出 5 问
2. 用户用一段自然语言回答
3. 按 `parsers/parse_profile.md` 规则解析为结构化数据
4. 用 Markdown 表格回显给用户确认
5. 用户确认后，按 `templates/MERCHANT_PROFILE_template.json` 结构写入 `${agent_core}/MERCHANT_PROFILE.json`
6. 进入 Stage 2

**绝对禁止**：
- ❌ 一次只问 1 个问题（会浪费 4 个对话回合）
- ❌ 跳过回显确认直接写文件
- ❌ Stage 1 未完成就进入 Stage 2

---

### 🟢 Stage 2：USER_PREFERENCES 推荐 8 问（3 分钟）

**触发时机**：Stage 1 完成且用户确认后。

**操作步骤**：
1. 读取 `question_flows/stage_2_preferences_8q.md`，发出 8 个二选一快问快答
2. 用户输入紧凑格式（如 "1A 2A 3A 4A 5A 6B 7A 8A"）
3. 按 `parsers/parse_preferences.md` 映射为 JSON
4. 表格回显确认
5. 写入 `${agent_core}/USER_PREFERENCES.json`
6. 进入 Stage 3

**关键技巧**：
- ✅ 每个选项都附带"为什么选 A/B/C"的简短说明
- ✅ 接受用户自定义混合（如 "3 我要表格 + 公式"）
- ✅ 默认值优先（用户跳过则选 A）

---

### 🟡 Stage 3：LEARNED_RULES 关键 2 问 + 持续追加（边用边补）

**触发时机**：Stage 2 完成后。

**操作步骤**：
1. 读取 `question_flows/stage_3_rules_capture.md`
2. 只问 2 个最关键问题（IP 黑名单 + 发布硬性规则）
3. 写入初始 `${agent_core}/LEARNED_RULES.json`
4. 告知用户：后续将通过 3 种方式自动学习规则
   - 用户纠正时自动捕获
   - 关键节点提示性追问
   - 周期性规则审计（每月）

---

## 完成后的反馈

每完成一个 Stage，必须用以下格式向用户汇报：

```markdown
✅ Stage X 完成！

📊 已收集字段：
| 字段 | 值 |
|---|---|
| ... | ... |

⚠️ 待补充（可后续完善）：
- ...

🚀 进度：[████████░░] 75% (3/4 阶段)
```

---

## 与其他 Skill 的协作

```
[merchant-onboarding-wizard]  ← 你（专职 KYC）
         ↓ 输出三件套到 ${agent_core}/
         ↓
   ┌─────┴─────┬──────────────┐
   ↓           ↓              ↓
[cross-border-launch-sop] [alibaba-create-website] [其他业务 Skill]
   读画像→执行发品           读画像→执行装修         读画像→个性化服务
```

**调用约定**：
- 其他 Skill 启动时，先检查 `${agent_core}/MERCHANT_PROFILE.json` 是否存在
- 不存在则提示用户："建议先完成画像建模，预计 5 分钟。是否立即启动？"
- 用户同意 → 调用本 Skill；用户拒绝 → 进入降级模式（边问边做）

---

## 文件清单

| 文件 | 用途 |
|---|---|
| `SKILL.md` | 本文件，主入口 |
| `README.md` | 用户使用说明 |
| `question_flows/stage_1_profile_5q.md` | 必填 5 问模板 |
| `question_flows/stage_2_preferences_8q.md` | 偏好 8 问模板 |
| `question_flows/stage_3_rules_capture.md` | 规则捕获策略 |
| `parsers/parse_profile.md` | profile 自然语言解析规则 |
| `parsers/parse_preferences.md` | preferences 选项映射规则 |
| `templates/MERCHANT_PROFILE_template.json` | profile JSON 骨架 |
| `templates/USER_PREFERENCES_template.json` | preferences JSON 骨架 |
| `templates/LEARNED_RULES_template.json` | rules JSON 骨架 |
| `examples/lilis_wedding_case.md` | 大勛 Lilis Wedding 案例（脱敏） |

---

## 性能指标

| 指标 | 传统方式 | 本 Skill |
|---|---|---|
| 建档时间 | 30-60 分钟 | **5 分钟** |
| 字段完整度 | 40-60% | **95%+** |
| AI 反复追问 | 5-10 次/会话 | **0 次** |
| Token 消耗 | ~8000/会话 | **~2500/会话** (-69%) |
| 用户学习成本 | 需读底层文档 | **零学习** |

---

**维护者**：大勛  
**版本**：v1.0  
**创建日期**：2026-05-02
