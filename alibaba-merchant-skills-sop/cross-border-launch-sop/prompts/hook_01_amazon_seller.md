# Hook 01：Amazon Seller / SMB CTA Hook

## 🎯 设计目标

针对 **SMB 零售商 + Amazon FBA 卖家** 的钩子图，触发首次询盘冲动。
- 核心信息：Factory Direct + US Office + US Warehouse + Free Samples
- CTA：CHAT NOW（醒目按钮）

## 🖼 image_generate 调用 Prompt

```
A professional B2B marketing banner image, 1024x1024, e-commerce style.

LAYOUT (top to bottom):
- Top 25%: Bold headline "FACTORY DIRECT + US WAREHOUSE" in modern sans-serif font
- Middle 50%: 4 icon badges in 2x2 grid:
  · 🏭 "Factory Direct" (factory icon)
  · 🇺🇸 "US Office" (American flag + office building)
  · 📦 "NY Warehouse 3-5 Days" (warehouse + truck icon)
  · 🎁 "Free Samples Available" (gift box icon)
- Bottom 25%: Large bright orange "CHAT NOW" button with white text + chat bubble icon

STYLE:
- Color palette: Navy blue background, white text, orange CTA button
- Premium B2B feel, similar to Alibaba.com gold supplier banners
- Clean, high contrast, mobile-readable
- Add subtle gradient and shadow effects for depth
- Include small "Verified Supplier" badge in corner

DO NOT:
- No real brand logos (Disney, Nike, etc.)
- No copyrighted images
- No text smaller than 24pt (must be readable on mobile)
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
| 文字可读性 | 手机端清晰可读 |
| CTA 显眼度 | 橙色按钮占视觉焦点 |
| 信息密度 | 4 个核心卖点不堆砌 |
| 品牌一致性 | Navy blue + Orange 配色 |
| 评分目标 | ≥ 9/10 |

## 🔄 复用规则

- 同一品牌**全部 SKU 复用同一张** hook_01
- 仅当品牌定位重大变更时才重新生成
- 保存路径：`project/temp/launch/_brand_hooks/hook_01_amazon_seller.jpg`
