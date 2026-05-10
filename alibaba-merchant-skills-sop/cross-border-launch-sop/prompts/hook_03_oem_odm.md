# Hook 03：OEM/ODM Brand Builder Hook

## 🎯 设计目标

针对 **想做品牌的高价值客户**，捕获 OEM/ODM 询盘。
- 核心信息：OEM/ODM + Build Your Own Brand + MOQ 100
- 视觉重点：皇冠+星标主徽章（紫粉渐变奢华感）

## 🖼 image_generate 调用 Prompt

```
A premium OEM/ODM service banner targeting brand builders, 1024x1024.

LAYOUT:
- Center: Large hexagonal main badge with crown + star icon
  · Background: Rich purple-to-pink gradient
  · Text: "OEM / ODM"
  · Subtitle: "BUILD YOUR OWN BRAND"
- 4 supporting badges around the main badge:
  · Top-left: "Custom Logo Printing"
  · Top-right: "Private Label Packaging"
  · Bottom-left: "Bespoke Design Service"
  · Bottom-right: "Exclusive Color Matching"
- Top corner ribbon: "MOQ 100 PCS"
- Bottom: Small text "FREE Design Consultation · 7-Day Sampling"

STYLE:
- Color palette: Royal purple, magenta pink, gold accents
- Luxury/premium feel (think high-end cosmetics or jewelry branding)
- Foil-stamped gold effect on main badge
- Sophisticated typography (mix of serif headline + sans-serif body)
- Add light ray effects radiating from center badge
- Premium texture (subtle gradient backgrounds)

DO NOT:
- No generic corporate look
- Must convey "exclusivity" and "premium service"
- No real brand logos referenced
```

## ⚙️ 调用参数

```python
image_generate(
    prompt=<above>,
    aspect_ratio="1:1",
    task_type="complex"
)
```

## ✅ 质检标准

| 维度 | 要求 |
|---|---|
| 高级感 | 紫粉渐变 + 金色点缀 |
| 主徽章突出 | 占视觉中心 50% |
| 4 支持徽章 | 服务范围一目了然 |
| MOQ 信息 | 角标突出但不喧宾夺主 |
| 评分目标 | ≥ 9/10 |

## 🔄 复用规则

- 跨品类通用（任何想推 OEM 的 SKU 都用）
- 用于详情页 Slot 10（详情页倒数第二屏，捕获高价值意向）
- 保存路径：`project/temp/launch/_brand_hooks/hook_03_oem_odm.jpg`
