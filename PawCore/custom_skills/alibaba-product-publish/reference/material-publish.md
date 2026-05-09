# 素材包发品链路

通过用户上传的素材包，在 Alibaba.com 国际站（ICBU）批量发布商品。

## 素材包发品流程

流程为严格顺序执行，每一步依赖上一步的成功结果。

`<工作目录>`为reference/material-analysis.md创建的临时工作目录`analysis_<YYYYMMDD_HHMMSS>/`

### 第 1 步：素材解析

读取并执行 reference/material-analysis.md 子技能，完成素材文件的解析。

执行步骤：
1. 读取 reference/material-analysis.md
2. 按文档中的工作流程完整执行素材解析（包括 ZIP 解压、图片收集、文档提取、AI 解析、AI 视觉分析、统一分类、选主图）
3. 获得解析后的商品数据 materialInfo（JSON 数组）。**上限限制：若数组长度超过 15，仅保留前 15 个元素，截断后的数组作为后续步骤的输入。**
4. 素材解析完毕后以表格形式打印素材解析结果。

第 1 步执行过程中，不需要和用户进行交互，直接执行。

### 第 2 步：预测类目

使用第 1 步返回的 `materialInfo` 内容作为入参 `material`，调用 `infer_category` 进行内容素材推理。

- **入参:**
  - `material` — 第 1 步返回的素材解析内容。**注意：传参时必须确保 `material` 的值为字符串类型（用双引号包裹），否则工具调用会失败。**
- **返回:** `AiResponse<Map<String, String>>` — 返回结果的 `model` 字段为 `Map<String, String>` 类型，固定只有 1 个键值对：
  - **key**: 叫做 `category_key`。记住：这里不要按照 category_key 去提取内容，要将map的唯一key拿出来作为category_key。将其保存用于后续步骤
  - **value**: 存入 tair 的内容，格式参考 reference/infer_category_sample_result.json
- **结果判断（通过返回结果的 `model` 字段判断）:**
  - **类目预测成功（`model` 非空）:** 从 `model` 中取出唯一的 value，将该 value 解析为 `JSONArray`，通过 `JSONArray.size()` 获取商品总数 `totalCount`，保存用于后续步骤。**注意：`totalCount` 以本步骤（第 2 步）的结果为准，因为 `infer_category` 可能会合并或调整品类数量，第 1 步的数组长度仅用于上限截断。** 将`model`内容保存为`<工作目录>/infer_category_result.json`。进入第 3 步。
  - **类目预测失败:** 向用户报告返回结果中的具体错误信息。

### 第 3 步：用户修改并确认

向用户展示解析后的商品信息 **禁止展示 tair key 相关信息**，等待用户修改或者确认是否继续发品。

- 展示解析出的多个商品标题（对应 titleEn 字段）、类目（对应 catDesc 字段），按照每个商品占用一行，每个字段一列的方式展示。**禁止展示其他信息。** 交期信息不单独作为表格列展示，而是包含在预览组件中，由预览组件内部呈现。
- **展示示例（假设第 2 步返回的 `category_key` 为 `abc123`）：**

  | 序号 | 商品标题 | 类目 | 操作 |
    |------|----------|------|------|
  | 1 | Mini Exercise Bike | Sports & Entertainment | <product-preview>{"id": "abc123-1"}</product-preview> |
  | 2 | Silicone Baking Mold | Kitchen & Dining | <product-preview>{"id": "abc123-2"}</product-preview> |

- **"操作"列生成规则：**
  1. 获取第 2 步返回的 `category_key`
  2. 将 category_key 与当前行的序号用 `-` 拼接，如 `{category_key}-{序号}`
  3. 按 `<product-preview>{"id": "{拼接值}"}</product-preview>` 格式输出
- **必须等待用户明确确认** 后才能继续。
- 如果用户拒绝，终止流程并确认。

> **重要:** 此步骤不调用任何 MCP 工具。未经用户明确确认，绝不可进入发品流程。

### 第 4 步：用户修改数据合并

如果用户没有修改内容，直接执行第 5 步。
如果用户修改了商品内容，按以下子步骤执行数据合并。

> **核心原则：** 所有大 JSON 数据通过文件 I/O 流转，禁止将完整商品 JSON 作为 shell CLI 字符串参数传递。AI 仅传递文件路径和小型 patch JSON，避免在内存中转发大 JSON 导致字段丢失。

