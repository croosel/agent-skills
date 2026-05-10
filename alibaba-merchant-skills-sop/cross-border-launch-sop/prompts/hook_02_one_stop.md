# Hook 02：One-Stop Wholesale Hook

## 🎯 设计目标

针对 **婚庆策划公司 + 批发买家** 的钩子图，强调"一站式采购"价值。
- 核心信息：1 Supplier + 1 Shipment + 1 Invoice + 5000+ SKUs
- 视觉重点：4 大品类陈列（高仿真花 + 氛围灯 + 桌布背景 + 气球）

## 🖼 image_generate 调用 Prompt

```
A professional one-stop wholesale showcase banner, 1024x1024, e-commerce style.

LAYOUT:
- Top: Headline "ONE-STOP WEDDING & PARTY SUPPLIES"
- Subheadline: "1 Supplier · 1 Shipment · 1 Invoice · 5000+ SKUs"
- Center: 4-quadrant product grid showing:
  Quadrant 1 (top-left): Premium artificial flowers (roses, peonies, eucalyptus)
  Quadrant 2 (top-right): Ambient lighting (LED candles, string lights, lanterns)
  Quadrant 3 (bottom-left): Tablecloths and photo backdrops (silk, sequin, satin)
  Quadrant 4 (bottom-right): Balloons (gold, rose gold, pearl, latex)
- Bottom: 4 small badges
  · "Custom Orders Welcome"
  · "OEM/ODM Available"
  · "Worldwide Shipping"
  · "30-Day Quality Guarantee"

STYLE:
- Color palette: Soft rose gold + champagne + cream tones (wedding luxury feel)
- High-end editorial photography style
- Lifestyle scene composition with natural lighting
- Add elegant serif font for headlines
- Subtle gold accents and decorative elements
- Wedding/celebration atmosphere

DO NOT:
- No specific brand names visible
- No copyrighted character imagery
- Avoid cluttered or busy compositions
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
| 4 品类完整 | 每个象限产品清晰可辨 |
| 配色高级感 | Rose gold / 香槟色调 |
| 价值传达 | "1 Supplier" 信息突出 |
| 转化设计 | 4 个底部 badge 增强信任 |
| 评分目标 | ≥ 9/10 |

## 🔄 复用规则

- 全部婚庆/派对类 SKU 共用
- 用于详情页 Slot 6（详情页第一屏）
- 保存路径：`project/temp/launch/_brand_hooks/hook_02_one_stop.jpg`
