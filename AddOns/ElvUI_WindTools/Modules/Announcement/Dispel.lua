local W, F, E, L = unpack((select(2, ...)))
local A = W:GetModule("Announcement")

local _G = _G
local gsub = gsub
local strsplit = strsplit

local GetSpellLink = GetSpellLink
local IsInInstance = IsInInstance
local IsPartyLFG = IsPartyLFG
local UnitGUID = UnitGUID

function A:Dispel(sourceGUID, sourceName, destName, spellId, extraSpellId)
    local config = self.db.dispel

    if not config.enable or config.onlyInstance and not (IsInInstance() or IsPartyLFG()) then
        return
    end

    if not (spellId and extraSpellId) then
        return
    end

    if not self:CheckAuthority("DISPEL_OTHERS") then
        return
    end

    local function FormatMessage(message)
        sourceName = gsub(sourceName, "%-[^|]+", "")
        message = gsub(message, "%%player%%", sourceName)
        message = gsub(message, "%%target%%", destName)
        message = gsub(message, "%%player_spell%%", GetSpellLink(spellId))
        message = gsub(message, "%%target_spell%%", GetSpellLink(extraSpellId))
        return message
    end

    if sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet") then
        if config.player.enable then
            self:SendMessage(FormatMessage(config.player.text), self:GetChannel(config.player.channel))
        end
    elseif config.others.enable then
        local sourceType = strsplit("-", sourceGUID)

        if sourceType == "Pet" then
            sourceName = self:GetPetInfo(sourceName)
        end

        if not self:IsGroupMember(sourceName) then
            return
        end

        self:SendMessage(FormatMessage(config.others.text), self:GetChannel(config.others.channel))
    end
end
