local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 秘法之雨 (錮法權杖)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388884
    },
    {
        -- 裂隙吐息 (秘法劫毀者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388956
    },
    {
        -- 裂隙吐息 (秘法劫毀者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388957
    },
    {
        -- 裂隙吐息 (秘法劫毀者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388958
    },
    {
        -- 致命強風 (守護者哨衛)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 378011
    },
    {
        -- 俯衝轟炸 (衛地鷹)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 377516
    },
    {
        -- 俯衝轟炸 (鷹王)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 377524
    },
    {
        -- 狂風 (鷹王)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 377383
    },
    {
        -- 種子引爆 (暗邪鞭笞者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 390918
    },
    {
        -- 星界旋風 (阿爾蓋薩回音騎士)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 387932
    },
    -- [1] 維薩穆斯
    {
        -- 秘法光球
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 385970
    },
    {
        -- 腐敗法力
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 386201
    },
    {
        -- 秘法裂縫
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388546
    },
    {
        -- 魔爆術
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 385958,
        playerIsNotTank = true
    },
    -- [2] 克若絲
    {
        -- 壓制狂風
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 377034
    },
    {
        -- 火焰風暴 (烈火球門)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 376449
    },
    {
        -- 徘徊颶風 (龍捲風)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 393122
    },
    -- [3] 生長過盛的古樹
    {
        -- 生長
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388799
    },
    {
        -- 枝條生長
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388625
    },
    -- [4] 朵拉苟莎的回音
    {
        -- 能量真空
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388822
    },
    {
        -- 星界之息
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 374361
    },
    {
        -- 秘法裂隙
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388902
    },
    {
        -- 能量爆發
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388996
    }
}

local mapIds = {2097, 2098, 2099}

AD:AddData("Algeth'ar Academy", mistakes, mapIds)
