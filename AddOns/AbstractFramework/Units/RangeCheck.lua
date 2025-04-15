---@class AbstractFramework
local AF = _G.AbstractFramework

local UnitIsVisible = UnitIsVisible
local UnitInRange = UnitInRange
local UnitCanAssist = UnitCanAssist
local UnitCanAttack = UnitCanAttack
local UnitCanCooperate = UnitCanCooperate
local IsSpellInRange = (C_Spell and C_Spell.IsSpellInRange) and C_Spell.IsSpellInRange or IsSpellInRange
local IsItemInRange = (C_Spell and C_Item.IsItemInRange) and C_Item.IsItemInRange or IsItemInRange
local CheckInteractDistance = CheckInteractDistance
local UnitIsDead = UnitIsDead
local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
-- local GetSpellTabInfo = GetSpellTabInfo
-- local GetNumSpellTabs = GetNumSpellTabs
-- local GetSpellBookItemName = GetSpellBookItemName
-- local BOOKTYPE_SPELL = BOOKTYPE_SPELL

---@type function
local UnitInSamePhase
if AF.isRetail then
    UnitInSamePhase = function(unit)
        return not UnitPhaseReason(unit)
    end
else
    UnitInSamePhase = UnitInPhase
end

local playerClass = UnitClassBase("player")

local friendSpells = {
    -- ["DEATHKNIGHT"] = 47541,
    -- ["DEMONHUNTER"] = ,
    ["DRUID"] = (AF.isWrath or AF.isVanilla) and 5185 or 8936, -- 治疗之触 / 愈合
    -- FIXME: [361469 活化烈焰] 会被英雄天赋 [431443 时序烈焰] 替代，但它而且有问题
    -- IsSpellInRange 始终返回 nil
    ["EVOKER"] = 355913, -- 翡翠之花
    -- ["HUNTER"] = 136,
    ["MAGE"] = 1459, -- 奥术智慧 / 奥术光辉
    ["MONK"] = 116670, -- 活血术
    ["PALADIN"] = AF.isRetail and 19750 or 635, -- 圣光闪现 / 圣光术
    ["PRIEST"] = (AF.isWrath or AF.isVanilla) and 2050 or 2061, -- 次级治疗术 / 快速治疗
    -- ["ROGUE"] = AF.isWrath and 57934,
    ["SHAMAN"] = AF.isRetail and 8004 or 331, -- 治疗之涌 / 治疗波
    ["WARLOCK"] = 5697, -- 无尽呼吸
    -- ["WARRIOR"] = 3411,
}

local deadSpells = {
    ["EVOKER"] = 361227, -- resurrection range, need separately for evoker
}

local petSpells = {
    ["HUNTER"] = 136,
}

local harmSpells = {
    ["DEATHKNIGHT"] = 47541, -- 凋零缠绕
    ["DEMONHUNTER"] = 185123, -- 投掷利刃
    ["DRUID"] = 5176, -- 愤怒
    -- FIXME: [361469 活化烈焰] 会被英雄天赋 [431443 时序烈焰] 替代，但它而且有问题
    -- IsSpellInRange 始终返回 nil
    ["EVOKER"] = 362969, -- 碧蓝打击
    ["HUNTER"] = 75, -- 自动射击
    ["MAGE"] = AF.isRetail and 116 or 133, -- 寒冰箭 / 火球术
    ["MONK"] = 117952, -- 碎玉闪电
    ["PALADIN"] = 20271, -- 审判
    ["PRIEST"] = AF.isRetail and 589 or 585, -- 暗言术：痛 / 惩击
    ["ROGUE"] = 1752, -- 影袭
    ["SHAMAN"] = AF.isRetail and 188196 or 403, -- 闪电箭
    ["WARLOCK"] = 234153, -- 吸取生命
    ["WARRIOR"] = 355, -- 嘲讽
}

-- local friendItems = {
--     ["DEATHKNIGHT"] = 34471,
--     ["DEMONHUNTER"] = 34471,
--     ["DRUID"] = 34471,
--     ["EVOKER"] = 1180, -- 30y
--     ["HUNTER"] = 34471,
--     ["MAGE"] = 34471,
--     ["MONK"] = 34471,
--     ["PALADIN"] = 34471,
--     ["PRIEST"] = 34471,
--     ["ROGUE"] = 34471,
--     ["SHAMAN"] = 34471,
--     ["WARLOCK"] = 34471,
--     ["WARRIOR"] = 34471,
-- }

