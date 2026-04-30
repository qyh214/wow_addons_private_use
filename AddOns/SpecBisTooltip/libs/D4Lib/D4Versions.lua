local AddonName, D4 = ...
local pre = AddonName .. "D4PREFIX"
D4.VersionTab = D4.VersionTab or {}
if C_ChatInfo then
    C_ChatInfo.RegisterAddonMessagePrefix(pre)
end

function D4:SetVersion(icon, ver)
    if icon == nil then
        D4:MSG("|cffff0000[SetVersion] MISSING ICON AT SetVersion", icon)

        return false
    end

    if ver == nil then
        D4:MSG("|cffff0000[SetVersion] MISSING VERSION AT SetVersion", ver)

        return false
    end

    if D4.VersionTab[string.lower(AddonName)] ~= nil then
        D4:MSG("|cffff0000[SetVersion] VERSION ALREADY SET", AddonName)

        return false
    end

    local index = string.lower(AddonName)
    D4.VersionTab[index] = {}
    D4.VersionTab[index].name = AddonName
    D4.VersionTab[index].version = ver
    D4.VersionTab[index].icon = icon
    D4.VersionTab[index].foundHigher = false
    local nameOrder = {}
    for k, v in pairs(D4.VersionTab) do
        tinsert(nameOrder, string.lower(k))
    end

    table.sort(nameOrder)
    local id = 0
    for i, v in pairs(nameOrder) do
        id = id + 1
        D4.VersionTab[string.lower(v)].id = id
    end
end

function D4:GetVersion(name)
    local na = name or AddonName
    if na == nil then
        D4:MSG("|cffff0000[GetVersion] Name is Invalid", AddonName)

        return false
    end

    if AddonName and D4.VersionTab[string.lower(na)] then return D4.VersionTab[string.lower(na)].version end

    return nil
end

function D4:FoundHigher(name)
    if name == nil then
        D4:MSG("|cffff0000[FoundHigher] MISSING NAME AT FoundHigher")

        return false
    end

    if name and D4.VersionTab[string.lower(name)] then return D4.VersionTab[string.lower(name)].foundHigher end

    return false
end

function D4:IsHigherVersion(ov1, ov2, ov3, cv1, cv2, cv3)
    if ov1 > cv1 then
        return true
    elseif ov1 == cv1 then
        if ov2 > cv2 then
            return true
        elseif ov2 == cv2 then
            if ov3 > cv3 then return true end
        end
    end

    return false
end

function D4:CheckVersion(name, ver)
    if name == nil then
        D4:MSG("|cffff0000[CheckVersion] MISSING NAME AT CheckVersion")

        return false
    end

    local ov1, ov2, ov3 = string.split(".", ver)
    local cv1, cv2, cv3 = string.split(".", D4:GetVersion(name) or "0.0.0")
    local higher = D4:IsHigherVersion(ov1, ov2, ov3, cv1, cv2, cv3)
    if higher and name and D4.VersionTab and D4.VersionTab[string.lower(name)] then
        D4.VersionTab[string.lower(name)].foundHigher = true
        D4:MSG(name, D4.VersionTab[string.lower(name)].icon, string.format("New Version available (v%s -> v%s)", D4:GetVersion(name), ver))
    end
end

local f = CreateFrame("FRAME")
D4:RegisterEvent(f, "PLAYER_ENTERING_WORLD")
D4:RegisterEvent(f, "PLAYER_REGEN_ENABLED")
D4:RegisterEvent(f, "PLAYER_REGEN_DISABLED")
D4:OnEvent(
    f,
    function(sel, event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            D4:RegisterEvent(f, "CHAT_MSG_ADDON")
        elseif event == "PLAYER_REGEN_DISABLED" then
            D4:UnregisterEvent(f, "CHAT_MSG_ADDON")
        elseif event == "CHAT_MSG_ADDON" then
            local pref, msg = ...
            if pref == pre and msg then
                local a, name, v, ver = string.split(";", msg)
                if a and name and v and ver and a == "A" and v == "V" and AddonName == name and not D4:FoundHigher(name) then
                    D4:CheckVersion(name, ver)
                end
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            D4:UnregisterEvent(f, event)
            D4:After(
                3,
                function()
                    if C_ChatInfo and D4.VersionTab[string.lower(AddonName)] then
                        D4:RegisterEvent(f, "CHAT_MSG_ADDON")
                        D4:After(
                            2,
                            function()
                                local id = D4.VersionTab[string.lower(AddonName)].id or 0
                                D4:After(
                                    id * 0.1,
                                    function()
                                        local ver = D4:GetVersion()
                                        if ver == nil then
                                            D4:MSG(AddonName, 0, "|cffff0000MISSING VERSION", AddonName)
                                        end

                                        if ver then
                                            local chatType
                                            if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                                                chatType = "INSTANCE_CHAT"
                                            elseif IsInRaid() then
                                                chatType = "RAID"
                                            elseif IsInGroup() then
                                                chatType = "PARTY"
                                            elseif IsInGuild() then
                                                chatType = "GUILD"
                                            end

                                            if chatType then
                                                C_ChatInfo.SendAddonMessage(pre, string.format("A;%s;V;%s", AddonName, ver), chatType)
                                            end
                                        end
                                    end, "D4 PLAYER_ENTERING_WORLD 2"
                                )
                            end, "D4 PLAYER_ENTERING_WORLD 1"
                        )
                    end
                end, "[D4] CHECK VERSION"
            )
        end
    end, "VERSION"
)
