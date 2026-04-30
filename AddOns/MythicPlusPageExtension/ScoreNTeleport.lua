local ADDON_NAME, mppe = ...
-- REF https://wago.io/uPxmk1k-L https://wago.io/ud2YBS4WC
local function SelectBestSpellID(spellIDs)
    if (not spellIDs) then
        return
    end
    if #spellIDs > 1 then
        for _, spellID in next, spellIDs do
            if IsSpellKnown(spellID) then
                return spellID
            end
        end
    end
    return spellIDs[1]
end
-- REF https://wago.io/uPxmk1k-L https://wago.io/ud2YBS4WC
local function UpdateGameTooltip(parent, spellID, initialize)
    -- if (isLoadingScreenEnabled) then return end
    -- if (not GameTooltip:IsOwned(parent)) then return end
    -- if (not initialize and not GameTooltip:IsOwned(parent)) then return end
        local Button_OnEnter = parent:GetScript("OnEnter")
        if (not Button_OnEnter) then
            return
        end
        Button_OnEnter(parent)
        if IsSpellKnown(spellID) then
            local spellCooldown = C_Spell.GetSpellCooldown(spellID)

            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(name or TELEPORT_TO_DUNGEON)
            if issecretvalue(spellCooldown.startTime) or issecretvalue(spellCooldown.duration) then -- 12.0秘密值判断
               GameTooltip:AddLine(mppe.Translate['Cannot get spell info while in the current state.'], 1, 0, 0)
            elseif not spellCooldown.startTime or not spellCooldown.duration then
                GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
            elseif spellCooldown.duration == 0 then
                GameTooltip:AddLine(mppe.Translate['Click To Teleport'], 0, 1, 0)
            else
                GameTooltip:AddLine(SPELL_FAILED_NOT_READY..":"..SecondsToTime(ceil(spellCooldown.startTime + spellCooldown.duration - GetTime())), 1, 0, 0)
            end
        else
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(name or TELEPORT_TO_DUNGEON)
            GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
        end
    GameTooltip:Show()
    -- C_Timer.After(1, function () UpdateGameTooltip(parent, spellID) end)
end

