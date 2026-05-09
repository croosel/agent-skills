#!/bin/bash

# PawCore Agent 一键部署脚本 v1.0
# 用途：自动同步品牌资产、注入商家记忆、升级发品技能
# 仓库：https://github.com/croosel/agent-skills

set -e

# 定义路径
PROJECT_ROOT=$(pwd)
AGENT_CORE="${PROJECT_ROOT}/agent-core"
SKILLS_DIR="${AGENT_CORE}/skills/alibaba-product-publish"

echo "🚀 开始部署 PawCore 品牌资产..."

# 1. 下载品牌资产并存放到项目根目录
echo "📦 同步品牌资产 (SOP, Templates, Keywords)..."
curl -L -o PawCore_Publishing_SOP.md https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/brand_assets/PawCore_Publishing_SOP.md
curl -L -o PawCore_PDP_Template.md https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/brand_assets/PawCore_PDP_Template.md
curl -L -o PawCore_Brand_Content_Final.md https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/brand_assets/PawCore_Brand_Content_Final.md
curl -L -o PawCore_Storefront_Final_Layout.md https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/brand_assets/PawCore_Storefront_Final_Layout.md
curl -L -o PawCore_P4P_Keywords.md https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/brand_assets/PawCore_P4P_Keywords.md

# 2. 注入商家记忆 (MERCHANT_PROFILE, USER_PREFERENCES, LEARNED_RULES)
echo "🧠 注入商家记忆..."
mkdir -p "${AGENT_CORE}"
curl -L -o "${AGENT_CORE}/MERCHANT_PROFILE.json" https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/identity_profile/MERCHANT_PROFILE.json
curl -L -o "${AGENT_CORE}/USER_PREFERENCES.json" https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/identity_profile/USER_PREFERENCES.json
curl -L -o "${AGENT_CORE}/LEARNED_RULES.json" https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/identity_profile/LEARNED_RULES.json

# 3. 升级发品技能 (定制化逻辑)
if [ -d "$SKILLS_DIR" ]; then
    echo "🛠️ 升级发品技能逻辑..."
    curl -L -o "${SKILLS_DIR}/SKILL.md" https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/custom_skills/alibaba-product-publish/SKILL.md
    mkdir -p "${SKILLS_DIR}/reference"
    curl -L -o "${SKILLS_DIR}/reference/url-publish.md" https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/custom_skills/alibaba-product-publish/reference/url-publish.md
    curl -L -o "${SKILLS_DIR}/reference/material-publish.md" https://raw.githubusercontent.com/croosel/agent-skills/main/PawCore/custom_skills/alibaba-product-publish/reference/material-publish.md
else
    echo "⚠️ 未发现发品技能目录，跳过技能升级。请确保已安装 alibaba-product-publish 技能。"
fi

echo "✅ PawCore 品牌部署完成！"
echo "👉 现在你可以直接对 Agent 说：'按照 PawCore SOP 发布这个产品：[1688链接]'"
