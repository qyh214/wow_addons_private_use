local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 致命推進 (墮落的暗刃兵)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 325523
    },
    {
        -- 罪孽震盪 (哈奇厄斯裂片)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 326440
    },
    {
        -- 急速射擊 (墮落的馴犬者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 325799
    },
    {
        -- 岩石之息
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 346866,
        playerIsNotTank = true
    },
    {
        -- 強力揮擊 (石源魔斬擊者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 326997,
        playerIsNotTank = true
    },
    -- [1]『罪污巨人』哈奇厄斯
    {
        -- 拋擲殘骸
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 322945
    },
    {
        -- 玻璃裂片
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323001,
        playerIsNotTank = true
    },
    {
        -- 折射罪光
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 324044
    },
    -- [2] 艾可隆
    {
        -- 血腥洪流
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 319702
    },
    -- [3] 至高判決者阿利茲
    {
        -- 靈魂泉
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 338013
    },
    -- [4] 宮務大臣
    {
        -- 念力碰撞
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323126
    },
    {
        -- 念力猛襲
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 329113
    },
    {
        -- 釋放磨難
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323236
    },
    {
        -- 爆發折磨
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 327885
    }
}

local mapIds = {1663, 1664, 1665}

AD:AddData("Halls of Atonement", mistakes, mapIds)