#### 4.1 基准商品提取

使用 `merge_json.py` 的 `--index` 参数从 JSON 数组中程序化提取指定商品，AI 不在内存中操作数组：

```bash
python3 reference/scripts/merge_json.py <工作目录>/infer_category_result.json '{}' --index <N-1> --output <工作目录>/base_product_<N>.json
```

- `N` 为用户修改的商品序号（1-based），`--index` 接收 0-based 索引，传 `N-1`。
- `'{}'` 是空 patch（仅 2 字节），效果等同于"仅提取，不修改"。
- **提取成功（退出码 0）：** 基准商品已写入 `base_product_<N>.json`，进入 4.2 步。
- **提取失败（退出码 1）：** 文件不存在或索引越界，向用户报告 stderr 中的错误信息并终止本步骤。

#### 4.2 AI 意图映射（生成 patch）

用户的修改请求通常是自然语言描述（如"把标题改成 XXX"、"价格改为 10 美元"），需要通过 AI 将自然语言映射为 JSON patch（仅包含需要修改的字段），而非重新生成完整 JSON。

> **🌟 PawCore SOP 自动补全：**
> 如果工作目录下存在 `PawCore_Publishing_SOP.md`，AI 在生成 patch 时，必须**自动包含**以下字段，无需用户额外要求：
> - `"mainImgUrlList.imageList[4].imgUrl"`: `"https://sc02.alicdn.com/kf/A0f3c3b0a144d4fcd90534f3e8e0cb4adD.png"`
> - `"mainImgUrlList.imageList[5].imgUrl"`: `"https://sc02.alicdn.com/kf/Abdf1735a1d234ef89e3a90258b975731B.png"`
> - `"minQuantity"`: `50` (除非素材中明确指定了更低的起订量)

**执行流程：**

1. 使用 Read 工具读取 `<工作目录>/base_product_<N>.json`，获取基准商品内容用于理解上下文。
2. 使用以下 prompt 调用大模型完成映射：

