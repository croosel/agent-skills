# 利润健康检查方法论

## 🎯 核心目标

**避免"看似有单，实则亏损"**：通过 3 维度利润测算，确保每个 Tier 都健康。

---

## 📐 三维度利润计算公式

### 维度 1：FOB 毛利率（基础）

```
FOB Gross Margin = (Selling Price - Production Cost) / Selling Price

示例：
  Tier 1 售价 $11.50, 生产成本 $2.5
  → FOB Margin = ($11.50 - $2.5) / $11.50 = 78.3%
```

**红线**：FOB 毛利率 < 70% → 🟡 预警

### 维度 2：含海外仓均摊后毛利率

```
Warehouse Margin = (Selling Price - Production - Logistics - Storage) / Selling Price

其中：
  Logistics = 头程海运 + 末端派送 (per unit)
  Storage = 月仓储费 / 月销量 (per unit)

示例（NY 3PL）：
  月固定费用 $500
  月销 100 套 → 每套均摊 $5 仓储
  Tier 1 ($11.50) → ($11.50 - $2.5 - $1.5 - $5) / $11.50 = 21.7%
  
⚠️ Tier 1 在月销 100 套时毛利率只有 21.7%（远低于 FOB 的 78.3%）
```

### 维度 3：含关税 DDP 到手成本

```
DDP Total Cost = Production + Tariff + Logistics + Last-mile + 5% Buffer

示例：
  Production: $2.5
  Tariff (HTS 9505.90.6000, 7.5%): $11.50 × 7.5% = $0.86
  Sea Freight (per unit): $1.0
  US Last-mile: $3.5
  → DDP Total: ~$8.50/套

如果 Tier 1 售价 $11.50, DDP 利润 = $11.50 - $8.50 = $3.0/套（26% 利润）
```

---

## 📊 健康度评级表

| FOB 毛利率 | 含仓储毛利率（月销 100） | 评级 | 行动建议 |
|---|---|---|---|
| ≥ 80% | ≥ 50% | 🟢 优秀 | 维持现状 |
| 70-80% | 30-50% | 🟢 健康 | 维持现状 |
| 60-70% | 10-30% | 🟡 警戒 | 月销需 ≥ 200 套才安全 |
| 50-60% | < 10% | 🟠 风险 | 提价 5-10% 或砍 SKU |
| < 50% | 亏损 | 🔴 红线 | 立即停售或重新定价 |

---

## 🛠 自动测算输出模板

每次发新品 Step 5 自动执行：

```markdown
💰 {产品名} 利润健康检查报告

📊 三档定价测算：

| Tier | MOQ | 售价 | FOB 毛利率 | 含仓储毛利率 | 评级 |
|---|---|---|---|---|---|
| 1 | 30-99 | $11.50 | 78.3% | 65% (月销50+) | 🟢 健康 |
| 2 | 100-299 | $9.80 | 74.5% | 60% (月销50+) | 🟢 健康 |
| 3 | 300+ | $8.20 | 69.5% | 🟡 月销<100套会亏损 | 🟡 警戒 |

🎯 关键发现：
- ✅ Tier 1/2 全场景健康
- 🟡 Tier 3 需配合大单（≥100 套/月）才能盈利
- 💡 建议：Tier 3 适合"清库存"或"大客户专享"，不要主推

🚀 决策建议：
1. 接受现状（Tier 3 仅作清库存）→ 维持定价 ✅
2. 上调 Tier 3 至 $9.50 保 70% 毛利底线
3. 砍掉 Tier 3，仅保留 Tier 1/2

请选择 1/2/3。
```

---

## ⚙️ 计算工具（可选 Python 脚本）

```python
def profit_health_check(production_cost, tier_price, monthly_sales, 
                        warehouse_monthly_fixed=500, 
                        per_unit_storage=0.5,
                        tariff_rate=0.075,
                        sea_freight=1.0,
                        last_mile=3.5):
    # FOB Margin
    fob_margin = (tier_price - production_cost) / tier_price
    
    # Warehouse Margin
    storage_per_unit = warehouse_monthly_fixed / monthly_sales + per_unit_storage
    warehouse_cost = production_cost + sea_freight + storage_per_unit
    warehouse_margin = (tier_price - warehouse_cost) / tier_price
    
    # DDP Cost
    tariff = tier_price * tariff_rate
    ddp_total = production_cost + tariff + sea_freight + last_mile
    ddp_profit = tier_price - ddp_total
    
    # Rating
    if fob_margin >= 0.80 and warehouse_margin >= 0.50:
        rating = "🟢 Excellent"
    elif fob_margin >= 0.70 and warehouse_margin >= 0.30:
        rating = "🟢 Healthy"
    elif fob_margin >= 0.60 and warehouse_margin >= 0.10:
        rating = "🟡 Warning"
    elif fob_margin >= 0.50:
        rating = "🟠 Risk"
    else:
        rating = "🔴 Loss"
    
    return {
        "fob_margin": f"{fob_margin*100:.1f}%",
        "warehouse_margin": f"{warehouse_margin*100:.1f}%",
        "ddp_profit": f"${ddp_profit:.2f}",
        "rating": rating
    }
```

---

## 💡 实战经验

1. **新品定价宁高勿低**：上线后下调容易，上调难
2. **Tier 1 是标杆**：80% 询盘集中在 Tier 1，其他 Tier 是"诱饵"
3. **不要无脑最低价**：Tier 3 利润底线一定要守住
4. **海外仓是双刃剑**：低销量时是负担，高销量时是壁垒
5. **关税常变**：每月查一次最新税率（特别是中美贸易政策）
