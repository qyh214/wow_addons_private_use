local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 裂隙衝擊 (傳送門法師佐洪)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355306
    },
    {
        -- 震擊地雷 (指揮官佐發)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355476
    },
    {
        -- 致命武力 (指揮官佐發)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355487
    },
    {
        -- 震光屏障 (環境)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355502
    },
    {
        -- 鎮壓猛襲 (市場保安官)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355638
    },
    {
        -- 干擾手榴彈 (海關警衛)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355903
    },
    {
        -- 光束接合者 (武裝監督者, 『追蹤者』佐寇司)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 356011
    },
    {
        -- 腐爛的食物 (脫序的顧客)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 356482
    },
    {
        -- 聖光裂片撤退 (集團幫派)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 357019
    },
    -- [1] 佐菲克斯
    {
        -- 武裝保全
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 348366
    },
    -- [2] 大展示廳
    {
        -- 飢餓之握 (阿克魯斯)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 349663
    },
    {
        -- 宏偉吞噬 (阿克魯斯)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 349801
    },
    {
        -- 靈魄引爆 (亞奇力特)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 349999
    },
    {
        -- 散熱震盪 (亞奇力特)
        -- 測試 (可能無法避免)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 351070
    },
    {
        -- 旋風之滅 (溫札‧金熔)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 350090
    },
    -- [3] 佐戈隆
    {
        -- 控場
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 350921
    },
    {
        -- 壓制火光
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 355439
    },
    {
        -- 不許進入！
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 357799
    },
    -- [4] 郵務主管
    {
        -- 灑出的液體
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 346329
    },
    -- [5] 索阿茲米
    {
        -- 殊離之環
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 347481
    }
}

local mapIds = {1989, 1990, 1991, 1992}

AD:AddData("Tazavesh: Streets of Wonder", mistakes, mapIds)
