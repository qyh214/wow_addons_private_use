---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- spells
---------------------------------------------------------------------
local UNKNOWN_NAME = _G.UNKNOWN
local UNKNOWN_ICON = AF.GetIcon("QuestionMark")

if AF.isWrath then
    ---@param spellId number
    ---@param alwaysReturnValue boolean? If true, always return non-nil values even if the spellId is invalid
    ---@return string spellName
    ---@return number spellIcon
    function AF.GetSpellInfo(spellId, alwaysReturnValue)
        if not spellId then return end
        local name, _, icon = GetSpellInfo(spellId)
        if alwaysReturnValue then
            return name or UNKNOWN_NAME, icon or UNKNOWN_ICON
        end
        return name, icon
    end
else
    local GetSpellInfo = C_Spell.GetSpellInfo
    local GetSpellName = C_Spell.GetSpellName
    local GetSpellTexture = C_Spell.GetSpellTexture

    ---@param spellId number
    ---@param alwaysReturnValue boolean? If true, always return non-nil values even if the spellId is invalid
    ---@return string spellName
    ---@return number spellIcon
    function AF.GetSpellInfo(spellId, alwaysReturnValue)
        local info = GetSpellInfo(spellId)
        if not info then return end

        if not info.iconID then -- when?
            info.iconID = GetSpellTexture(spellId)
        end

        if alwaysReturnValue then
            return info.name or UNKNOWN_NAME, info.iconID or UNKNOWN_ICON
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
if AF.isWrath or AF.isTBC or AF.isVanilla then
    local GetSpellInfo = GetSpellInfo
    local GetNumSpellTabs = GetNumSpellTabs
    local GetSpellTabInfo = GetSpellTabInfo
    local GetSpellBookItemName = GetSpellBookItemName

    local MATCH_PATTERN, FORMAT_PATTERN = "Rank (%d+)", "Rank %d"
    if LOCALE_deDE or LOCALE_frFR then
        MATCH_PATTERN = "Rang (%d+)"
        FORMAT_PATTERN = "Rang %d"
    elseif LOCALE_esES or LOCALE_esMX then
        MATCH_PATTERN = "Rango (%d+)"
        FORMAT_PATTERN = "Rango %d"
    -- elseif LOCALE_itIT then -- not supported in classic
    --     MATCH_PATTERN = "Grado (%d+)"
    --     FORMAT_PATTERN = "Grado %d"
    elseif LOCALE_koKR then
        MATCH_PATTERN = "(%d+) 레벨"
        FORMAT_PATTERN = "%d 레벨"
    elseif LOCALE_ptBR then
        MATCH_PATTERN = "Grau (%d+)"
        FORMAT_PATTERN = "Grau %d"
    elseif LOCALE_ruRU then
        MATCH_PATTERN = "Уровень (%d+)"
        FORMAT_PATTERN = "Уровень %d"
    elseif LOCALE_zhCN then
        MATCH_PATTERN = "等级 (%d+)"
        FORMAT_PATTERN = "等级 %d"
    elseif LOCALE_zhTW then
        MATCH_PATTERN = "等級 (%d+)"
        FORMAT_PATTERN = "等級 %d"
    end

    FORMAT_PATTERN = "(" .. FORMAT_PATTERN .. ")"

    function AF.GetSpellRankSuffix(rank)
        return FORMAT_PATTERN:format(rank)
    end

    function AF.GetSpellMaxRank(spellId)
        local spellName = GetSpellInfo(spellId)
        if not spellName then return end

        local maxRank = 0
        local bookType = BOOKTYPE_SPELL

        local totalSpells = 0
        for tab = 1, GetNumSpellTabs() do
            local name, texture, offset, numSpells = GetSpellTabInfo(tab)
            totalSpells = totalSpells + numSpells
        end

        -- local spellSubText
        for i = 1, totalSpells do
            local name, subText = GetSpellBookItemName(i, bookType)
            if name == spellName and subText then
                local rank = tonumber(subText:match(MATCH_PATTERN))
                -- spellSubText = subText
                if rank and rank > maxRank then
                    maxRank = rank
                end
            end
        end

        -- if spellSubText then
        --     print("----------------------------------------------")
        --     print(spellSubText, MATCH_PATTERN, tonumber(spellSubText:match(MATCH_PATTERN)))
        --     print("Max Rank of " .. spellName .. ": " .. maxRank)
        --     print("----------------------------------------------")
        -- else
        --     print("Rank info not found: " .. spellName)
        -- end

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