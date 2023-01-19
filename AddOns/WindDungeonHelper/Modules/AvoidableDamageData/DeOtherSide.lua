local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes ={
    -- 小怪
    {
        -- 黑暗蓮花 (延遲爆炸紫圈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 328729
    },
    {
        -- 黑暗爆發 (亡語者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 334051
    },
    {
        -- 狂怒面具
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 342869
    },
    {
        -- 狂怒面具
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 333790
    },
    {
        -- 斬掠 (遠處旋風斬)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 333250
    },
    {
        -- 劍刃風暴
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 332672
    },
    {
        -- 噴灑精華 (哈卡之子 大紅圈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323569
    },
    {
        -- 近戰 (阿塔萊死亡行者的靈魂 追人)
        type = AD.MISTAKE.MELEE,
        npc = 170483
    },
    {
        -- 瘋狂鑽鑿 (損壞的鑽牙器 需卡視角)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 331933
    },
    {
        -- 織線 (無頭的顧客)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 332157
    },
    {
        -- 機械炸彈松鼠
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 320830
    },
    {
        -- 靈魄星風暴 (去商人路上隨機出現的小圈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323136
    },
    -- [1]『奪魂者』哈卡
    {
        -- 鮮血彈幕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323118
    },
    -- [2] 曼納斯頓夫婦
    {
        -- 回音指尖極限雷射
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323992
    },
    -- [3] 商人希夏
    {
        -- 爆炸裝置
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 320232
    },
    {
        -- 位移衝擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 320723
    },
    -- [4] 繆薩拉
    {
        -- 星能雲霧
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 335000
    },
    {
        -- 宇宙崩壞
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 325691
    },
    {
        -- 破碎領域
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 327427
    },
    {
        -- 死亡主宰
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 334913
    }
}

local mapIds = {1677, 1678, 1679, 1680}

AD:AddData("De Other Side", mistakes, mapIds)
