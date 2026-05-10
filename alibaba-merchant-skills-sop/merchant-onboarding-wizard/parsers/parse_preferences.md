# Preferences 选项映射规则

## 🎯 任务

将用户的紧凑回答（如 "1A 2B 3A..."）或口语化回答（如 "全选 A"）映射为 `USER_PREFERENCES.json`。

## 📋 8 题选项映射表

### Q1. 思维框架
| 用户输入 | JSON 值 | 行为表现 |
|---|---|---|
| 1A | "first_principles" | 每个分析先拆解到本质 |
| 1B | "swot" | 用 SWOT 框架分析 |
| 1C | "data_driven" | 先看数据再判断 |

### Q2. 回复语言
| 用户输入 | JSON 值 |
|---|---|
| 2A | "zh-CN_with_en_terms" |
| 2B | "zh-CN" |
| 2C | "en-US" |
| 2D | "bilingual" |

### Q3. 输出格式
| 用户输入 | JSON 值 | 优先级 |
|---|---|---|
| 3A | "table_first" | 表格 > 列表 > 段落 |
| 3B | "list_first" | 列表 > 段落 |
| 3C | "narrative" | 段落叙事 |

### Q4. 报告框架
| 用户输入 | JSON 值 |
|---|---|
| 4A | "mckinsey_8_pillars" |
| 4B | "star" |
| 4C | "simple_3_parts" |

### Q5. Next Steps
| 用户输入 | JSON 值 |
|---|---|
| 5A | "always_provide_1_to_3" |
| 5B | "important_tasks_only" |
| 5C | "never" |

### Q6. 数据呈现
| 用户输入 | JSON 值 |
|---|---|
| 6A | "detailed_with_formulas" |
| 6B | "conclusions_with_evidence" |
| 6C | "conclusions_only" |

### Q7. 风险沟通
| 用户输入 | JSON 值 |
|---|---|
| 7A | "direct_alerts" |
| 7B | "gentle_suggestions" |
| 7C | "on_demand_only" |

### Q8. AI 主动性
| 用户输入 | JSON 值 |
|---|---|
| 8A | "high" |
| 8B | "medium" |
| 8C | "low" |

## 🗣 口语化解析规则

| 用户说法 | 解析结果 |
|---|---|
| "全选 A" / "都 A" | Q1-Q8 全选 A |
| "用默认" / "推荐配置" | 默认值（见下方） |
| "全 A，除了 6B" | Q1=A, Q2=A, ..., Q6=B, Q7=A, Q8=A |
| "1A 2A 3A 4A 5A 6B 7A 8A" | 直接映射 |
| "I'd like A for all" | 全选 A |

## ⭐ 大勛默认推荐配置

如果用户回答 "用默认" / "推荐配置"，使用以下组合（这是大勛验证过的最佳值）：

```json
{
  "thinking_framework": "first_principles",
  "response_language": "zh-CN_with_en_terms",
  "output_format": "table_first",
  "report_framework": "mckinsey_8_pillars",
  "next_steps_policy": "always_provide_1_to_3",
  "data_presentation": "conclusions_with_evidence",
  "risk_communication": "direct_alerts",
  "ai_proactivity": "high"
}
```

## 📊 回显确认模板

解析完成后，必须用以下表格回显：

```markdown
✅ 偏好已记录！我未来的回复将遵守以下规则：

| Q | 维度 | 你的选择 | 实际效果示例 |
|---|---|---|---|
| 1 | 思维框架 | A. 第一性原理 | "为什么用钩子图？因为转化漏斗本质是注意力争夺..." |
| 2 | 回复语言 | A. 中文+英文术语 | "客单价 (AOV) 提升 20%" |
| 3 | 输出格式 | A. 表格优先 | （所有对比一律用 Markdown 表格） |
| 4 | 报告框架 | A. 麦肯锡 8 段 | （重大决策按 8 段式输出） |
| 5 | Next Steps | A. 必给 1-3 个 | （每条回复结尾固定输出） |
| 6 | 数据呈现 | B. 结论+数字 | "毛利率 78.3% ✅（高于 70% 底线 8.3pp）" |
| 7 | 风险沟通 | A. 直接预警 | "⚠️ 🔴 Tier3 月销 < 100 套会亏损" |
| 8 | AI 主动性 | A. 高 | （主动预判、批量执行、减少确认） |

✨ 即将进入最后一步：硬性规则建立（仅 2 题）
```

## ⚠️ 严格禁止

- ❌ 一次只解析 1 题（必须批量）
- ❌ 不回显直接写文件
- ❌ 用户没明确选时擅自填充
