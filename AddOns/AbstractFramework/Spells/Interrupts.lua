---@class AbstractFramework
local AF = _G.AbstractFramework

local IsSpellKnown = IsSpellKnown
local GetSpellCooldown = C_Spell.GetSpellCooldown

local function GetGCD()
    return GetSpellCooldown(61304).duration
end

local INTERRUPT_SPELLS = {
    -- true: check gcd
    WARRIOR = {
        [6552] = false, -- 拳击
    },
    PALADIN = {
        [96231] = false, -- 责难
        [31935] = true, -- 复仇者之盾
    },
    HUNTER = {
        [187707] = false, -- 压制
    },
    ROGUE = {
        [1766] = false, -- 脚踢
    },
    PRIEST = {
        [15487] = false, -- 沉默
    },
    DEATHKNIGHT = {
        [47528] = false, -- 心灵冰冻
    },
    SHAMAN = {
        [57994] = false, -- 风剪
    },
    MAGE = {
        [2139] = false, -- 法术反制
    },
    WARLOCK = {
        [119910] = false, -- 法术封锁
        [119914] = false, -- 巨斧投掷
    },
    MONK = {
        [116705] = false, -- 切喉手
    },
    DRUID = {
        [106839] = false, -- 迎头痛击
        [78675] = false, -- 日光术
    },
    DEMONHUNTER = {
        [183752] = false, -- 瓦解
    },
    EVOKER = {
        [351338] = false, -- 镇压
    },
}

local known_spells = {}

local function SPELLS_CHANGED()
    wipe(known_spells)
    for spell, checkGCD in pairs(INTERRUPT_SPELLS[AF.player.class]) do
        if IsSpellKnownOrOverridesKnown(spell) then
            known_spells[spell] = checkGCD
        end
    end
end

local timer
local function DELAYED_SPELLS_CHANGED()
    if timer then timer:Cancel() end
    timer = C_Timer.NewTimer(1, SPELLS_CHANGED)
end
AF.CreateBasicEventHandler(DELAYED_SPELLS_CHANGED, "SPELLS_CHANGED")

function AF.InterruptUsable()
    for spell, checkGCD in pairs(known_spells) do
        local cd = GetSpellCooldown(spell).duration
        if cd == 0 or (checkGCD and cd == GetGCD()) then
            return true
        end
    end
end