> **System:** 你是一个 JSON patch 生成助手。你的任务是根据用户的自然语言修改请求，输出一个 **扁平 JSON patch 对象**，仅包含需要修改的字段。程序会将 patch 合并到基准 JSON 上，因此你 **不需要也不应该** 输出完整 JSON。
>
> **⚠️ 最高优先级原则——严禁幻想：**
> - **用户没有明确要求修改的字段，绝对不允许出现在 patch 中。** patch 中的每一个 key 都必须能直接溯源到用户本次修改请求中的某句话。
> - 禁止"顺便优化"、"顺便修正"、"顺便补全"任何用户未提及的字段。
> - 禁止修改基准 JSON 中已有字段的格式、大小写、编码、语种、数值精度等，除非用户明确要求。
> - 如果无法确定用户意图对应哪个字段路径，输出空对象 `{}` 并在外层说明原因，而不是猜测。
>
> **patch 格式：**
> - patch 是一个扁平的 JSON 对象，每个 key 是点分隔的字段路径，value 是新值。
> - 对象用点号分隔：`"price.priceType": "FIXED_PRICE"`
> - 数组元素用中括号索引：`"price.ladderPriceList[0].unitPrice": 55`
> - 深层嵌套依次拼接：`"productSkuList[0].skuAttrDTOList[1].valueDTOList[0].valueStandardName": "Navy Blue"`
> - 要删除某个字段，将其值设为 `null`：`"ladderPeriodList": null`
> - 要替换整个数组或对象，直接赋完整值：`"price.ladderPriceList": [{"unitPrice": 10, "minQuantity": 100}]`
>
> **规则：**
> 1. **只输出用户明确要求修改的字段路径和新值**，不要输出未修改的字段。**如果用户只说"改标题"，patch 中只能有标题相关字段；如果用户只说"改价格"，patch 中只能有价格相关字段。禁止触碰用户未提及的任何字段。**
> 2. 输出必须是合法的 JSON 对象，不能包含注释或省略号。
> 3. 如果用户请求修改的字段在基准 JSON 中不存在，使用最合理的路径新增（路径中的中间层级必须已存在于基准 JSON 中）。
> 4. 如果用户请求删除某个字段，将其值设为 `null`。
> 5. 修改标题时，`title` 和 `titleEn` 必须同步修改，且两个字段都必须出现在 patch 中。**语言规则（严格遵守）：`title` 字段固定存放中文标题，`titleEn` 字段固定存放英文标题，不可颠倒。** 无论用户提供的是中文还是英文，都需要翻译生成另一种语言的版本，确保 `title` 为中文、`titleEn` 为英文。
>    - 用户输入中文"豪华天鹅绒沙发" → `"title": "豪华天鹅绒沙发"`, `"titleEn": "Luxury Velvet Sofa"`
>    - 用户输入英文"Luxury Velvet Sofa" → `"title": "豪华天鹅绒沙发"`, `"titleEn": "Luxury Velvet Sofa"`
> 6. 修改价格时，需保持 price.priceType 与实际价格结构的一致性（FIXED_PRICE 对应 fixedPrice，LADDER_PRICE 对应 ladderPriceList，RANGE_PRICE 对应 minPrice/maxPrice）。如果需要同时修改价格类型和价格列表，两者都要出现在 patch 中。
> 7. 修改图片时，imgUrl 必须以 `https://` 开头，type 必须为以下之一：whiteBackgroundImage、sceneImage、detailImage、moreStylesImage、other。
> 8. ladderPriceList 和 ladderPeriodList 中的 minQuantity 不得小于商品的 minQuantity（起订量）。
> 9. 修改或新增交期（交货期/生产周期/lead time/delivery time）时，映射到 `ladderPeriodList` 字段。该字段为阶梯交期数组，格式为：
>    `"ladderPeriodList": [{"minQuantity": <起订量>, "maxQuantity": <最大量>, "processPeriod": <天数>}]`
>    - `processPeriod` 为整数，单位为天。如果用户说"交期 10 天"，则 `processPeriod` 为 10。
>    - `minQuantity` 必须 >= 商品的 `minQuantity`（起订量）。如果基准 JSON 中有 `minQuantity`，使用该值作为第一个阶梯的 `minQuantity`；如果没有，默认为 1。
>    - 如果用户只提供单一交期（如"10 天"），生成单个阶梯元素，`maxQuantity` 可省略。
>    - 如果用户提供多个阶梯交期（如"100 件以内 10 天，100 件以上 15 天"），按区间生成多个阶梯元素。
>    - 如果基准 JSON 中已存在 `ladderPeriodList`，整体替换为新值。
> 10. 仅输出 patch JSON 对象，不要输出任何解释文字。
>
> **禁止示例（以下行为全部违规）：**
> - 用户说"把标题改成 XXX" → patch 中出现了 `description`、`price` 等标题以外的字段 ❌
> - 用户说"价格改为 10 美元" → patch 中出现了 `title`、`titleEn` 等价格以外的字段 ❌
> - 用户没提及任何修改 → 输出了非空 patch ❌
> - 基准 JSON 中 `title` 为 "沙发"，用户只改价格 → patch 中出现 `"title": "沙发"` 重复原值 ❌
>
> **patch 输出示例（仅供格式参考）：**
> ```json
> {
>   "title": "豪华天鹅绒沙发",
>   "titleEn": "Luxury Velvet Sofa",
>   "price.ladderPriceList[0].unitPrice": 55
> }
> ```
>
> **交期 patch 示例：**
> 用户说"交期 10 天"（假设基准 JSON 中 minQuantity 为 100）：
> ```json
> {
>   "ladderPeriodList": [{"minQuantity": 100, "processPeriod": 10}]
> }
> ```
> 用户说"100 件以内 7 天，100 件以上 15 天"（假设基准 JSON 中 minQuantity 为 50）：
> ```json
> {
>   "ladderPeriodList": [{"minQuantity": 50, "maxQuantity": 100, "processPeriod": 7}, {"minQuantity": 101, "processPeriod": 15}]
> }
> ```
>
> **基准 JSON（只读参考，不要复制到输出中）：**
> ```json
> {读取到的base_product_<N>.json内容}
> ```
>
> **用户修改请求：**
> {用户的自然语言修改描述}

