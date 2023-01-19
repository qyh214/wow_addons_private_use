local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 迅捷削切 (琪瑞安黑暗軍教官)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323786
    },
    {
        -- 橫掃攻擊 (棄誓者先鋒)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 317943
    },
    {
        -- 漸弱 (萊克西斯 左邊門神)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 336420
    },
    {
        -- 衝擊 (棄誓者小隊長)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323740
    },
    {
        -- 粉碎重擊 (棄誓者小隊長)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 336447
    },
    {
        -- 強音 (棄誓者惡徒 4方向AoE)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 336444,
        playerIsNotTank = true
    },
    -- [1] 金塔拉
    {
        -- 充能之矛
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 321034
    },
    {
        -- 巨力斬擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 320966,
        playerIsNotTank = true
    },
    {
        -- 離子電漿
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 324662
    },
    {
        -- 深度連結 (連線)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 331251
    },
    {
        -- 淵染毒液 (污水)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 317626
    },
    {
        -- 弱化彈幕 (黑球)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 324370
    },
    -- [2] 溫圖納斯
    {
        -- 黑闇箭
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 324141
    },
    -- [3] 奧利菲翁
    {
        -- 蒼穹砲
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323372
    },
    {
        -- 靈魄力場
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323792
    },
    {
        -- 蓄能踐踏
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 324608,
        playerIsNotTank = true
    },
    -- [4]『猜疑楷模』德沃絲
    {
        -- 穿梭
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 323943
    },
    {
        -- 冥淵引爆
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 334625,
        noPlayerDebuff = 335805
    }
}

local mapIds = {1692, 1693, 1694, 1695}

AD:AddData("Spires of Ascension", mistakes, mapIds)
