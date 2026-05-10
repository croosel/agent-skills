# 案例：大勛 Lilis Wedding Party Decor 商家建档

> 这是 Skill 创建者大勛本人的真实建档案例，可作为标准参考。

## 🎬 完整对话流程（5 分钟）

### Stage 1：必填 5 问（2 分钟）

**🤖 AI 发出标准 5 问** → **👤 用户回答**：

> "我是 Lilis Wedding Party Decor Supplies 的国际站运营负责人，
> 店铺 https://cn1575365235ierx.en.alibaba.com，主营婚庆派对装饰用品
> （cateId 201599407 Party Decoration sets + 201606903 Party & Holiday Supplies），
> 主要卖到美国和墨西哥（北美主市场），核心优势是纽约 3PL 海外仓 3-5 天达，
> 还有美国办公室+工厂直销，月单约 50 单，团队 3 人。
> 客户主要是 SMB 零售商、Amazon FBA 卖家、Etsy/Shopify 创业者、婚庆策划公司。"

**🤖 AI 解析回显**：

```markdown
✅ 已解析以下信息，请确认：

| 字段 | 值 | 说明 |
|---|---|---|
| 品牌名 | Lilis Wedding Party Decor Supplies | ✅ |
| 店铺 | https://cn1575365235ierx.en.alibaba.com | ✅ |
| Member ID | cn1575365235 | ✅ 从 URL 解析 |
| 平台 | alibaba.com | ✅ |
| 主营品类 | 婚庆派对装饰 | ✅ |
| 主类目 | Party Decoration sets (201599407) | ✅ |
| 副类目 | Party & Holiday Supplies (201606903) | ✅ |
| 主市场 | US | ✅ |
| 副市场 | MX | ✅ |
| 自动推断语言 | en-US, es-MX | 🤖 基于市场推断 |
| 核心优势 | 纽约 3PL 海外仓 / 3-5 天达 / 美国办公室 / 工厂直销 | ✅ |
| 月单量 | 50 | ✅ |
| 团队规模 | 3 人 | ✅ |
| 目标客群 | SMB 零售商, Amazon FBA, Etsy/Shopify 创业者, 婚庆策划 | ✅ |

✅ 信息完整，无需补问。确认无误后我写入 MERCHANT_PROFILE.json。
```

### Stage 2：偏好 8 问（3 分钟）

**🤖 AI 发出 8 题快问快答** → **👤 大勛回答**：

> "1A 2A 3A 4A 5A 6B 7A 8A"

**🤖 AI 回显**：

```markdown
✅ 偏好已记录（这是大勛验证过的最佳组合）：

| Q | 维度 | 选择 | 效果 |
|---|---|---|---|
| 1 | 思维框架 | A. 第一性原理 | 拆解→质疑→重组→验证→洞察 |
| 2 | 语言 | A. 中文+英文术语 | "客单价 (AOV)" |
| 3 | 格式 | A. 表格优先 | 一律用 Markdown 表格 |
| 4 | 框架 | A. 麦肯锡 8 段 | 重大决策按 8 段输出 |
| 5 | Next Steps | A. 必给 1-3 个 | 每条回复结尾固定 |
| 6 | 数据 | B. 结论+数字 | 先结论，附关键数字 |
| 7 | 风险 | A. 直接预警 | 🔴🟡🟢 标注 |
| 8 | 主动性 | A. 高 | 主动预判+批量执行 |
```

### Stage 3：规则 2 问（30 秒）

**🤖 AI 发出 2 问** → **👤 大勛回答**：

> "Q1 用大勛默认 IP 黑名单（Disney/Stitch/Aurora 等 30+ 词）
> Q2 用默认推荐规则"

**🤖 AI 应用默认配置**：

```json
{
  "ip_blacklist": ["Disney", "Stitch", "Aurora", "Frozen", "Elsa", ...],
  "image_rules": ["首图必须白底 RGB(255,255,255), 1024x1024"],
  "language_rules": ["所有 listing 必须双语：EN-US + ES-MX"],
  "moq_rules": ["MOQ ≤ 100 PCS, 必须支持 Sample Order"],
  "profit_rules": ["FOB 毛利率 < 70% 触发预警", "必须计算 DDP 到手成本"]
}
```

### 完成！

```markdown
🎉 Onboarding 完成！

📊 三件套状态：
| 文件 | 状态 | 字段数 |
|---|---|---|
| MERCHANT_PROFILE.json | ✅ | 14 个核心字段 |
| USER_PREFERENCES.json | ✅ | 8 个偏好维度 |
| LEARNED_RULES.json | ✅ | 30+ IP 词 + 5 类规则 |

⏱️ 用时：4 分 30 秒
💰 节省 Token：约 5500（vs 传统对话式建档）

🚀 推荐下一步：
1. 输入 "发新品" → cross-border-launch-sop
2. 输入 "店铺装修" → alibaba-create-website
3. 输入 "数据查询" → alibaba-analysis-brief
```

## 📊 对比传统方式

| 维度 | 传统对话式 | 本 Skill 流程 |
|---|---|---|
| 用时 | 30-60 分钟 | **4.5 分钟** |
| 对话回合 | 30+ | **3 个** |
| Token 消耗 | ~8000 | **~2500** |
| 字段完整度 | 60% | **95%** |
| 用户疲劳度 | 高 | 低 |

## 💡 关键成功因素

1. **一次问 5 题，不挤牙膏** → 用户一段话讲完
2. **二选一格式** → 偏好题秒选
3. **大勛默认配置** → 规则题一键启用
4. **表格回显** → 错误立即修正，不返工
