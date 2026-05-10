# Slot 02：Lifestyle Scene 使用场景图

## 🎯 设计目标

主图区第 2 张，**情感代入**：让买家秒懂"这就是我的客户想要的"。

## 🖼 image_generate Prompt 模板

```
A beautiful lifestyle scene showing the {product_name} in actual use at a {target_event}.

SCENE COMPOSITION:
- Setting: {specific_venue} (e.g. "elegant outdoor garden party at golden hour")
- People: {target_demographics} (e.g. "joyful Latina family celebrating Quinceañera")
- Product placement: Hero product is the visual focal point, fully decorated and styled
- Atmosphere: {emotional_tone} (e.g. "warm, celebratory, magical moment")

COMPOSITION RULES:
- Rule of thirds: Product anchors one third of frame
- Depth of field: Subtle bokeh background to highlight product
- Lighting: Natural golden hour OR professional event lighting
- Color story: Coordinated palette matching product colors
- Action moment: People interacting/admiring the product (not posed)

STYLE:
- Editorial / Lifestyle magazine photography
- High resolution, 1024x1024
- Photorealistic, NOT cartoonish
- Aspirational but achievable feel
- Show 3-5 people max (group shot)

CRITICAL:
- Product must be 30-40% of frame (clearly visible)
- Show the product IN USE, not just on display
- Capture genuine emotion (smiles, hugs, celebration)
```

## 🔧 参数填充指南

| 占位符 | 案例：Quinceañera Decoration Set |
|---|---|
| `{product_name}` | "Quinceañera party decorations" |
| `{target_event}` | "Quinceañera (Sweet 15) celebration" |
| `{specific_venue}` | "elegant indoor banquet hall with chandeliers" |
| `{target_demographics}` | "joyful Latina family with the 15-year-old quinceañera in pink dress" |
| `{emotional_tone}` | "magical, dreamy, once-in-a-lifetime" |

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
| 真实感 | 不能像 AI 生成（避免典型 AI 瑕疵） |
| 文化适配 | 人物族裔/服饰符合目标市场 |
| 产品聚焦 | 占 30-40% 画面 |
| 情感传达 | 笑容真挚，氛围温馨 |
| 评分目标 | ≥ 9/10 |

## 💡 进阶技巧

如果第一次生成不理想，可加入：
- "shot with Canon EOS R5, 50mm f/1.8 lens, professional photography"
- "8K high resolution, ultra detailed, magazine quality"
- "natural skin tones, candid expressions"
