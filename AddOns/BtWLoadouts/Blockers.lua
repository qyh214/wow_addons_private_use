--[[
    Blockers define how to handle blocking the activation of loadouts for various reasons
]]

local _, Internal = ...;
local L = Internal.L;

--[[ BASE MIXIN ]]

Internal.BlockerMixin = {}
-- Should we wait for this blocker to be done to continue or just fail
function Internal.BlockerMixin:ShouldWait()
    return false
end
function Internal.BlockerMixin:GetWaitReasonMessage()
    return nil
end
-- Is this blocker current active
function Internal.BlockerMixin:IsActive()
    return false
end
function Internal.BlockerMixin:PopupMessage()
    return nil, nil
end
function Internal.BlockerMixin:PopupMessagePartial()
    return nil, nil
end
-- Item that can be used to solve this blocker
function Internal.BlockerMixin:UsableItem()
    return nil
end
-- Returns a list of events that probably mean a change in this blocker
function Internal.BlockerMixin:GetEvents()
    return
end

--[[ COMBAT ]]

local CombatBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function CombatBlockerMixin:ShouldWait()
    return true
end
function CombatBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for combat to end"]
end
function CombatBlockerMixin:IsActive()
    return InCombatLockdown()
end

local CombatBlocker = CreateFromMixins(CombatBlockerMixin);
function Internal.GetCombatBlocker()
    return CombatBlocker;
end

--[[ MOVING ]]

local MovingBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function MovingBlockerMixin:ShouldWait()
    return true
end
function MovingBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for you to stop moving"]
end
function MovingBlockerMixin:IsActive()
    return IsPlayerMoving()
end

local MovingBlocker = CreateFromMixins(MovingBlockerMixin);
function Internal.GetMovingBlocker()
    return MovingBlocker;
end

--[[ FLYING ]]

local FlyingBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function FlyingBlockerMixin:ShouldWait()
    return true
end
function FlyingBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for you to stop flying"]
end
function FlyingBlockerMixin:IsActive()
    return IsFlying()
end

local FlyingBlocker = CreateFromMixins(FlyingBlockerMixin);
function Internal.GetFlyingBlocker()
    return FlyingBlocker;
end

--[[ TAXI ]]

local TaxiBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function TaxiBlockerMixin:ShouldWait()
    return true
end
function TaxiBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for taxi ride to end"]
end
function TaxiBlockerMixin:IsActive()
    return UnitOnTaxi("player")
end

local TaxiBlocker = CreateFromMixins(TaxiBlockerMixin);
function Internal.GetTaxiBlocker()
    return TaxiBlocker;
end

--[[ MYTHIC PLUS ]]

local MythicPlusBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function MythicPlusBlockerMixin:ShouldWait()
    return false
end
function MythicPlusBlockerMixin:PopupMessagePartial()
    return L["Cannot fully apply your loadout while within a Mythic Keystone dungeon"]
end
function MythicPlusBlockerMixin:IsActive()
    return C_ChallengeMode.IsChallengeModeActive()
end

local MythicPlusBlocker = CreateFromMixins(MythicPlusBlockerMixin);
function Internal.GetMythicPlusBlocker()
    return MythicPlusBlocker;
end

