local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    {
        -- 火炮彈幕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 168514
    },
    {
        -- 火炮彈幕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 168540
    },
    {
        -- 高爆榴彈 (格羅姆卡技師)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 178299
    },
    {
        -- 燃焰之箭 (格羅姆卡火箭手)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 173149
    },
    {
        -- 燃燒箭 (格羅姆卡火箭手)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164632
    },
    {
        -- 投擲短斧 (格羅姆卡水手)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 173113
    },
    {
        -- 劍刃風暴 (格羅姆卡戰場軍官)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 167233
    },
    {
        -- 裂空順劈斬 (雷霆王牧者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 167815
    },
    {
        -- 鋸齒釘爪刺 (雷霆王牧者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 173324
    },
    {
        -- 熔岩衝擊 (鐵翼噴火者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 173517
    },
    {
        -- 熔岩彈幕 (鐵翼噴火者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 173489
    },
    -- [1] 『血肉撕裂者』諾加爾
    {
        -- 燃燒箭
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164632
    },
    {
        -- 倒鉤箭雨
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164648
    },
    {
        -- 撕碎掃擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164734
    },
    -- [2] 恐軌執行者
    {
        -- 撕碎肌腱
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 163276
    },
    {
        -- 熔岩掃擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 165152
    },
    {
        -- 熔岩掃擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 163668
    },
    -- [3] 歐席爾
    {
        --  原始突襲
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 161256
    },
    -- [4] 史庫洛克
    {
        -- 急速射擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 168348,
        noPlayerDebuff = 168398
    },
    {
        -- 爆燃
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 169129
    },
    {
        -- 劍刃風暴
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 168401
    },
    {
        -- 火砲彈幕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 168390
    },
    {
        -- 火炮彈幕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 168148
    }
}

local mapIds = {595}

AD:AddData("Iron Docks", mistakes, mapIds)
