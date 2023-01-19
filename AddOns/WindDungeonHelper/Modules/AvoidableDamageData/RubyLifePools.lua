local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 挖掘衝擊 (原始重戰士)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372696
    },
    {
        -- 鋸齒大地 (原始重戰士)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372697
    },
    {
        -- 岩石導彈 (洪荒大地守衛)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 373458
    },
    {
        -- 熾炎衝刺 (挑戰者德拉哈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372088
    },
    {
        -- 熾炎衝刺 (挑戰者德拉哈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372796
    },
    {
        -- 風暴之息 (雷首蜥蜴)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 391727
    },
    {
        -- 火息術 (火喉)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 391724
    },
    {
        -- 燃盡 (火縛毀滅者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 373614
    },
    {
        -- 熔火之鋼 (小焦焰)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 385292
    },
    {
        -- 烈焰之地 (小焦焰)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 378968
    },
    {
        -- 榮耀之火 (洪荒使者舞焰者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 373973
    },
    {
        -- 榮耀之火 (洪荒使者舞焰者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 373977
    },
    {
        -- 榮耀之火 (洪荒使者舞焰者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 373972
    },
    {
        -- 轟雷引爆 (洪荒雷雲)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 392399
    },
    {
        -- 爍火 (烈焰傳導者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 392399,
        noPlayerDebuff = 392451
    },
    -- [1] 梅莉卓沙‧寒磨
    {
        -- 冰雹炸彈
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 384024
    },
    -- [2] 可幾亞‧焰蹄
    {
        -- 熔岩巨石
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372811
    },
    {
        -- 熔岩巨石
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372819
    },
    {
        -- 焦土
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372820
    },
    {
        -- 火縛儀式
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372863
    },
    {
        -- 燃盡 (大怪)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 373087
    },
    -- [3] 凱拉卡及俄克哈‧風脈
    {
        -- 熾燃焰息 (凱拉卡)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 381526
    },
    {
        -- 燃焰餘燼 (凱拉卡)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 384773
    }
}
local mapIds = {2094, 2095}

AD:AddData("Ruby Life Pools", mistakes, mapIds)