3. 将 AI 返回的 JSON 解析为 **patch 对象（patchJSON）**。如果 AI 返回的内容无法解析为合法 JSON 对象，向用户报告解析错误并请求重新描述修改内容。
4. **patch 键校验（反幻想守卫）：** 逐一检查 patchJSON 中的每个顶层 key，确认该 key 对应的修改能在用户的自然语言请求中找到明确依据。如果发现任何无法溯源到用户请求的 key，**必须将其从 patchJSON 中删除**，然后继续。如果删除后 patchJSON 为空对象 `{}`，说明 AI 完全幻想，向用户确认是否确实需要修改。

   **⚠️ 重要：用户使用自然语言描述，patch 使用 JSON 字段名，两者经常不同。校验时必须参照以下映射表判断溯源关系，而非仅做字面匹配：**

   | 用户可能的自然语言表述 | 对应的 patch 字段名 |
   |---|---|
   | 标题、名称、产品名 | `title`、`titleEn` |
   | 价格、单价、报价 | `price`、`price.fixedPrice`、`price.ladderPriceList`、`price.priceType` 等 |
   | 起订量、最小订购量、MOQ | `minQuantity` |
   | 交期、交货期、生产周期、lead time、delivery time | `ladderPeriodList` |
   | 图片、主图、详情图 | `mainImgUrlList`、`description.imageList` |
   | 描述、详情、产品描述 | `description` |
   | SKU、规格、变体 | `productSkuList` |
   | 属性、产品属性 | `attrDTOList` |

   只要用户请求中的语义能对应到上述某个字段，该 patch key 就是合法的，**不得删除**。
5. 使用 Write 工具将校验后的 patchJSON 写入 `<工作目录>/patch_<N>.json`。

#### 4.3 程序化合并

使用 `merge_json.py` 将 patch 无损地合并到 baseProduct 上，所有输入输出均通过文件路径传递：

```bash
python3 reference/scripts/merge_json.py <工作目录>/base_product_<N>.json <工作目录>/patch_<N>.json --output <工作目录>/merged_<N>.json
```

- **合并成功（退出码 0）：** 合并结果已写入 `merged_<N>.json`，进入 4.4 步。
- **合并失败（退出码 1）：** stderr 输出错误信息（如路径不存在、数组越界等）。将错误信息展示给用户，回到 4.2 步让 AI 重新生成 patch，最多重试 **2 次**。

#### 4.4 修改后校验

传入合并结果、基准文件和 patch 文件，同时进行结构校验和 **diff 校验**（检测字段丢失与意外新增）：

```bash
python3 reference/scripts/validate_output.py --mode merge --base <工作目录>/base_product_<N>.json --patch <工作目录>/patch_<N>.json <工作目录>/merged_<N>.json
```

- **校验通过（PASS）：** 进入 4.5 步调用 merge_material。
- **校验失败（FAIL）：** 校验错误可能包含以下类型：
  - `[diff] field lost` — 基准 JSON 中的字段在合并后丢失了（patch 未删除该字段），说明 patch 有误（可能整体替换了某个对象而非精确修改子字段）。
  - `[diff] unexpected field added` — 合并后出现了基准和 patch 中都没有的字段。
  - 其他结构性错误（缺少必填字段、类型错误等）。
  
  将校验错误信息展示给用户，重新回到 4.2 步让 AI 修正 patch，最多重试 **2 次**（与 4.3 的重试次数共享，总计最多 2 次重试）。**如果错误包含 `[diff] field lost` 类型，AI 在重新生成 patch 时必须使用精确的点分路径（如 `"price.fixedPrice": 10`）而非替换整个父对象（如 `"price": {...}`）。** 如果 2 次重试后仍失败，向用户报告具体校验错误，终止本步骤。

#### 4.5 调用 merge_material

1. 使用 Read 工具读取 `<工作目录>/merged_<N>.json`，获取校验通过的商品 JSON。
2. 使用第 2 步保存的 `key` 作为 `materialTairKey`，使用用户修改的商品序号作为 `materialIndex`，读取到的 JSON 内容作为 `fixedMaterial`，调用 `merge_material` 进行数据合并。

- **入参:**
  - `materialTairKey` — 第 2 步返回的 category_key（如果之前已通过 merge_material 更新，则使用更新后的值）
  - `materialIndex` — 用户修改的商品序号，比如修改的第 1 个商品，materialIndex = 1，不要写成 materialIndex = 0。
  - `fixedMaterial` — 从 `merged_<N>.json` 读取的 JSON 字符串（这是整个流程中 AI 唯一一次传递完整商品 JSON，通过 MCP 协议传递，无 shell 长度限制）