--[[ JAILER'S CHAIN ]]

local JailersChainBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function JailersChainBlockerMixin:ShouldWait()
    return true
end
function JailersChainBlockerMixin:PopupMessagePartial()
    return L["Cannot fully apply your loadout while under the effects of the Jailer's Chains"]
end
function JailersChainBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for you to be freed from the Jailer's Chains"]
end
function JailersChainBlockerMixin:IsActive()
    local GetPlayerAuraBySpellID = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID or GetPlayerAuraBySpellID
    return GetPlayerAuraBySpellID(338906) ~= nil
end

local JailersChainBlocker = CreateFromMixins(JailersChainBlockerMixin);
function Internal.GetJailersChainBlocker()
    return JailersChainBlocker;
end

--[[ RESTED TOME ]]

local talentChangeBuffs = {
    [32727] = true,
    [44521] = true,
    [226234] = true,
    [226241] = true,
    [227041] = true,
    [227563] = true,
    [227564] = true,
    [227565] = true,
    [227569] = true,
    [228128] = true,
    [248473] = true,
    [256229] = true,
    [256230] = true,
    [256231] = true,
    [321923] = true,
    [324028] = true,
    [325012] = true, -- Swolkin ability
    [338907] = true, -- Refuge of the Damned
};
local tomeLevelRequirements = {
    [141640] = {10, 50}, -- Tome of the Clear Mind
    [143780] = {10, 50}, -- Tome of the Tranquil Mind
    [143785] = {10, 50}, -- Tome of the Tranquil Mind
    [141446] = {10, 50}, -- Tome of the Tranquil Mind
    [153647] = {10, 59}, -- Tome of the Quiet Mind
    [173049] = {51, 60}, -- Tome of the Still Mind
};
local tomes = {
    141640, -- Tome of the Clear Mind
    143780, -- Tome of the Tranquil Mind
    143785, -- Tome of the Tranquil Mind
    141446, -- Tome of the Tranquil Mind
    153647, -- Tome of the Quiet Mind
    173049, -- Tome of the Still Mind
};
local function GetBestTome()
    local level = UnitLevel("player")
    for _,itemID in ipairs(tomes) do
        local count = GetItemCount(itemID);
        local minLevel, maxLevel = unpack(tomeLevelRequirements[itemID])
        if count >= 1 and minLevel <= level and maxLevel >= level then
            local name, link, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID);
            return itemID, name, link, quality, icon;
        end
    end
end

local RestedTomeBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function RestedTomeBlockerMixin:ShouldWait()
    return true
end
function RestedTomeBlockerMixin:PopupMessage()
    return L["A Rested Area or Tome is required to apply your loadout"], L["tome"]
end
function RestedTomeBlockerMixin:PopupMessagePartial()
    return L["A Rested Area or Tome is required to fully apply your loadout"], L["tome"]
end
function RestedTomeBlockerMixin:GetWaitReasonMessage()
    if not GetBestTome() then
        return L["Waiting for a rested area"]
    else
        return L["Waiting for a tome or rested area"]
    end
end
function RestedTomeBlockerMixin:IsActive()
    -- No matter how rested or tomed you are, you cant do stuff in an M+ or Torghast
    if MythicPlusBlocker:IsActive() then
        return false
    end
    if JailersChainBlocker:IsActive() then
        return false
    end
    if IsResting() then
        return false
    end

    local index = 1;
    local name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", index, "HELPFUL");
    while name do
        if talentChangeBuffs[spellId] then
            return false;
        end

        index = index + 1;
        name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", index, "HELPFUL");
    end

    return true;
end
function RestedTomeBlockerMixin:UsableItem()
    return GetBestTome();
end

local RestedTomeBlocker = CreateFromMixins(RestedTomeBlockerMixin);
function Internal.GetRestedTomeBlocker()
    return RestedTomeBlocker;
end

--[[ FORGE OF BONDS ]]

local ForgeOfBondsBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function ForgeOfBondsBlockerMixin:ShouldWait()
    return true
end
function ForgeOfBondsBlockerMixin:PopupMessagePartial()
    return L["Cannot fully apply your loadout without visiting a Forge of Bonds"]
end
function ForgeOfBondsBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for you to open the Forge of Bonds"]
end
function ForgeOfBondsBlockerMixin:IsActive()
    return not C_Soulbinds.CanModifySoulbind()
end

local ForgeOfBondsBlocker = CreateFromMixins(ForgeOfBondsBlockerMixin);
function Internal.GetForgeOfBondsBlocker()
    return ForgeOfBondsBlocker;
end

--[[ SPELL CASTING ]]

local SpellCastingBlockerMixin = CreateFromMixins(Internal.BlockerMixin)
function SpellCastingBlockerMixin:ShouldWait()
    return true
end
function SpellCastingBlockerMixin:GetWaitReasonMessage()
    return L["Waiting for spell cast to end"]
end
function SpellCastingBlockerMixin:IsActive()
    return not not UnitCastingInfo("player")
end

local SpellCastingBlocker = CreateFromMixins(SpellCastingBlockerMixin);
function Internal.GetSpellCastingBlocker()
    return SpellCastingBlocker;
end
