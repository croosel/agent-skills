---
name: cross-border-launch-sop
description: 跨境电商发品与店铺装修前置准备 SOP（专属大勛定制版）。基于 Hybrid Workflow v1.0 的人+Amazon+AGENT 三方分工模式，5 步完成新品建模发布。当用户说「发新品/上架/launch product/搬品/新品建模」或提供 1 张产品图 + Amazon ASIN 时触发。预期单 SKU 准备时间从 15-20 分钟缩短至 8-10 分钟，节省 50% Token，转化率预期提升 50-70%。
trigger:
  - "发新品" / "上架 [产品名]" / "搬品" / "新品建模" / "launch new product"
  - 用户同时提供 1 张产品图 + 1 个 Amazon ASIN
  - "店铺装修" / "首页设计" / "做新 listing"
  - 用户说要发布到国际站 + 提到 Amazon 链接
---

# 🚀 跨境电商发品 SOP - Hybrid Workflow v1.0

> **专属定制**：本 Skill 由「大勛」基于 Lilis Wedding Party Decor 实战经验沉淀，适用于各品类跨境电商发品。

## 核心使命

用 **Hybrid Workflow（人 + Amazon + AGENT 三方分工）**，将单 SKU 发品准备时间从 **15-20 分钟** 缩短至 **8-10 分钟**，同时通过 11 图转化漏斗 + 3 钩子图设计，将询盘转化率提升 **50-70%**。

## 第一性原理

| 原则 | 反例 ❌ | 正例 ✅ |
|---|---|---|
| **减少熵增** | 信息散落对话中 | 固化到 manifest.json |
| **三方分工** | AI 全干（不准） / 人全干（慢） | 人定方向 + Amazon 验证 + AI 执行 |
| **价值锚定前置** | 4 张产品特写图 | 主图区放场景+规格+卖点 |
| **转化漏斗设计** | 通用图随便摆 | 11 图 6 阶段精准布局 |
| **品牌资产复用** | 每 SKU 重做钩子图 | 3 钩子图跨 SKU 通用 |

---

## 前置检查（启动前必读）

**Step 0: Profile 检查**

```python
if not os.path.exists("${agent_core}/MERCHANT_PROFILE.json"):
    print("⚠️ 检测到画像未建立，建议先完成 5 分钟 onboarding")
    suggest("立即调用 merchant-onboarding-wizard")
else:
    load_merchant_profile()
    proceed_to_step_1()
```

读取 `${agent_core}/MERCHANT_PROFILE.json` + `LEARNED_RULES.json`，将商家画像和硬性规则注入上下文。

---

## 5 步标准流程

### 🔵 Step 1：启动建模 + 建立 Manifest

**输入**：
- 用户提供：1 张原始产品图（任意背景）
- 用户提供：1 个 Amazon ASIN（参考竞品）
- 用户提供：产品名（如 "Quinceañera Decoration Set"）

**操作**：
1. 在 `project/temp/launch/{product_slug}/` 创建目录
2. 复制 `templates/manifest_template.json` 到该目录
3. 创建 `images/` 子目录
4. 检查 `_brand_hooks/` 是否存在 3 张通用钩子图，无则提示用户先生成

**产出**：
```
project/temp/launch/{product_slug}/
├── manifest.json (空骨架)
└── images/ (空目录)
```

---

### 🟢 Step 2：白底化处理（首图）

**操作**：
1. 用 `image_edit` 工具，prompt: "Professional product photo on pure white background RGB(255,255,255), studio lighting, e-commerce style, 1024x1024"
2. task_type: "white_background"
3. 输出保存为 `images/01_main_white_bg.jpg`
4. 更新 manifest.json 的 `image_assets[0]`

**质检要求**：
- ✅ 背景纯白 RGB(255,255,255)
- ✅ 产品居中，占画面 70-80%
- ✅ 无阴影 / 无水印
- ✅ 1024x1024 分辨率

---

### 🟡 Step 3：Amazon 数据抓取

**操作**：
1. spawn 一个 `browser` sub-agent
2. 任务：抓取 Amazon ASIN 页面的关键数据
3. 必抓字段：
   - 产品标题 (Title)
   - 价格 (Price)
   - 评分 (Rating) + 评论数
   - Bullet Points（5 大卖点）
   - 产品维度 / 重量
   - 类目 (Category)
   - 关键评论摘要
4. 数据保存到 manifest.json 的 `market_validation` 字段

**重要**：Amazon 数据仅作"市场验证"用，**不要直接复制**（侵权风险）。AI 必须用 Amazon 数据为基准，重新创作 listing。

---

### 🟣 Step 4：双语 Manifest 生成

**操作**：基于 Step 1-3 收集的数据，AI 自主填充以下字段：

#### 4.1 标题（双语 EN-US + ES-MX）
- 长度限制：每个语言版本 ≤ 190 字符
- 必含：产品类型 + 核心卖点 + 数量/规格 + 关键场景
- 参考 `templates/title_formula.md`

#### 4.2 关键词（双语，每语言 3 个）
- 短尾 1 个：高搜索量
- 长尾 2 个：高转化

