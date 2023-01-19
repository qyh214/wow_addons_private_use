local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    {
        -- 封印魔法 (暮衛秘法師)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209404
    },
    {
        -- 狂野引爆 (法力龍鰻)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209477
    },
    {
        -- 充能光彈 (束縛能量)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 212031
    },
    {
        -- 干擾能量 (守護者傀儡)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209512,
        playerIsNotTank = true
    },
    {
        -- 蓄力潰擊 (守護者傀儡)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209495,
        playerIsNotTank = true
    },
    {
        -- 鎮壓猛襲 (暮衛守衛)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209027
    },
    {
        -- 魔焰泥坑 (燃燒軍團獵犬)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 211391
    },
    {
        -- 魔化引爆 (魔縛執行者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 211464
    },
    -- [1] 巡邏隊長葛陀
    {
        -- 掃蕩者
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 219498
    },
    {
        -- 共鳴斬擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 206580
    },
    {
        -- 共鳴斬擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 206574
    },
    -- [2] 塔莉仙‧火冠
    {
        -- 迴旋刀刃 (伊瑪庫緹雅)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209378
    },
    {
        -- 震懾波 (賈茲夏魯)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 207979
    },
    {
        -- 壓制躍擊 (賈茲夏魯)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 397903
    },
    {
        -- 煉獄爆發
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 211457
    },
    {
        -- 煉獄爆發
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 207887
    },
    -- [3] 諫言者梅朗卓斯
    {
        -- 奔騰劍擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209667
    },
    {
        -- 勁風刺擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209628
    },
    {
        -- 勁風刺擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209630
    }
}

local mapIds = {761, 762, 763}

AD:AddData("Court of Stars", mistakes, mapIds)
