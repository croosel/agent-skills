# 📋 5 步发品检查清单

> **使用方法**：每完成一步，AI 必须勾选对应项并向用户汇报。

## ✅ Step 0: 前置检查

- [ ] `${agent_core}/MERCHANT_PROFILE.json` 已存在（否则调用 onboarding-wizard）
- [ ] `${agent_core}/LEARNED_RULES.json` 已加载 IP 黑名单
- [ ] `_brand_hooks/` 目录存在 3 张通用钩子图（hook_01/02/03）

## 🔵 Step 1: 启动建模

- [ ] 用户提供产品图
- [ ] 用户提供 Amazon ASIN
- [ ] 用户提供产品 slug（英文短名）
- [ ] 创建 `project/temp/launch/{slug}/` 目录
- [ ] 复制 manifest_template.json 到该目录
- [ ] 创建 `images/` 子目录

## 🟢 Step 2: 白底化

- [ ] 调用 image_edit (task_type: white_background)
- [ ] 输出 1024x1024
- [ ] 背景为纯白 RGB(255,255,255)
- [ ] 保存到 `images/01_main_white_bg.jpg`
- [ ] 更新 manifest 的 image_assets[0].status = READY

## 🟡 Step 3: Amazon 抓取

- [ ] spawn browser sub-agent
- [ ] 抓取 Title, Price, Rating, Review Count
- [ ] 抓取 5 Bullet Points
- [ ] 抓取产品维度 / 重量
- [ ] 抓取关键差评摘要（用于规避）
- [ ] 数据写入 manifest.market_validation
- [ ] **绝对不要直接复制 Amazon 文案**

## 🟣 Step 4: 双语 Manifest

- [ ] 标题 EN-US 生成（≤190 字符）
- [ ] 标题 ES-MX 生成（≤190 字符）
- [ ] 关键词 EN（短尾 1 + 长尾 2）
- [ ] 关键词 ES（短尾 1 + 长尾 2）
- [ ] 6 Bullet Points EN
- [ ] 6 Bullet Points ES
- [ ] 阶梯定价 Tier 1/2/3
- [ ] 自动计算 FOB 毛利率
- [ ] **IP 黑名单检查通过**
- [ ] 物流参数（HTS / DDP / 重量）

## 🔴 Step 5: 钩子图 + 利润 + 上架

### 5.1 图片资产
- [ ] Slot 1 白底 ✅
- [ ] Slot 2 使用场景（AI 生成）
- [ ] Slot 3 材质尺寸（AI 生成）
- [ ] Slot 4 卖点信息图（AI 生成）
- [ ] Slot 5 hook_01（复用）
- [ ] Slot 6 hook_02（复用）
- [ ] Slot 7 场景差异化（AI 生成）
- [ ] Slot 8 摄影背景（AI 生成）
- [ ] Slot 9 配色对比（AI 生成）
- [ ] Slot 10 hook_03（复用）
- [ ] Slot 11 认证图（可选）

### 5.2 利润健康检查
- [ ] Tier 1 FOB 毛利率 ≥ 70% ✅
- [ ] Tier 2 FOB 毛利率 ≥ 70% ✅
- [ ] Tier 3 FOB 毛利率 ≥ 70%（如不达标，🟡 预警）
- [ ] 含海外仓均摊后利润测算

### 5.3 上架前最终校验
- [ ] manifest.json JSON 合法性校验通过
- [ ] 11 图布局打印确认表
- [ ] 用户最终确认
- [ ] 调用 #alibaba-product-publish

## 📊 完成后汇报模板

```markdown
✅ {产品名} 发布完成！

📊 资产清单：
- 11 张图（10 READY + 1 PENDING_OPTIONAL）
- 双语 listing（EN + ES）
- 3 阶梯定价（毛利率 X% / Y% / Z%）
- HTS {code}, DDP ${cost}

⏱️ 用时：X 分钟（vs 传统 15-20 分钟，节省 X%）
💰 节省 Token：约 X
🎯 转化预期：基准 +50-70%

🚀 推荐 Next Steps：
1. 监控首周询盘量
2. 准备第 2 个 SKU
3. 装修店铺 (调用 alibaba-create-website)
```
