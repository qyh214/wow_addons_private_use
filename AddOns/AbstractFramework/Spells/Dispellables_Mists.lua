---@class AbstractFramework
local AF = _G.AbstractFramework

local UnitClassBase = UnitClassBase
local IsSpellKnown = IsSpellKnown
local GetSpecialization = C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo

local dispellable = {}

function AF.CanDispel(debuffType)
    if not debuffType then return end
    return dispellable[debuffType]
end

local specDispellables = {
    -- DRUID ----------------
    -- 102 - Balance
    [102] = {["Curse"] = true, ["Poison"] = true},
    -- 103 - Feral
    [103] = {["Curse"] = true, ["Poison"] = true},
    -- 104 - Guardian
    [104] = {["Curse"] = true, ["Poison"] = true},
    -- Restoration
    [105] = {["Curse"] = true, ["Magic"] = true, ["Poison"] = true},
    -------------------------

    -- MAGE -----------------
    -- 62 - Arcane
    [62] = {["Curse"] = true},
    -- 63 - Fire
    [63] = {["Curse"] = true},
    -- 64 - Frost
    [64] = {["Curse"] = true},
    -------------------------

    -- MONK -----------------
    -- 268 - Brewmaster
    [268] = {["Disease"] = true, ["Poison"] = true},
    -- 269 - Windwalker
    [269] = {["Disease"] = true, ["Poison"] = true},
    -- 270 - Mistweaver
    [270] = {["Disease"] = true, ["Magic"] = true, ["Poison"] = true},
    -------------------------

    -- PALADIN --------------
    -- 65 - Holy
    [65] = {["Disease"] = true, ["Magic"] = true, ["Poison"] = true, ["Bleed"] = true},
    -- 66 - Protection
    [66] = {["Disease"] = true, ["Poison"] = true, ["Bleed"] = true},
    -- 70 - Retribution
    [70] = {["Disease"] = true, ["Poison"] = true, ["Bleed"] = true},
    -------------------------

    -- PRIEST ---------------
    -- 256 - Discipline
    [256] = {["Disease"] = true, ["Magic"] = true},
    -- 257 - Holy
    [257] = {["Disease"] = true, ["Magic"] = true},
    -- 258 - Shadow
    [258] = {["Magic"] = true},
    -------------------------

    -- SHAMAN ---------------
    -- 262 - Elemental
    [262] = {["Curse"] = true},
    -- 263 - Enhancement
    [263] = {["Curse"] = true},
    -- 264 - Restoration
    [264] = {["Curse"] = true, ["Magic"] = true},
    -------------------------

    -- WARLOCK --------------
    -- 265 - Affliction
    -- [265] = {["Magic"] = function() return IsSpellKnown(89808, true) end},
    -- 266 - Demonology
    -- [266] = {["Magic"] = function() return IsSpellKnown(89808, true) end},
    -- 267 - Destruction
    -- [267] = {["Magic"] = function() return IsSpellKnown(89808, true) end},
    -------------------------
}

local eventFrame = CreateFrame("Frame")

if UnitClassBase("player") == "WARLOCK" then
    eventFrame:RegisterEvent("UNIT_PET")

    local timer
    eventFrame:SetScript("OnEvent", function(self, event, unit)
        if unit ~= "player" then return end

        if timer then
            timer:Cancel()
        end
        timer = C_Timer.NewTimer(1, function()
            -- update dispellable
            dispellable["Magic"] = IsSpellKnown(89808, true)
            -- texplore(dispellable)
        end)
    end)
else
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    local function UpdateDispellable()
        local specId = GetSpecializationInfo(GetSpecialization())
        dispellable = specDispellables[specId] or {}
        -- texplore(dispellable)
    end

    local timer

    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end

        if timer then timer:Cancel() end
        timer = C_Timer.NewTimer(1, UpdateDispellable)
    end)
end