-- 获取字符串UTF8长度
local function utf8len(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

-- 在字符串的指定字符索引位置插入换行符
local function InsertNewlineAt(str, charIndex)
    if not str or charIndex <= 0 or charIndex > utf8len(str) then
        return str -- 参数无效，返回原字符串
    end

    local len = string.len(str)
    local bytePos = len
    local left = len
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        if cnt == charIndex then
            bytePos = len - left
            left = 0
        end
        cnt = cnt + 1
    end
    -- 使用utf8.offset找到第 charIndex 个字符的字节位置
    if not bytePos then
        return str
    end
    -- 在指定字节位置前插入换行符
    return string.sub(str, 1, bytePos - 1) .. "\n" .. string.sub(str, bytePos)
end

local function ClearDungeonIconsOtherText(DungeonIcons)
    if not DungeonIcons then return end

    -- local children = {DungeonIcons:GetChildren()}
    -- for _, child in ipairs(children) do
    --     print(string.format("%s:%s", child:GetName() or "NULL", child:GetObjectType()))
    --     if child:GetObjectType() == "FontString" then
    --             child:SetText("")
    --             child:Hide()
    --             child:ClearAllPoints()
    --             child:SetParent(UIParent)
    --     elseif child:GetObjectType() == "Button" and (child:GetName() or "NULL") == "NULL" then
    --         child:Hide()
    --         child:ClearAllPoints()
    --         child:SetParent(UIParent)
    --     end
    -- end

    local regions = {DungeonIcons:GetRegions()}
    for _, region in ipairs(regions) do
        --print(string.format("%s:%s", region:GetName() or "NULL", region:GetObjectType()))
        if region:GetObjectType() == "FontString" then
            --print(region:GetText() and region:GetText() or "nil")
            if region ~= DungeonIcons.HighestLevel and region:GetName() == nil then              
                region:SetText("")
                region:Hide()
                region:ClearAllPoints()
                region:SetParent(UIParent)
            end
        end
    end
end

local function GenerateScoreNTeleport()
    local _csm_Init = false
    if not mppe.CurrentSeasonMythic then mppe.CurrentSeasonDungeon = {} _csm_Init = true end
    for k, di in ipairs(ChallengesFrame.DungeonIcons) do
        if _csm_Init then table.insert(mppe.CurrentSeasonDungeon, di.mapID) end
        local _s = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(di.mapID)) or 0
        if MythicPlusPageExtensionDB.ScoreNTeleport_TryClearOther and MythicPlusPageExtensionDB.ScoreNTeleport_TryClearOther == true then ClearDungeonIconsOtherText(di) end
        di.HighestLevel:ClearAllPoints()
        di.HighestLevel:SetPoint("TOP", ChallengesFrame.DungeonIcons[k], 0, -2) 
        di.HighestLevel:SetFont(di.HighestLevel:GetFont(), MythicPlusPageExtensionDB.ScoreNTeleport_DunLevel_FontSize, "OUTLINE")

        local teleportID = mppe.Dungeons[di.mapID] and SelectBestSpellID(mppe.Dungeons[di.mapID].TeleportID)
        local dunShortname = mppe.Dungeons[di.mapID] and mppe.Translate[mppe.Dungeons[di.mapID].Name]

        -- REF https://wago.io/uPxmk1k-L https://wago.io/ud2YBS4WC
        local dungeonTeleport = _G["mppeDT"..di.mapID] or CreateFrame("Button", "mppeDT"..di.mapID, di, "InsecureActionButtonTemplate")
        if MythicPlusPageExtensionDB.ScoreNTeleport_EnableTeleport and MythicPlusPageExtensionDB.ScoreNTeleport_EnableTeleport == true then
            dungeonTeleport:RegisterForClicks("AnyDown", "AnyUp")
            dungeonTeleport:SetAttribute("type", "spell")
            dungeonTeleport:SetScript("OnEnter", function() UpdateGameTooltip(di, teleportID, true) end)
            dungeonTeleport:SetScript("OnLeave", function() if GameTooltip:IsOwned(di) then GameTooltip:Hide() end end)
            dungeonTeleport:SetAllPoints(di)
            dungeonTeleport:SetAttribute("spell", teleportID)
        end
        local dunNameWordWarp = false
        local dungeonName = _G["mppeDN"..di.mapID] or dungeonTeleport:CreateFontString("mppeDN"..di.mapID, "OVERLAY", "GameFontNormal")
        dungeonName:ClearAllPoints()
        dungeonName:SetPoint("BOTTOM", ChallengesFrame.DungeonIcons[k], 0, 0)
        dungeonName:SetTextColor(1,1,1,1)
        dungeonName:SetFont(dungeonName:GetFont(), MythicPlusPageExtensionDB.ScoreNTeleport_DunShortName_FontSize, "OUTLINE")
        dungeonName:SetWordWrap(dunNameWordWarp)
        if dunShortname and utf8len(dunShortname) > MythicPlusPageExtensionDB.ScoreNTeleport_DunShortName_PerLine then
            dunShortname = InsertNewlineAt(dunShortname, MythicPlusPageExtensionDB.ScoreNTeleport_DunShortName_PerLine)
            dungeonName:SetHeight(26)
            dunNameWordWarp = true
            dungeonName:SetWordWrap(dunNameWordWarp)
            dungeonName:SetPoint("BOTTOM", ChallengesFrame.DungeonIcons[k], 0, -5)
        end
        dungeonName:SetText(dunShortname)
        dungeonName:SetWidth(di:GetWidth() + 4)

        local dungeonName_bg = _G["mppeDN"..di.mapID.."_bg"] or dungeonTeleport:CreateTexture("mppeDN"..di.mapID.."_bg", "BACKGROUND")
        dungeonName_bg:SetSize(ChallengesFrame.DungeonIcons[k]:GetWidth(), dungeonName:GetHeight() + 2)
        if dunNameWordWarp then dungeonName_bg:SetSize(ChallengesFrame.DungeonIcons[k]:GetWidth(), dungeonName:GetHeight() - 4) end
        dungeonName_bg:SetAtlas("ChallengeMode-guild-background")
        dungeonName_bg:ClearAllPoints()
        dungeonName_bg:SetPoint("BOTTOM", ChallengesFrame.DungeonIcons[k], 0, 0)
        dungeonName_bg:SetVertexColor(0, 0, 0, 0.6)
        
        local dungeonScore = _G["mppeDS"..di.mapID] or dungeonTeleport:CreateFontString("mppeDS"..di.mapID, "OVERLAY", "GameFontNormal")
        dungeonScore:ClearAllPoints()
        dungeonScore:SetPoint("CENTER", ChallengesFrame.DungeonIcons[k], 0, -3)
        dungeonScore:SetFont(dungeonScore:GetFont(), MythicPlusPageExtensionDB.ScoreNTeleport_DunScore_FontSize, "OUTLINE")
        dungeonScore:SetTextColor(di.HighestLevel:GetTextColor())
        dungeonScore:SetText(_s > 0 and _s or "")

        if MythicPlusPageExtensionDB.ScoreNTeleport_UseOldStyle then
            dungeonName:ClearAllPoints()
            dungeonName_bg:ClearAllPoints()
            di.HighestLevel:ClearAllPoints()
            dungeonScore:ClearAllPoints()
            dungeonName:SetTextColor(di.HighestLevel:GetTextColor())
            dungeonName:SetPoint("TOP", ChallengesFrame.DungeonIcons[k], 0, -2)
            dungeonName_bg:SetVertexColor(0, 0, 0, 0)
            dungeonName_bg:SetPoint("TOP", ChallengesFrame.DungeonIcons[k], 0, -2)
            di.HighestLevel:SetPoint("BOTTOM", ChallengesFrame.DungeonIcons[k], 0, 2) 
            dungeonScore:SetPoint("CENTER", ChallengesFrame.DungeonIcons[k], 0, 1.5)
        end
        dungeonTeleport:SetFrameLevel(di:GetFrameLevel() + 10) -- 防止其他插件的东西阻挡失效
        if MythicPlusPageExtensionDB.ScoreNTeleport_ScoreColorStyle ~= "highestlv" then
            dungeonScore:SetTextColor(mppe.GetColorByScore(_s * 8, MythicPlusPageExtensionDB.ScoreNTeleport_ScoreColorStyle))
        end
    end
    if _csm_Init then 
        table.sort(mppe.CurrentSeasonDungeon, function(a, b)
                return a < b
        end)
    end
    --print(mppe.CurrentSeasonDungeons[5])
