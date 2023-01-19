local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 螺旋碎塊 (故障的廢料機器人)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 294890 -- TODO: 到底是哪個?
    },
    {
        -- 螺旋碎塊 (故障的廢料機器人)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 300159
    },
    {
        -- 自毀程序 (故障的廢料機器人)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 300129
    },
    {
        -- 急速射擊 (機械岡騎兵)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 301667
    },
    {
        -- B.O.R.K (廢料獵犬)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 299475
    },
    {
        -- 廢料爆炸 (活塞頭技師)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 299535
    },
    {
        -- 超U質模組：廢料火砲 (武裝爬行蛛)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 300188
    },
    {
        -- 震懾波 (廢骨惡霸)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 300427
    },
    {
        -- 爆炸 (廢骨垃圾投擲者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 300561
    },
    {
        -- 黏液波 (軟泥元素)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 300816
    },
    -- 勾巴馬克王
    {
        -- 土崩石塌
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 297283
    },
    -- 髒克
    {
        -- 劇毒波
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 297834
    },
    {
        -- 結合
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 297835
    },
    {
        -- 燃盡
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 297985
    },
    -- 崔克西和奈洛
    {
        -- 燃盡
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 298571
    },
    {
        -- 電力懸浮
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 298849
    },
    {
        -- 螺栓破擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 298940
    },
    {
        -- 油門踩到底
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 299164
    },
    {
        -- 劇烈電擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 302681
    },
    -- HK-8型空中壓制單位
    {
        -- 火砲轟擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 295536
    },
    {
        -- 排氣口爆發
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 296150
    },
    {
        -- 自體毀滅
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 296522
    },
    {
        -- 靜電迸發
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 302384
    }
}

local mapIds = {1490}

AD:AddData("Operation: Mechagon - Junkyard", mistakes, mapIds)
