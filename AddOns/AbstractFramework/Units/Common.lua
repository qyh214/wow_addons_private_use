---@class AbstractFramework
local AF = _G.AbstractFramework

local strfind = strfind
local bitband = bit.band
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitIsUnit = UnitIsUnit
local UnitInParty = UnitInParty
local UnitInPartyIsAI = UnitInPartyIsAI or AF.noop
local UnitPlayerOrPetInParty = UnitPlayerOrPetInParty
local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClassBase = UnitClassBase
local UnitName = UnitName
local GetUnitName = GetUnitName
local GetNormalizedRealmName = GetNormalizedRealmName

---------------------------------------------------------------------
-- group
---------------------------------------------------------------------

---@param group number
---@return number n
function AF.GetNumSubgroupMembers(group)
    local n = 0
    for i = 1, GetNumGroupMembers() do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if subgroup == group then
            n = n + 1
        end
    end
    return n
end

---@param group number
---@return table unitIDs
function AF.GetUnitsInSubGroup(group)
    local units = {}
    for i = 1, GetNumGroupMembers() do
        -- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(raidIndex)
        local name, _, subgroup = GetRaidRosterInfo(i)
        if subgroup == group then
            tinsert(units, "raid"..i)
        end
    end
    return units
end

---@param fullName string
---@return number i raid index
---@return number subgroup
---@return string unitId
---@return string classFileName
---@return string role TANK, HEALER, DAMAGER, NONE
---@return number rank 2:leader, 1:assistant, 0:member
function AF.GetRaidInfoByName(fullName)
    for i = 1, GetNumGroupMembers() do
        local name, rank, subgroup, _, _, classFileName, _, _, _, _, _, role = GetRaidRosterInfo(i)
        if name == fullName then
            return i, subgroup, "raid" .. i, classFileName, role, rank
        elseif not name then
            break
        end
    end
end

---@param group number
---@param subgroupIndex number
---@return number i raid index
---@return string name
---@return string unitId
---@return string classFileName
---@return string role TANK, HEALER, DAMAGER, NONE
---@return string rank 2:leader, 1:assistant, 0:member
function AF.GetRaidInfoBySubgroupIndex(group, subgroupIndex)
    local currentIndex = 0
    for i = 1, GetNumGroupMembers() do
        local name, rank, subgroup, _, _, classFileName, _, _, _, _, _, role = GetRaidRosterInfo(i)
        if subgroup == group then
            currentIndex = currentIndex + 1
            if currentIndex == subgroupIndex then
                return i, name, "raid" .. i, classFileName, role, rank
            end
        elseif subgroup > group and currentIndex ~= 0 then
            return -- nil if not found
        end
    end
end

---@param playerUnitID string "player" or group player
---@return string petUnitID
function AF.GetPlayerPetUnitID(playerUnitID)
    if playerUnitID == "player" then
        return "pet"
    elseif IsInRaid() then
        return "raidpet" .. select(3, strfind(playerUnitID, "^raid(%d+)$"))
    elseif IsInGroup() then
        return "partypet" .. select(3, strfind(playerUnitID, "^party(%d+)$"))
    end
end

---@param petUnitID string "pet" or group pet
---@return string playerUnitID
function AF.GetPetOwnerUnitID(petUnitID)
    if petUnitID == "pet" then
        return "player"
    else
        return petUnitID:gsub("pet", "")
    end
end

---@return function iterator
function AF.IterateGroupMembers()
    local groupType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    local i

    if groupType == "party" then
        i = 0
        numGroupMembers = numGroupMembers - 1
    else
        i = 1
    end

    return function()
        local ret
        if i == 0 then
            ret = "player"
        elseif i <= numGroupMembers and i > 0 then
            ret = groupType .. i
        end
        i = i + 1
        return ret
    end
end

---@return function iterator
function AF.IterateGroupPets()
    local groupType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    local i = groupType == "party" and 0 or 1

    return function()
        local ret
        if i == 0 and groupType == "party" then
            ret = "pet"
        elseif i <= numGroupMembers and i > 0 then
            ret = groupType .. "pet" .. i
        end
        i = i + 1
        return ret
    end
end

---@return string groupType raid, party, solo
function AF.GetGroupType()
    if IsInRaid() then
        return "raid"
    elseif IsInGroup() then
        return "party"
    else
        return "solo"
    end
end

---@param unit string
---@param ignorePets boolean
---@return boolean
function AF.UnitInGroup(unit, ignorePets)
    if ignorePets then
        return UnitIsUnit(unit, "player") or UnitInParty(unit) or UnitInRaid(unit) or UnitInPartyIsAI(unit)
    else
        return UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") or UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit) or UnitInPartyIsAI(unit)
    end