local harmItems = {
    ["DEATHKNIGHT"] = 28767, -- 40y
    ["DEMONHUNTER"] = 28767, -- 40y
    ["DRUID"] = 28767, -- 40y
    ["EVOKER"] = 24268, -- 25y
    ["HUNTER"] = 28767, -- 40y
    ["MAGE"] = 28767, -- 40y
    ["MONK"] = 28767, -- 40y
    ["PALADIN"] = 835, -- 30y
    ["PRIEST"] = 28767, -- 40y
    ["ROGUE"] = 28767, -- 40y
    ["SHAMAN"] = 28767, -- 40y
    ["WARLOCK"] = 28767, -- 40y
    ["WARRIOR"] = 28767, -- 40y
}

-- local FindSpellIndex
-- if C_SpellBook and C_SpellBook.FindSpellBookSlotForSpell then
--     FindSpellIndex = function(spellName)
--         if not spellName or spellName == "" then return end
--         return C_SpellBook.FindSpellBookSlotForSpell(spellName)
--     end
-- else
--     local function GetNumSpells()
--         local _, _, offset, numSpells = GetSpellTabInfo(GetNumSpellTabs())
--         return offset + numSpells
--     end

--     FindSpellIndex = function(spellName)
--         if not spellName or spellName == "" then return end
--         for i = 1, GetNumSpells() do
--             local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
--             if spell == spellName then
--                 return i
--             end
--         end
--     end
-- end

---@type function
local UnitInSpellRange
if C_Spell and C_Spell.IsSpellInRange then
    UnitInSpellRange = function(spellName, unit)
        return IsSpellInRange(spellName, unit)
    end
else
    UnitInSpellRange = function(spellName, unit)
        return IsSpellInRange(spellName, unit) == 1
    end
end

local rc = CreateFrame("Frame")
rc:RegisterEvent("SPELLS_CHANGED")

local spell_friend, spell_pet, spell_harm, spell_dead
AF_RANGE_CHECK_FRIENDLY = {}
AF_RANGE_CHECK_HOSTILE = {}
AF_RANGE_CHECK_DEAD = {}
AF_RANGE_CHECK_PET = {}

local function SPELLS_CHANGED()
    spell_friend = AF_RANGE_CHECK_FRIENDLY[playerClass] or friendSpells[playerClass]
    spell_harm = AF_RANGE_CHECK_HOSTILE[playerClass] or harmSpells[playerClass]
    spell_dead = AF_RANGE_CHECK_DEAD[playerClass] or deadSpells[playerClass]
    spell_pet = AF_RANGE_CHECK_PET[playerClass] or petSpells[playerClass]

    if spell_friend and IsSpellKnownOrOverridesKnown(spell_friend) then
        spell_friend = AF.GetSpellInfo(spell_friend)
    else
        spell_friend = nil
    end
    if spell_harm and IsSpellKnownOrOverridesKnown(spell_harm) then
        spell_harm = AF.GetSpellInfo(spell_harm)
    else
        spell_harm = nil
    end
    if spell_dead and IsSpellKnownOrOverridesKnown(spell_dead) then
        spell_dead = AF.GetSpellInfo(spell_dead)
    else
        spell_dead = nil
    end
    if spell_pet and IsSpellKnownOrOverridesKnown(spell_pet) then
        spell_pet = AF.GetSpellInfo(spell_pet)
    else
        spell_pet = nil
    end
end

local timer
local function DELAYED_SPELLS_CHANGED()
    if timer then timer:Cancel() end
    timer = C_Timer.NewTimer(1, SPELLS_CHANGED)
end

rc:SetScript("OnEvent", DELAYED_SPELLS_CHANGED)

function AF.IsInRange(unit, check)
    if not UnitIsVisible(unit) then
        return false
    end

    if UnitIsUnit("player", unit) then
        return true

    elseif not check and AF.UnitInGroup(unit) then
        -- NOTE: UnitInRange only works with group players/pets
        --! but not available for PLAYER PET when SOLO
        local inRange, checked = UnitInRange(unit)
        if not checked then
            return AF.IsInRange(unit, true)
        end
        return inRange

    else
        if UnitCanAssist("player", unit) or UnitCanCooperate("player", unit) then
            if not (UnitIsConnected(unit) and UnitInSamePhase(unit)) then
                return false
            end

            if UnitIsDead(unit) then
                if spell_dead then
                    return UnitInSpellRange(spell_dead, unit)
                end
            elseif spell_friend then
                return UnitInSpellRange(spell_friend, unit)
            end

            local inRange, checked = UnitInRange(unit)
            if checked then
                return inRange
            end

            if UnitIsUnit(unit, "pet") and spell_pet then
                -- no spell_friend, use spell_pet
                return UnitInSpellRange(spell_pet, unit)
            end

        elseif UnitCanAttack("player", unit) then
            if UnitIsDead(unit) then
                return CheckInteractDistance(unit, 4) -- 28 yards
            elseif spell_harm then
                return UnitInSpellRange(spell_harm, unit)
            end
            return IsItemInRange(harmItems[playerClass], unit)
        end

        if not InCombatLockdown() then
            return CheckInteractDistance(unit, 4) -- 28 yards
        end

        return true
    end