#### 4.3 卖点 (Bullet Points)
- 6 个 USP，按以下顺序：
  1. 数量价值 (Quantity Value)
  2. 材质质量 (Material Quality)
  3. 易用性 (Easy Setup)
  4. 适用场景 (Versatility)
  5. 视觉效果 (Visual Impact)
  6. 售后保障 (Service Guarantee)

#### 4.4 阶梯定价
- Tier 1 (30-99 PCS): 高价
- Tier 2 (100-299 PCS): 中价
- Tier 3 (300+ PCS): 低价
- 自动计算 FOB 毛利率，**< 70% 触发 ⚠️ 预警**

#### 4.5 物流参数
- 重量 + 尺寸 + 体积重
- HTS Code（按品类查 `workflows/hts_lookup.md`）
- 关税率 + DDP 到手成本

---

### 🔴 Step 5：钩子图生成 + 利润健康检查 + 上架

#### 5.1 主图区 5 张（v2.0 策略）
| Slot | 类型 | 来源 |
|---|---|---|
| 1 | 白底主图 | Step 2 已生成 |
| 2 | 使用场景 | AI 生成（用 `prompts/slot_02_lifestyle_scene.md`） |
| 3 | 材质尺寸 | AI 生成（用 `prompts/slot_03_material_spec.md`） |
| 4 | 卖点信息图 | AI 生成（用 `prompts/slot_04_usp_infographic.md`） |
| 5 | 钩子 hook_01 | 复用 `_brand_hooks/hook_01.jpg` |

#### 5.2 详情页 6 张
| Slot | 类型 | 来源 |
|---|---|---|
| 6 | 钩子 hook_02 | 复用 `_brand_hooks/hook_02.jpg` |
| 7 | 场景图（差异化） | AI 生成（不同于 Slot 2） |
| 8 | 摄影背景场景 | AI 生成 |
| 9 | 4 配色对比 | AI 生成 |
| 10 | 钩子 hook_03 | 复用 `_brand_hooks/hook_03.jpg` |
| 11 | CPC/认证图 | AI 生成（可选） |

#### 5.3 利润健康检查
读取 `workflows/profit_health_check.md`，输出：

```markdown
| Tier | 售价 | FOB 毛利率 | 含 NY 仓毛利率 | 状态 |
|---|---|---|---|---|
| 1 | $11.50 | 78.3% | 65% | ✅ 健康 |
| 2 | $9.80 | 74.5% | 60% | ✅ 健康 |
| 3 | $8.20 | 69.5% | 50% | 🟡 月销 < 100 套会亏损 |
```

#### 5.4 触发上架
1. 校验 manifest.json 完整性（用 `python3 -c "import json; json.load(open('manifest.json'))"`）
2. 调用 `#alibaba-product-publish` Skill
3. 完成后写入 TASK_HISTORY

---

## 强制约束（不可违反）

1. ✅ **首图必须白底** RGB(255,255,255)
2. ✅ **双语必填** EN-US + 目标市场语言
3. ✅ **MOQ ≤ 100 + Sample Order** SMB 友好
4. ✅ **检查 LEARNED_RULES.json 的 IP 黑名单**，禁止使用任何禁词
5. ✅ **3 张钩子图必须就位**（如缺，先调用钩子图生成流程）
6. ✅ **每条回复结尾给 1-3 个 Next Steps**

---

## 文件清单

| 文件 | 用途 |
|---|---|
| `SKILL.md` | 本文件，主入口 |
| `README.md` | 用户使用说明 |
| `templates/manifest_template.json` | 完整 manifest 骨架（含 11 图位） |
| `templates/master_profile_template.json` | 母 profile（品牌通用资产） |
| `templates/checklist_5_steps.md` | 5 步检查清单 |
| `prompts/hook_01_amazon_seller.md` | Hook 1 生成 Prompt |
| `prompts/hook_02_one_stop.md` | Hook 2 生成 Prompt |
| `prompts/hook_03_oem_odm.md` | Hook 3 生成 Prompt |
| `prompts/slot_02_lifestyle_scene.md` | 场景图 Prompt |
| `prompts/slot_03_material_spec.md` | 规格图 Prompt |
| `prompts/slot_04_usp_infographic.md` | 卖点图 Prompt |
| `workflows/hybrid_workflow_v1.md` | 三方分工详解 |
| `workflows/11_image_layout_strategy.md` | 11 图转化漏斗 |
| `workflows/profit_health_check.md` | 利润健康检查方法 |
| `examples/quinceanera_case_study.md` | 大勛实战案例 |

---

## 性能指标

| 指标 | 传统方式 | 本 Skill |
|---|---|---|
| 单 SKU 准备时间 | 15-20 分钟 | **8-10 分钟** (-50%) |
| Token 消耗 | ~3500/SKU | **~1800/SKU** (-49%) |
| 流程一致性 | 60-70% | **95%+** |
| 询盘转化率 | 基准 | **+50-70%** |
| 跨 SKU 复用 | 0% | **3 钩子图 100% 复用** |

---

**维护者**：大勛  
**版本**：v1.0  
**创建日期**：2026-05-02
