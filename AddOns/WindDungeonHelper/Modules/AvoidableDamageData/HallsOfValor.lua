local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 閃電吐息 (風暴飛龍)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198888,
        playerIsNotTank = true
    },
    {
        -- 碎裂風暴 (風暴飛龍)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198903
    },
    {
        -- 充電脈衝 (風鑄哨兵)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 210875
    },
    {
        -- 轟雷 (風鑄哨兵)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199818
    },
    {
        -- 凡人劈斬 (華爾拉亞女盾侍)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199050,
        playerIsNotTank = true
    },
    {
        -- 穿透射擊 (華爾拉亞神射手)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199210
    },
    {
        -- 淨化火焰 (華爾拉亞淨化者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 192565
    },
    {
        -- 聖光爆炸 (華爾拉亞志士)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 191508
    },
    {
        -- 庇護 (『啟迪者』歐莫爾)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 192206
    },
    {
        -- 轟隆踐踏 (怒蹄公牛)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199090
    },
    {
        -- 低姿衝鋒 (金毛雄鹿)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199146
    },
    {
        -- 捕熊陷阱 (華爾拉亞陷捕者)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199337
    },
    {
        -- 諸神的黃昏 (神御之王斯寇瓦德)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 193827
    },
    {
        -- 煉獄烈焰 (神御之王斯寇瓦德召喚的元素怪)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 193702
    },
    -- [1] 海姆達爾
    {
        -- 舞動之刃
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 193234
    },
    {
        -- 靜電力場
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 193260
    },
    {
        -- 閃電球
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 188395
    },
    -- [2] 海爾珈
    {
        -- 光明之盾
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 192018,
        playerIsNotTank = true
    },
    -- [3] 芬里爾
    -- [4] 歐丁
    {
        -- 發光碎片
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198088
    },
    {
        -- 耀眼風暴
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198263
    },
    {
        -- 回饋
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198412
    }
}
local mapIds = {703, 704, 705}

AD:AddData("Halls of Valor", mistakes, mapIds)
