local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 易爆河豚 (暗洋魚法師)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355234
    },
    {
        -- 巨石投擲 (岸行者巨人)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355465
    },
    {
        -- 轟雷 (風鑄守護者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355581
    },
    {
        -- 充電脈衝 (風鑄守護者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355584
    },
    {
        -- 潮汐爆發 (沙漏號浪潮賢者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 356260
    },
    {
        -- 漂流之星 (絢麗觀星者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 357228
    },
    -- [1] 海布藍德
    {
        -- 淨滅火焰
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 346960
    },
    {
        -- 淨滅力場
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 346961
    },
    {
        -- 泰坦撞擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 347094
    },
    {
        -- 符文回應
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 356796
    },
    -- [2] 時光船長鉤尾
    {
        -- 無限吐息
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 347149
    },
    {
        -- 鉤尾掃擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 347151
    },
    {
        -- 火砲彈幕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 347370
    },
    {
        -- 鉤到啦！
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 354334
    },
    {
        -- 燃燒焦油
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 358947
    },
    -- [3] 索利亞
    {
        -- 能量分離
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 351101
    },
    {
        -- 極光新星
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 351646
    }
}

local mapIds = {1993, 1995, 1996, 1997}

AD:AddData("Tazavesh: So'leah's Gambit", mistakes, mapIds)