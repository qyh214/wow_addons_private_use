---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- spells
---------------------------------------------------------------------
if AF.isWrath then
    ---@return number spellId
    ---@return number spellIcon
    function AF.GetSpellInfo(spellId)
        if not spellId then return end
        local name, _, icon = GetSpellInfo(spellId)
        return name, icon
    end
else
    local GetSpellInfo = C_Spell.GetSpellInfo
    local GetSpellName = C_Spell.GetSpellName
    local GetSpellTexture = C_Spell.GetSpellTexture

    ---@return number spellId
    ---@return number spellIcon
    function AF.GetSpellInfo(spellId)
        local info = GetSpellInfo(spellId)
        if not info then return end

        if not info.iconID then -- when?
            info.iconID = GetSpellTexture(spellId)
        end

        return info.name, info.iconID
    end
end

if C_Spell.DoesSpellExist then
    AF.SpellExists = C_Spell.DoesSpellExist
else
    AF.SpellExists = function(spellId)
        return GetSpellInfo(spellId) ~= nil
    end
end

function AF.RemoveInvalidSpells(t)
    if not t then return end
    for i = #t, 1, -1 do
        local spellId
        if type(t[i]) == "number" then
            spellId = t[i]
        else -- table
            spellId = t[i]["spellID"] or t[i][1]
        end
        if not AF.SpellExists(spellId) then
            tremove(t, i)
        end
    end
end

---------------------------------------------------------------------
-- classic spell rank
---------------------------------------------------------------------
if AF.isWrath or AF.isVanilla then
    local GetSpellInfo = GetSpellInfo
    local GetNumSpellTabs = GetNumSpellTabs
    local GetSpellTabInfo = GetSpellTabInfo
    local GetSpellBookItemName = GetSpellBookItemName
    local PATTERN = TRADESKILL_RANK_HEADER:gsub(" ", ""):gsub("%%d", "%%s*(%%d+)")

    function AF.GetMaxSpellRank(spellId)
        local spellName = select(1, GetSpellInfo(spellId))
        if not spellName then return end

        local maxRank = 0
        local bookType = BOOKTYPE_SPELL

        local totalSpells = 0
        for tab = 1, GetNumSpellTabs() do
            local name, texture, offset, numSpells = GetSpellTabInfo(tab)
            totalSpells = totalSpells + numSpells
        end

        for i = 1, totalSpells do
            local name, subText = GetSpellBookItemName(i, bookType)
            if name == spellName and subText then
                local rank = tonumber(subText:match(PATTERN))
                if rank and rank > maxRank then
                    maxRank = rank
                end
            end
        end

        return maxRank
    end
end

---------------------------------------------------------------------
-- spell cooldown
---------------------------------------------------------------------
if C_Spell.GetSpellCooldown then
    local GetSpellCooldown = C_Spell.GetSpellCooldown

    ---@param spellId number
    ---@return number startTime
    ---@return number duration
    AF.GetSpellCooldown = function(spellId)
        local info = GetSpellCooldown(spellId)
        if info then
            return info.startTime, info.duration
        end
    end
else
    local GetSpellCooldown = GetSpellCooldown

    ---@param spellId number
    ---@return number startTime
    ---@return number duration
    AF.GetSpellCooldown = function(spellId)
        local start, duration = GetSpellCooldown(spellId)
        return start, duration
    end
end

local GetTime = GetTime

---@param spellId number
---@return boolean isReady
---@return number? cdLeft
function AF.IsSpellReady(spellId)
    local start, duration = AF.GetSpellCooldown(spellId)
    if start == 0 or duration == 0 then
        return true
    else
        local _, gcd = AF.GetSpellCooldown(61304) --! check gcd
        if duration == gcd then -- spell ready
            return true
        else
            local cdLeft = start + duration - GetTime()
            return false, cdLeft
        end
    end
end

---------------------------------------------------------------------
-- auras
---------------------------------------------------------------------
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
function AF.FindAuraById(unit, filter, spellId)
    local i = 1
    repeat
        local auraData = GetAuraDataByIndex(unit, i, filter)
        if auraData then
            if auraData.spellId == spellId then
                return auraData
            end
            i = i + 1
        end
    until not auraData
end