- **返回:** `AiResponse<String>`
- **结果判断（通过返回结果的 `model` 字段判断）:**
  - **数据合并成功（`model` 非空）：** **必须将 `model` 的值保存下来，用于更新 `category_key`。** `merge_material` 返回的 `model` 值可能是包含合并后数据的新 tair key，后续所有需要 `category_key` 的步骤（第 5 步 `infer_prop`、再次修改时的 `merge_material`）都必须使用这个更新后的值，而非第 2 步的原始 `category_key`。**更新完成后，进入 4.6 步展示合并结果。**
  - **数据合并失败（`model` 为空）：** 向用户报告返回结果中的具体错误信息。

#### 4.6 展示合并结果（强制，不可跳过）

> **⚠️ 此步骤为强制执行步骤。** 每次执行完 4.5（merge_material 成功）后，必须执行 4.6 向用户展示合并后的结果并等待确认。**严禁在未展示合并结果、未获得用户明确确认的情况下进入第 5 步或后续任何发品流程。**

**数据来源：** 对于已修改的商品，必须使用 Read 工具读取 `<工作目录>/merged_<N>.json` 获取修改后的商品数据（标题、类目等字段），禁止使用内存中的旧数据或原始 `infer_category_result.json` 的内容。对于未修改的商品，使用第 3 步展示时的原始数据。

展示所有商品信息，同时展示一个修改状态列，标识当前商品是否修改过。交期信息不单独作为表格列展示，而是包含在预览组件中，由预览组件内部呈现。

| 序号 | 商品标题 | 类目 | 操作 | 修改状态 |
  |------|----------|------|------|------|
| 1 | Mini Exercise Bike | Sports & Entertainment | <product-preview>{"id": "abc123-1"}</product-preview> | ✅ 已合并修改 |
| 2 | Silicone Baking Mold | Kitchen & Dining | <product-preview>{"id": "abc123-2"}</product-preview> | 未修改 |


- **必须等待用户明确确认** 后才能继续。不可自动跳过，不可将展示和确认合并到其他步骤中。
- 如果用户拒绝，终止流程并确认。
- 如果用户继续修改商品内容，按照用户修改的内容继续执行第 4 步（从 4.1 开始）。
- **只有用户明确确认后**，才能进入第 5 步。

> **重要:** 未经用户明确确认，绝不可进入第 5 步及后续发品流程。此处为整个发品链路的最后确认关卡。

### 第 5 步：属性映射

> **前置条件：** 必须已通过第 3 步（用户未修改时）或第 4.6 步（用户修改后）获得用户的明确确认。如果用户执行了第 4 步修改但尚未在 4.6 步确认，禁止进入本步骤。

用户确认后，调用 `infer_prop` 进行属性映射。**⚠️ 如果第 4 步执行过 `merge_material`，必须使用 `merge_material` 返回的更新后 `category_key`（即第 4.5 步保存的 `model` 值），而非第 2 步的原始 `category_key`。** 如果用户没有修改（跳过了第 4 步），则使用第 2 步的原始 `category_key`。

- **入参:**
  - `material` — 更新后的 `category_key`（如上所述），**注意：传参时必须确保 `material` 的值为字符串类型（用双引号包裹），否则工具调用会失败。**
- **返回:** `AiResponse<Map<String, String>>` — 返回结果的 `model` 字段为 `Map<String, String>` 类型，固定只有 1 个键值对：
  - **key**: 叫做`property_key`，记住：这里不要按照 property_key 去提起内容，要将map的唯一key拿出来作为property_key。**必须将其保存为独立变量 `PROPERTY_KEY`，用于第 8 步的 `productInfoForMaterial` 入参。严禁将其与第 2 步的 `category_key` 混淆——两者虽然都是 tair key 字符串，但来源和用途完全不同。**
  - **value**: 存入 tair 的内容，格式参考 reference/infer_category_result.json
- **结果判断（通过返回结果的 `model` 字段判断）:**
  - **属性映射成功:（`model` 非空）**
  - **属性映射失败: 向用户报告返回结果中的具体错误信息。**

## 第 6 步：参数完整性校验

> **前置条件：** 必须在第 5 步属性映射成功后执行。本步骤在调用发品预检 MCP 之前，对每个待发布商品进行参数完整性校验，确保关键字段不为空。

使用第 5 步 `infer_prop` 返回的 `value`（即属性映射结果的 JSON 数组）作为校验数据源，对数组中的**每个商品**逐一检查以下必填项：

#### 校验项

