local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 注能之地 (秘法看管者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 375649
    },
    {
        -- 樹液爆發 (冒泡小黏液)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 375591
    },
    {
        -- 晶化割裂 (水晶痛擊者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 370766
    },
    {
        -- 分刺裂片 (水晶痛擊者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 371021,
        noPlayerDebuff = 377488
    },
    {
        -- 穿刺裂片 (水晶怒靈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 370764,
        playerIsNotTank = true
    },
    {
        -- 禁忌知識 (不穩定的監管者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 371352,
        noPlayerDebuff = 377488
    },
    {
        -- 秘能猛擊 (秘法傀儡)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 387067
    },
    {
        -- 動盪威能 (星界僕從)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 374868
    },
    {
        -- 法霜吐息 (逆鱗龍人副官)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 391120,
        playerIsNotTank = true
    },
    {
        -- 空無踐踏 (魔法中和角蛙)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 386536
    },
    -- [1] 雷摩
    {
        -- 爆發裂縫
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 386660
    },
    {
        -- 爆炸烙印
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 374582
    },
    {
        -- 刺痛樹液
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 374523
    },
    -- [2] 蒼藍之刃
    {
        -- 秘法順劈斬
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 372222,
        playerIsNotTank = true
    },
    {
        -- 不穩定的魔法
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 389855
    },
    {
        -- 遠古球體
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 385579
    },
    {
        -- 遠古球體碎片
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 390462
    },
    -- [3] 泰拉許‧灰翼
    {
        -- 霜凍大地
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 387150,
        threshold = 20
    },
    {
        -- 絕對零度
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 388008,
        noPlayerDebuff = 388072
    },
    {
        -- 寒冰毀滅者
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 387152,
        noPlayerDebuff = 387151
    },
    -- [4] 安珀斯庫
    {
        -- 晶化咆哮
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 384699
    },
    {
        -- 爆裂漩渦
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 385267
    },
    {
        -- 秘法爆發
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 385078
    }
}

local mapIds = {2073, 2074, 2075, 2076, 2077}

AD:AddData("The Azure Vault", mistakes, mapIds)
