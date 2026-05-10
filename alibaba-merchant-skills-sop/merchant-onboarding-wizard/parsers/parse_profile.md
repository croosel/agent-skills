# Profile 自然语言解析规则

## 🎯 任务

将用户的一段自然语言描述，解析为 `MERCHANT_PROFILE.json` 的结构化字段。

## 📋 解析字段映射

| JSON 字段 | 自然语言信号词 | 示例 |
|---|---|---|
| `brand_name` | "我是 X 品牌" / "店铺名 X" / "X 的运营" | "Lilis Wedding Party Decor" |
| `store_url` | http(s)://*.alibaba.com / 类似 URL | "https://cn1575365235ierx.en.alibaba.com" |
| `member_id` | URL 中的 cn 开头 ID / "member_id: X" | "cn1575365235" |
| `platform` | "国际站" → "alibaba.com"; "亚马逊" → "amazon" | "alibaba.com" |
| `main_category.name` | "主营 X" / "卖 X" / "做 X" | "婚庆派对装饰" |
| `main_category.cate_id` | "cateId X" / "类目 X" | "201599407" |
| `target_markets.primary` | "主要卖 X" / "主市场 X" / "主要在 X" | "US" |
| `target_markets.secondary` | "次要 X" / "副市场 X" / "也卖 X" | ["MX"] |
| `core_advantages[]` | "优势是 X" / "我们有 X" / "X 是核心" | ["NY 3PL Warehouse", "3-5 days delivery"] |
| `business_scale.monthly_orders` | "月单 X" / "每月 X 单" | 50 |
| `business_scale.team_size` | "团队 X 人" / "X 个人" | 3 |
| `target_customers[]` | "客户是 X" / "卖给 X" | ["SMB Retailers", "Amazon FBA"] |
| `languages[]` | "卖到 X" 自动推断 + 用户明确 | ["en-US", "es-MX"] |

## 🌍 国家映射规则

| 用户说法 | JSON 标准值 |
|---|---|
| 美国 / US / United States | "US" |
| 墨西哥 / Mexico / MX | "MX" |
| 欧洲 / EU / Europe | "EU" |
| 英国 / UK / Britain | "GB" |
| 日本 / JP / Japan | "JP" |
| 东南亚 / SEA | ["SG", "MY", "TH", "VN", "PH", "ID"] |

## 🌐 语言自动推断规则

根据 `target_markets` 自动添加 `languages`：

| 主市场 | 自动添加语言 |
|---|---|
| US / CA / GB / AU | "en-US" |
| MX / ES / AR / CO | "es-MX" |
| BR / PT | "pt-BR" |
| DE / AT | "de-DE" |
| FR | "fr-FR" |
| JP | "ja-JP" |

**示例**：用户说"卖美国和墨西哥" → 自动 `languages: ["en-US", "es-MX"]`

## ⚙️ 解析流程（AI 必须按顺序执行）

1. **读取用户回复**，按上述映射表逐字段提取
2. **缺失字段**：用 `null` 或 `""` 占位（**不要编造**）
3. **歧义字段**：在回显时标 ⚠️ 让用户确认
4. **自动推断**：语言、目标客群类型可基于 cateId / 市场推断
5. **回显模板**：

```markdown
✅ 我已解析出以下信息，请确认：

| 字段 | 值 | 说明 |
|---|---|---|
| 品牌名 | Lilis Wedding Party Decor | ✅ 直接提取 |
| 店铺 | https://...alibaba.com | ✅ 直接提取 |
| Member ID | cn1575365235 | ✅ 从 URL 解析 |
| 主营品类 | 婚庆派对装饰 | ✅ 直接提取 |
| Cate ID | 201599407 | ✅ 直接提取 |
| 主市场 | US | ✅ 直接提取 |
| 副市场 | MX | ✅ 直接提取 |
| 自动推断语言 | en-US, es-MX | 🤖 基于市场自动添加 |
| 核心优势 | 纽约 3PL 海外仓, 3-5 天达 | ✅ 直接提取 |
| 月单量 | 50 | ✅ 直接提取 |
| 团队规模 | 3 人 | ✅ 直接提取 |
| 目标客群 | ⚠️ 未提及 | 需要补问 |

⚠️ 1 项待补充：你的目标客户主要是 SMB 零售商、Amazon FBA 卖家、还是 B 端大客户？

回答后我立即写入 MERCHANT_PROFILE.json。
```

6. 用户确认后，按 `templates/MERCHANT_PROFILE_template.json` 结构写入文件

## ⚠️ 严格禁止

- ❌ 不要编造未提及的字段（如猜测 GMV、痛点）
- ❌ 不要直接写入文件而不回显确认
- ❌ 不要用单字段问答（一定要批量回显）