end

---------------------------------------------------------------------
-- RangeCheck debug
---------------------------------------------------------------------
local debug = AF.CreateBorderedFrame(AF.UIParent, "AFRangeCheckDebug")
debug:SetPoint("LEFT", 300, 0)
debug:Hide()

debug.text = AF.CreateFontString(debug)
debug.text:SetJustifyH("LEFT")
debug.text:SetSpacing(5)
debug.text:SetPoint("LEFT", 5, 0)

local function GetResult1()
    local inRange, checked = UnitInRange("target")

    return "UnitID: " .. (AF.GetBestUnitIDForTarget("target") or "target") ..
        "\n|cffffff00AF.IsInRange:|r " .. (AF.IsInRange("target") and "true" or "false") ..
        "\nUnitInRange: " .. (checked and "checked" or "unchecked") .. " " .. (inRange and "true" or "false") ..
        "\nUnitIsVisible: " .. (UnitIsVisible("target") and "true" or "false") ..
        "\n\nUnitCanAssist: " .. (UnitCanAssist("player", "target") and "true" or "false") ..
        "\nUnitCanCooperate: " .. (UnitCanCooperate("player", "target") and "true" or "false") ..
        "\nUnitCanAttack: " .. (UnitCanAttack("player", "target") and "true" or "false") ..
        "\n\nUnitIsConnected: " .. (UnitIsConnected("target") and "true" or "false") ..
        "\nUnitInSamePhase: " .. (UnitInSamePhase("target") and "true" or "false") ..
        "\nUnitIsDead: " .. (UnitIsDead("target") and "true" or "false") ..
        "\n\nspell_friend: " .. (spell_friend and (spell_friend .. " " .. (UnitInSpellRange(spell_friend, "target") and "true" or "false")) or "none") ..
        "\nspell_dead: " .. (spell_dead and (spell_dead .. " " .. (UnitInSpellRange(spell_dead, "target") and "true" or "false")) or "none") ..
        "\nspell_pet: " .. (spell_pet and (spell_pet .. " " .. (UnitInSpellRange(spell_pet, "target") and "true" or "false")) or "none") ..
        "\nspell_harm: " .. (spell_harm and (spell_harm .. " " .. (UnitInSpellRange(spell_harm, "target") and "true" or "false")) or "none")
end

local function GetResult2()
    if UnitCanAttack("player", "target") then
        return "IsItemInRange: " .. (IsItemInRange(harmItems[playerClass], "target") and "true" or "false") ..
            "\nCheckInteractDistance(28y): " .. (CheckInteractDistance("target", 4) and "true" or "false")
    else
        return "IsItemInRange: " .. (InCombatLockdown() and "notAvailable" or (IsItemInRange(harmItems[playerClass], "target") and "true" or "false")) ..
            "\nCheckInteractDistance(28y): " .. (InCombatLockdown() and "notAvailable" or (CheckInteractDistance("target", 4) and "true" or "false"))
    end
end

debug:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.2 then
        self.elapsed = 0
        local result = GetResult1() .. "\n\n" .. GetResult2()
        result = string.gsub(result, "none", "|cffabababnone|r")
        result = string.gsub(result, "true", "|cff00ff00true|r")
        result = string.gsub(result, "false", "|cffff0000false|r")
        result = string.gsub(result, " checked", " |cff00ff00checked|r")
        result = string.gsub(result, "unchecked", "|cffff0000unchecked|r")

        debug.text:SetText(AF.WrapTextInColor("AF Range Check Debug (Target)", "accent") .. "\n\n" .. result)

        debug:SetSize(debug.text:GetStringWidth() + 10, debug.text:GetStringHeight() + 20)
    end
end)

debug:SetScript("OnEvent", function()
    if not UnitExists("target") then
        debug:Hide()
        return
    end

    debug:Show()
end)

SLASH_AFRANGECHECK1 = "/afrc"
function SlashCmdList.AFRANGECHECK()
    if debug:IsEventRegistered("PLAYER_TARGET_CHANGED") then
        debug:UnregisterEvent("PLAYER_TARGET_CHANGED")
        debug:Hide()
    else
        debug:RegisterEvent("PLAYER_TARGET_CHANGED")
        if UnitExists("target") then
            debug:Show()
        end
    end
end