end

-- 刷新/初始化[分数&传送门]控件
function mppe.RefreshScoreNTeleport()
    if MythicPlusPageExtensionDB.ScoreNTeleport_Enable then
        --[[
        -- 如果直接执行，可能会在第一次打开窗体时无法找到mapid，所以用了这种循环判断并延迟执行
        if ChallengesFrame and ChallengesFrame.DungeonIcons then
            for k, di in ipairs(ChallengesFrame.DungeonIcons) do
                if not di.mapID then
                    print(mppe.Translate['MapID is Null'])
                    C_Timer.After(0.1, function() GenerateScoreNTeleport() end)
                    break
                end                
            end
            GenerateScoreNTeleport()
        end
        ]]
        -- 不管判断直接延迟执行也可以
        if ChallengesFrame then 
            C_Timer.After(0.02, function() GenerateScoreNTeleport() end)
        end
    end
end
--==================================================================
-- 通报事件控制器
mppe.SendTeleportInfo_eventFrame = CreateFrame("Frame")
local TpIdToDunID = nil
mppe.SendTeleportInfo_eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
mppe.SendTeleportInfo_eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
mppe.SendTeleportInfo_eventFrame:SetScript("OnEvent", function(self, event, unitTarget, castGUID, spellID)
    if event ~= "UNIT_SPELLCAST_START" and event ~= "UNIT_SPELLCAST_SUCCEEDED" then return end
    if not MythicPlusPageExtensionDB.ScoreNTeleport_Enable or not MythicPlusPageExtensionDB.ScoreNTeleport_SendTeleportInfo then return end
    if (unitTarget ~= "player") or (not spellID) or (not TpIdToDunID[spellID]) then return end

    if MythicPlusPageExtensionDB.ScoreNTeleport_STI_CastStatu == "caststart" and event == "UNIT_SPELLCAST_START" then
        local dunName = C_ChallengeMode.GetMapUIInfo(TpIdToDunID[spellID]) or "unknown"
        if IsInGroup() then SendChatMessage("[MPPE]"..string.format(mppe.Translate['Activating teleport %s, destination set to [%s]!'],C_Spell.GetSpellLink(spellID),dunName), IsInRaid() and "RAID" or "PARTY") end

    elseif MythicPlusPageExtensionDB.ScoreNTeleport_STI_CastStatu == "castsucceeded" and event == "UNIT_SPELLCAST_SUCCEEDED" then 
        local dunName = C_ChallengeMode.GetMapUIInfo(TpIdToDunID[spellID]) or "unknown"
        if IsInGroup() then SendChatMessage("[MPPE]"..string.format(mppe.Translate['Teleport %s completed, arrived at destination [%s]!'],C_Spell.GetSpellLink(spellID),dunName), IsInRaid() and "RAID" or "PARTY") end
    end  
end)
local function BuildTpIdToDunID()
    TpIdToDunID = {} 
    for dungeonID, dungeonInfo in pairs(mppe.Dungeons) do
        if type(dungeonInfo) == "table" and dungeonInfo.TeleportID and type(dungeonInfo.TeleportID) == "table" then
            for _, teleportID in ipairs(dungeonInfo.TeleportID) do
                TpIdToDunID[teleportID] = dungeonID
            end
        end
    end       
    return TpIdToDunID
end
BuildTpIdToDunID()