| 序号 | 校验项 | 校验规则 | 对应字段 |
|------|--------|----------|----------|
| 1 | 商品图片 | 每个商品至少包含一张图片（不区分主图/细节图/详情图）。检查 `mainImgUrlList.imageList` 和 `description.imageList` 中是否至少有一张有效图片（`imgUrl` 非空且以 `https://` 开头） | `mainImgUrlList.imageList`、`description.imageList` |
| 2 | 商品标题 | `titleEn` 字段不能为空字符串、null 或缺失 | `titleEn` |
| 3 | 属性列表 | `attrDTOList` 字段不能为空数组、null 或缺失，至少包含一个属性项 | `attrDTOList` |

#### 校验流程

1. 遍历属性映射结果中的每个商品，逐一执行上述 3 项校验。
2. 将所有校验不通过的商品及其缺失项汇总为结构化列表，**一次性展示**给用户。
3. **展示示例：**

   > 以下商品存在必填参数缺失，请补全后继续：
   >
   > | 序号 | 商品标题 | 缺失项 | 补全建议 |
   > |------|----------|--------|----------|
   > | 1 | （标题为空） | 商品标题、商品图片 | 请提供商品英文标题，并上传至少一张商品图片 |
   > | 3 | Silicone Baking Mold | 属性列表 | 请补充商品属性信息（如材质、尺寸等） |

4. **等待用户补全**：用户可以通过自然语言描述补充缺失信息（如“第 1 个商品标题改为 XXX，图片用 https://...”），按照第 4 步的修改合并流程（4.1 → 4.5 → **4.6**）处理用户补全的数据。**必须执行 4.6 展示合并结果并获得用户确认后**，才能重新执行第 6 步校验。
5. **校验通过条件：** 所有商品的 3 项校验均通过后，方可进入第 7 步。
6. **最多重试 3 次**（即总共最多执行 4 次校验）。如果第 4 次校验仍有商品不通过，向用户报告具体缺失项并**终止流程**。

### 第 7 步：调用发品预检 MCP

用户确认后，调用 `product_generate_precheck`，验证解析后的商品是否满足发品条件。

- **入参:**
  - `totalCount` — 待发布商品总数（从第 2 步解析结果中获取的 `totalCount`）
  - `abilityCode` — **固定值** `materialProductGenerate`
- **返回:** `ResultDTO<AgentPreCheckResultDTO>` — 包含预检结果
- **结果判断:**
  - **预检通过:** 进入第 8 步。
  - **预检不通过:** 向用户展示所有不通过原因的结构化列表，提供可操作的修改建议。**不得继续发品。**

### 第 8 步：启动素材包发品

预检通过后，调用 `icbu_product_generate_by_material`，启动异步发品流程。

- **入参:**
  - `productInfoForMaterial` — **⚠️ 必须使用第 5 步保存的 `PROPERTY_KEY`（即 `infer_prop` 返回的 property_key），严禁使用第 2 步 `infer_category` 返回的 `category_key`。** 这两个 key 来自不同步骤、含义完全不同：`category_key` 是类目预测结果，`PROPERTY_KEY` 是属性映射结果。使用错误的 key 将导致发品失败。
- **返回:** `ResultDTO<String>` — 返回值中包含 `taskId`
- **调用后处理:** 从返回结果的 `data` 字段中提取 `taskId`，保存用于第 9 步轮询。

### 第 9 步：轮询发品结果

使用第 8 步返回的 `taskId`，调用 `product_generate_query_task_list` 轮询发品结果，追踪发品进度。

- **入参:**
  - `taskId` — **必须**从第 8 步 `icbu_product_generate_by_material` 返回结果的 `data` 字段中提取（数值类型）。禁止使用 memory、历史会话或其他来源的 taskId。
- **返回:** `ResultDTO<List<ProductTaskDTO>>` — 包含多个发品子任务的状态和结果详情。
- **轮询策略:** 每 **5 秒** 调用一次此 MCP，最多 **200 次**（约 16 分钟）。
- **状态判断:** 每次轮询后，遍历返回的 `List<ProductTaskDTO>`，检查每个子任务的 `status` 字段：
  - **`status = 2`:** 任务完成
  - **`status = 1`:** 任务还在执行中
  - **`status = -1`:** 任务执行失败
