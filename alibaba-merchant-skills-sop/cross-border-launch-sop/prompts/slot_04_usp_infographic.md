# Slot 04：USP Infographic 卖点信息图

## 🎯 设计目标

主图区第 4 张，**价值锚定**：6 大 USP + 社会证明，回答"为什么选你"。

## 🖼 image_generate Prompt 模板

```
A professional USP infographic banner, 1024x1024, conversion-optimized.

LAYOUT:
- Top: Bold headline "WHY {brand_name}" in large font
- Below headline: Star rating display "★★★★★ 4.8/5 from {review_count}+ Customers"
- Center: 6 USP badges in 2x3 grid:
  Cell 1: 💎 "PREMIUM QUALITY" — {usp_1_subtitle}
  Cell 2: 🏭 "FACTORY DIRECT" — {usp_2_subtitle}
  Cell 3: 🚚 "FAST SHIPPING" — {usp_3_subtitle}
  Cell 4: 🎨 "CUSTOM AVAILABLE" — {usp_4_subtitle}
  Cell 5: 💰 "BEST VALUE" — {usp_5_subtitle}
  Cell 6: 🛡️ "SATISFACTION GUARANTEED" — {usp_6_subtitle}
- Bottom: Trust badges row
  · "Verified Supplier"
  · "Trade Assurance"
  · "On-Time Delivery 99%"
  · "Reorder Rate 65%"

STYLE:
- Color palette: Brand colors + white background for clean look
- Each USP cell: Icon (top) + Bold title (middle) + Subtitle (bottom)
- Use subtle drop shadows on badges for depth
- Star rating in gold color, prominent
- Trust badges in muted blue (professional)

TYPOGRAPHY:
- Headlines: Bold sans-serif (Montserrat / Helvetica)
- Subtitles: Light/Regular sans-serif
- Numbers: Extra bold to grab attention

CRITICAL:
- Must be readable on mobile (no text < 18pt)
- High contrast for accessibility
- Visual hierarchy: Stars > USPs > Trust badges
```

## 🔧 参数填充指南

| 占位符 | 案例 |
|---|---|
| `{brand_name}` | "LILIS WEDDING" |
| `{review_count}` | "500" |
| `{usp_1_subtitle}` | "100% Quality Tested" |
| `{usp_2_subtitle}` | "No Middleman Markup" |
| `{usp_3_subtitle}` | "3-5 Days from US Warehouse" |
| `{usp_4_subtitle}` | "OEM/ODM with MOQ 100" |
| `{usp_5_subtitle}` | "Up to 70% Off Bulk Orders" |
| `{usp_6_subtitle}` | "30-Day Money Back" |

## ⚙️ 调用参数

```python
image_generate(
    prompt=<填充后>,
    aspect_ratio="1:1",
    task_type="complex"
)
```

## ✅ 质检标准

| 维度 | 要求 |
|---|---|
| 6 USP 完整 | 2x3 网格清晰分布 |
| 评分突出 | 4.8★ 显眼且有金色 |
| 信任元素 | 4 个底部 badge 增强可信度 |
| 配色统一 | 与品牌色一致 |
| 评分目标 | 10/10 |

## 💡 进阶技巧

USP 选择策略：
- **如果竞品也有的 USP，强化"我们做得更好"**（如"Free Shipping" → "Free Shipping in 3 Days"）
- **如果是独家 USP，放在 Cell 1 或 Cell 4**（视觉焦点位置）
- **避免抽象词**（如"High Quality"），用具体数字（"Tested 50+ Cycles"）
