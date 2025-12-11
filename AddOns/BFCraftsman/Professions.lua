---@class BFC
local BFC = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

local GetTradeSkillDisplayName = C_TradeSkillUI.GetTradeSkillDisplayName

BFC.validSkillLines = {
    [164] = true, -- Blacksmithing
    [165] = true, -- Leatherworking
    [171] = true, -- Alchemy
    [197] = true, -- Tailoring
    [202] = true, -- Engineering
    [333] = true, -- Enchanting
    [773] = true, -- Inscription
    [755] = true, -- Jewelcrafting
    -- [182] = true, -- Herbalism
    -- [186] = true, -- Mining
    -- [393] = true, -- Skinning
}

BFC.validChildSkillLines = {
    [2823] = true, -- Alchemy (DF)
    [2871] = true, -- Alchemy (TWW)
    [2822] = true, -- Blacksmithing (DF)
    [2872] = true, -- Blacksmithing (TWW)
    [2825] = true, -- Enchanting (DF)
    [2874] = true, -- Enchanting (TWW)
    [2827] = true, -- Engineering (DF)
    [2875] = true, -- Engineering (TWW)
    [2828] = true, -- Inscription (DF)
    [2878] = true, -- Inscription (TWW)
    [2829] = true, -- Jewelcrafting (DF)
    [2879] = true, -- Jewelcrafting (TWW)
    [2830] = true, -- Leatherworking (DF)
    [2880] = true, -- Leatherworking (TWW)
    [2831] = true, -- Tailoring (DF)
    [2883] = true, -- Tailoring (TWW)
}

function BFC.GetProfessionList()
    local ret = {}
    for id in pairs(BFC.validSkillLines) do
        local name = GetTradeSkillDisplayName(id)
        tinsert(ret, {id, name})
    end
    sort(ret, function(a, b)
        return a[2] < b[2]
    end)
    return ret
end

local professionOrder = {164, 165, 171, 197, 202, 333, 773, 755}
function BFC.GetProfessionString(profs, size)
    local text = ""
    if type(profs) == "table" then
        for _, id in pairs(professionOrder) do
            if profs[id] ~= nil then
                local icon = AF.GetProfessionIcon(id)
                text = text .. AF.EscapeIcon(icon, size)
            end
        end
    end
    return text
end

BFC.learnedProfessions = {}

local function Update(prof, name, class, faction)
    if prof.enabled and BFC.validSkillLines[prof.id] then
        if not BFC.learnedProfessions[prof.id] then
            BFC.learnedProfessions[prof.id] = {}
        end
        tinsert(BFC.learnedProfessions[prof.id], {name, class, faction})
    end
end

function BFC.UpdateLearnedProfessions()
    wipe(BFC.learnedProfessions)
    for _, t in pairs(BFC_DB.publish.characters) do
        if not BFC_DB.publish.currentServerOnly or AF.IsConnectedRealm(t.name) then
            -- fix for old versions, will be removed in the future
            if not t.faction and AF.player.fullName == t.name then
                t.faction = AF.player.faction
            end

            Update(t.prof1, t.name, t.class, t.faction)
            Update(t.prof2, t.name, t.class, t.faction)
        end
    end
end