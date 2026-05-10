# Slot 03：Material & Size Spec Sheet 材质尺寸图

## 🎯 设计目标

主图区第 3 张，**B2B 规格验证**：让批发买家秒判断"质量+尺寸符合预期"。

## 🖼 image_generate Prompt 模板

```
A professional B2B product spec sheet, 1024x1024, e-commerce style.

LAYOUT (3 sections):
TOP THIRD: Material showcase
- Close-up macro photography of the material (fabric/paper/plastic)
- Show texture details (e.g. "premium velvet texture", "thick cardstock")
- Label: "PREMIUM MATERIAL: {material_name}"

MIDDLE THIRD: Size & dimension diagram
- Technical drawing style with measurements
- Show product from front/side with dimension lines (cm + inches)
- Include ruler or coin for scale reference
- Labels: "{Width} cm x {Height} cm x {Depth} cm"

BOTTOM THIRD: Component breakdown
- Flat lay of all included items
- Numbered labels with quantities
- Format: "✓ 1x Item A | ✓ 30x Item B | ✓ 50x Item C"
- Total: "TOTAL: {total_pieces} PCS · SERVES {serves} PEOPLE"

STYLE:
- Clean white/grey background
- Professional product photography
- Clear typography (Helvetica/Arial bold for numbers)
- Use color coding for material types
- Add subtle grid lines for technical feel

REQUIRED ELEMENTS:
- "{Cert_logo}" badges if applicable (FDA, CPSIA, CE)
- Brand watermark in corner (small, non-intrusive)
```

## 🔧 参数填充指南

| 占位符 | 案例：Quinceañera Decoration Set |
|---|---|
| `{material_name}` | "Premium silk fabric + sturdy cardstock" |
| `{Width/Height/Depth}` | "40 x 30 x 15 cm" |
| `{total_pieces}` | "181 PCS" |
| `{serves}` | "25 people" |
| `{Cert_logo}` | "CPSIA Tested" |

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
| 信息密度 | 3 段内容均匀分布 |
| 可读性 | 数字/单位清晰可辨 |
| 专业感 | 有 CAD 制图风格 |
| 信任元素 | 包含认证 logo |
| 评分目标 | 10/10（B2B 必须满分） |

## 💡 进阶技巧

如果信息太挤，可拆为 2 张：
- 03a_material.jpg（仅材质）
- 03b_size.jpg（仅尺寸）

但**首选合并为 1 张**（节省图位）。