end

-- NOTE: Retail (but not ideal): UnitTokenFromGUID
---@param target string targetUnitID
---@return string?
function AF.GetBestUnitIDForTarget(target)
    if UnitIsUnit(target, "player") then
        return "player"
    elseif UnitIsUnit(target, "pet") then
        return "pet"
    elseif UnitIsUnit(target, "focus") then
        return "focus"
    end

    if not AF.UnitInGroup(target) then return end

    if UnitIsPlayer(target) or UnitInPartyIsAI(target) then
        for unit in AF.IterateGroupMembers() do
            if UnitIsUnit(target, unit) then
                return unit
            end
        end
    else
        for unit in AF.IterateGroupPets() do
            if UnitIsUnit(target, unit) then
                return unit
            end
        end
    end
end

---@return string? bestUnitID
---@return string? unitName
---@return string? classFileName
function AF.GetTargetUnitInfo()
    if UnitIsUnit("target", "player") then
        return "player", UnitName("player"), UnitClassBase("player")
    elseif UnitIsUnit("target", "pet") then
        return "pet", UnitName("pet")
    end
    if not AF.UnitInGroup("target") then return end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            if UnitIsUnit("target", "raid"..i) then
                return "raid"..i, UnitName("raid"..i), UnitClassBase("raid"..i)
            end
            if UnitIsUnit("target", "raidpet"..i) then
                return "raidpet"..i, UnitName("raidpet"..i)
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers()-1 do
            if UnitIsUnit("target", "party"..i) then
                return "party"..i, UnitName("party"..i), UnitClassBase("party"..i)
            end
            if UnitIsUnit("target", "partypet"..i) then
                return "partypet"..i, UnitName("partypet"..i)
            end
        end
    end
end

function AF.HasPermission()
    if isPartyMarkPermission and IsInGroup() and not IsInRaid() then return true end
    return UnitIsGroupLeader("player") or (IsInRaid() and UnitIsGroupAssistant("player"))
end

function AF.HasMarkPermission()
    if IsInRaid() then
        return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
    else -- party / solo
        return true
    end
end

---------------------------------------------------------------------
-- unit type
---------------------------------------------------------------------

-- https://warcraft.wiki.gg/wiki/UnitFlag
local OBJECT_AFFILIATION_MINE = 0x00000001
local OBJECT_AFFILIATION_PARTY = 0x00000002
local OBJECT_AFFILIATION_RAID = 0x00000004

---@param unitFlags number
---@return boolean isFriend
function AF.IsFriend(unitFlags)
    if not unitFlags then return false end
    if (bitband(unitFlags, OBJECT_AFFILIATION_MINE) ~= 0)
        or (bitband(unitFlags, OBJECT_AFFILIATION_RAID) ~= 0)
        or (bitband(unitFlags, OBJECT_AFFILIATION_PARTY) ~= 0)
    then
        return true
    end
    return false
end

---@param guid string
---@return boolean isPlayer
function AF.IsPlayer(guid)
    return (guid and strfind(guid, "^Player")) and true or false
end

---@param guidOrUnit string guid or unitID
---@return boolean isPet
function AF.IsPet(guidOrUnit)
    if strfind(guidOrUnit, "pet%d*$") then
        return true
    elseif strfind(guidOrUnit, "^Pet") then
        return true
    end
    return false
end

---@param guid string
---@return boolean isNPC
function AF.IsNPC(guid)
    return (guid and strfind(guid, "^Creature")) and true or false
end

---@param guid string
---@return boolean isVehicle
function AF.IsVehicle(guid)
    return (guid and strfind(guid, "^Vehicle")) and true or false
end

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------

function AF.UnitFullName(unit)
    if not unit or not UnitIsPlayer(unit) then return end

    local name = GetUnitName(unit, true)

    --? name might be nil in some cases?
    if name and not string.find(name, "-") then
        local server = GetNormalizedRealmName()
        --? server might be nil in some cases?
        if server then
            name = name .. "-" .. server
        end
    end

    return name
end

AF.UnitShortName = UnitName

function AF.ToShortName(fullName)
    if not fullName then return "" end
    local shortName = strsplit("-", fullName)
    return shortName
end

function AF.GetRealmName(fullName)
    if not fullName then return "" end
    local _, realmName = strsplit("-", fullName)
    return realmName or GetNormalizedRealmName()
end

---@param name string realmName or fullName
function AF.IsConnectedRealm(name)
    if not name then return false end
    -- realm
    if name:find("-") then
        name = AF.GetRealmName(name)
    end
    -- normalizedRealm
    name = name:gsub(" ", ""):gsub("-", "")
    return AF.connectedRealms[name] or false
end