- **根据 `status` 判断是否继续轮询:**
  - **所有子任务的 `status` 均为 `2`:** 全部发品完成，停止轮询，进入商品 ID 解析和结果呈现阶段。
  - **存在任一子任务的 `status` 为 `1`:** 任务仍在处理中，继续轮询。每隔 30 秒向用户同步进度（如 `completedTaskCount` / `actualTotalTaskCount`）。
  - **存在子任务的 `status` 为 `-1`:** 向用户报告失败的子任务信息。若仍有其他子任务在执行中（`status = 1`），继续轮询直到所有子任务结束。
  - **超时（200 次后仍未完成）:** 提示用户任务可能仍在后台运行，建议稍后查看。
- **商品 ID 解析（所有子任务完成后）:** 对每个 `status = 2` 的 `ProductTaskDTO` 执行以下操作：
  1. **仅关注 `output` 字段**，忽略其他字段，避免因返回数据量过大导致解析失败
  2. 获取 `output["materialPublish_saveDraft"]`
  3. 从中获取 `["data"]`
  4. 提取 `productId`
  5. 收集所有成功子任务的 `productId`，汇总为 `product_id` 列表

### 第 10 步：向用户提供信息

发品成功后，向用户提供以下信息：

1. **已发布商品数量**
2. 展示发布商品的信息，**仅包括商品ID、发布状态，禁止展示商品标题和类目。**
- **展示示例：**

| 序号 | 商品ID | 发布状态 |
  |------|--------|----------|
| 1 | [1601737818311](https://post.alibaba.com/product/publish.htm?pubAction=draft&itemId=1601737818311) | ✅ 成功 |
| 2 | [1601737818310](https://post.alibaba.com/product/publish.htm?pubAction=draft&itemId=1601737818310) | ✅ 成功 |


3. **警告或备注**（如发品过程中产生的异常信息）
4. **常态化引导文案：**
   > 商品已以草稿形式成功发布到 Alibaba.com 国际站。您可以前往卖家后台[「商品管理」](https://hz-productposting.alibaba.com/product/products_manage.htm#/product/sketch/1-10/ydtState=&groupId=&boutiqueTag=&productKeyword=&ownerMemberId=&gmtModifiedFrom=&gmtModifiedTo=&bkGmtModified=&gmtCreatedFrom=&gmtCreatedTo=&bkGmtCreate=&categoryId=&displayStatus=all&isToAddSpecific=&redModel=&ydtSearchKey=&isWindowProduct=false&isGoods=false&isPrivate=false&isVideo=false&isSpecific=false&gmtModified=desc&subject=&size=10&productId=&noFreightCost=&tradeType=&detailType=&powerScoreLayer=&isManualEdit=&isCountry=&isOriginal=&dropShipping=&qualityScore=&hasRadarRiskTask=&notBusinessCategoryProduct=false&isSemiManaged=false&productSource=&riskCountry=&overseaStockType=&gpsrFilter=&deliveryProduct=&lightCustom=&semiManagedType=&hasTariffs=&designAndSampleFilter=&samplingType=&uiAdvanceSearch=false)中查看和编辑这条草稿商品，确认无误后正式上架。


**商品编辑链接** 将编辑链接以超链接的方式放到商品ID上（禁止展示商品标题）。

- **链接拼接规则（必须严格遵守）：**
  1. **域名固定为** `post.alibaba.com`，严禁使用 `hz-productposting.alibaba.com` 或其他域名
  2. **路径固定为** `/product/publish.htm`，严禁使用 `/product/posting.htm` 或其他路径
  3. **参数固定为** `?pubAction=draft&itemId=${product_id}`，严禁添加 `spm` 或其他额外参数
  4. **完整链接格式**：`https://post.alibaba.com/product/publish.htm?pubAction=draft&itemId=${product_id}`
  5. **如果获取不到 `product_id`**，该商品ID不做超链接，保持纯文本显示

- **正确示例：**
  - 有 product_id：`[1601737818311](https://post.alibaba.com/product/publish.htm?pubAction=draft&itemId=1601737818311)`
  - 无 product_id：`1601737818311`（纯文本，无超链接）

- **错误示例（严禁出现）：**
  - ❌ `hz-productposting.alibaba.com/product/posting.htm?spm=...`
  - ❌ `post.alibaba.com/product/posting.htm?itemId=...`
  - ❌ `post.alibaba.com/product/publish.htm?pubAction=draft&itemId=...&spm=...`

在有多个商品的时候，一定要将每个品的编辑链接都做处理，不要丢失超链接。



流程中的所有状态更新使用清晰的结构化格式展示。

发品成功后删除`<工作目录>`文件夹。
