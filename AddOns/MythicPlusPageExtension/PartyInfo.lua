local ADDON_NAME, mppe = ...
local pe = mppe.PartyEvent

local function ClearFrameContents(frame)
    if not frame then return end
    
    -- 安全移除并销毁所有子框架
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        -- 解除所有脚本绑定，避免引用残留
        child:SetScript("OnUpdate", nil)
        child:SetScript("OnEvent", nil)
        child:SetScript("OnEnter", nil)
        child:SetScript("OnLeave", nil)
        --child:SetScript("OnClick", nil)
        child:Hide()
        child:ClearAllPoints()
        child:SetParent(UIParent) -- 解除父子关系，使其可被垃圾回收
    end
    
    -- 安全移除并销毁所有区域（纹理、字体字符串等）
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region:GetObjectType() == "FontString" then
            region:SetText("") -- 清空文本
        end
        region:Hide()
        region:ClearAllPoints()
        region:SetParent(UIParent)
    end
end

-- 缓存函数：创建一个能快速补齐特定ID列表的函数
local function MythicRunsDunFiller(runs)
    local existingMap = {}
    for _, item in ipairs(runs) do
        existingMap[item.challengeModeID] = item
    end

    local runsList = {}
    local runsMap = {}
    if not mppe.CurrentSeasonDungeon then
        return {},{}
    end
    for _, id in ipairs(mppe.CurrentSeasonDungeon) do
        table.insert(runsList, existingMap[id] or {challengeModeID = id, bestRunDurationMS = 0, finishedSuccess = false, mapScore = 0, bestRunLevel = 0})
        table.insert(runsMap, id, existingMap[id] or {challengeModeID = id, bestRunDurationMS = 0, finishedSuccess = false, mapScore = 0, bestRunLevel = 0})
    end   
    
    table.sort(runsList, function(a, b)
        -- 1. 按 mapScore 降序
        if a.mapScore ~= b.mapScore then return a.mapScore > b.mapScore end
        -- 2. 按 bestRunLevel 降序
        if a.bestRunLevel ~= b.bestRunLevel then return a.bestRunLevel > b.bestRunLevel end
        if a.bestRunDurationMS ~= b.bestRunDurationMS then return a.bestRunLevel < b.bestRunLevel end
        -- 3. 按 finishedSuccess 降序 (true > false)
        if a.finishedSuccess ~= b.finishedSuccess then
            -- 注意：在Lua中，true > false 的比较需要特殊处理
            -- 将布尔值转换为数字比较 (true=1, false=0)
            local aSuccess = a.finishedSuccess and 1 or 0
            local bSuccess = b.finishedSuccess and 1 or 0
            return aSuccess > bSuccess
        end
        -- 4. 按 challengeModeID 降序
        return a.challengeModeID < b.challengeModeID
    end)

    return runsList, runsMap
end

local function FormatKSTime(ms)
    if type(ms) ~= "number" or ms <= 0 then return "0:00.000" end
    local totalSeconds = ms / 1000
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%d:%04.1f", minutes, seconds)
end

local function GeneratePlayerRunsInfo(name, realm, score, hexColor, runsList)
    if type(runsList) ~= "table" then return "" end

    local textParts = {}
    table.insert(textParts, string.format("|c%s%s(%s)|r - %s\n", hexColor, name, realm, mppe.Translate['Person Best M+ Records']))
    table.insert(textParts, string.format("%s|c%s%s|r\n\n", mppe.Translate['SeasonRating:'], mppe.GetColorByScore(score or 0, MythicPlusPageExtensionDB.PartyKeyStone_ScoreColorStyle, true), score or 0))
    
    for i,r in pairs(runsList) do
        local l = string.format("|c%s%s|r", r.finishedSuccess and "ff00ff00" or "ffff0000", (r.bestRunLevel and r.bestRunLevel > 0) and string.format("%02d",r.bestRunLevel) or "    ")--"|c00707070N/A|r")
        local d = mppe.Dungeons[r.challengeModeID] and mppe.Translate[mppe.Dungeons[r.challengeModeID].Name] or "UNKNOWN"
        local s = r.mapScore > 0 and r.mapScore or string.format("|c00707070%s|r", mppe.Translate['No Record'])
        local t = string.format("|c%s%s|r", r.finishedSuccess and "ff00ff00" or "ffff0000", r.bestRunDurationMS > 0 and string.format("(%s)", FormatKSTime(r.bestRunDurationMS)) or "")
        -- 12 圣焰隐修院 123(12:34.5)
        local _text = string.format("%s |c00ffffff%s|r|T:0:0|t%s %s\n", l, d, s, t)        
        table.insert(textParts, _text)
    end
    return table.concat(textParts, "")
end

local function GenerateDungeonRunsInfo(memberList, dungeonId)
    if type(memberList) ~= "table" or not dungeonId or dungeonId == 0 then return "" end
    local d = mppe.Dungeons[dungeonId] and mppe.Translate[mppe.Dungeons[dungeonId].Name] or "UNKNOWN"
    local textParts = {}
    table.insert(textParts, string.format("%s - %s\n\n", d, mppe.Translate['Dungeon Best M+ Records']))
    for i, m in ipairs(memberList) do
        local r = m.runsMap[dungeonId]
        if r then
        local l = string.format("|c%s%s|r", r.finishedSuccess and "ff00ff00" or "ffff0000", (r.bestRunLevel and r.bestRunLevel > 0) and string.format("%02d",r.bestRunLevel) or "    ")
        local n = string.format("|c%s%s(%s)|r", m.hexColor, m.name, m.realm)
        local s = r.mapScore > 0 and r.mapScore or string.format("|c00707070%s|r", mppe.Translate['No Record'])
        local t = string.format("|c%s%s|r", r.finishedSuccess and "ff00ff00" or "ffff0000", r.bestRunDurationMS > 0 and string.format("(%s)", FormatKSTime(r.bestRunDurationMS)) or "")
        -- 12 张三(白银之手) 123(12:34.5)
        local _text = string.format("%s |c00ffffff%s|r|T:0:0|t%s %s\n", l, n, s, t)       
        table.insert(textParts, _text)
        end
    end
    return table.concat(textParts, "")
end

-- local function GeneratePartyInfo()  
--     local weeklyChest = ChallengesFrame.WeeklyInfo.Child.WeeklyChest
--     weeklyChest:ClearAllPoints()
--     weeklyChest:SetPoint("LEFT", 100, 0)
--     local description = ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus
--     description:SetWordWrap(true)
--     description:SetSize(200, 90)

--     local xoffset = MythicPlusPageExtensionDB.PartyKeyStone_xOffset and MythicPlusPageExtensionDB.PartyKeyStone_xOffset or 0
--     local yoffset = MythicPlusPageExtensionDB.PartyKeyStone_yOffset and MythicPlusPageExtensionDB.PartyKeyStone_yOffset or 0
--     local pCount = 1
--     if IsInGroup() then
--         pCount = GetNumGroupMembers()
--     end

--     local PartyInfoFrame = _G["mppePartyInfoFrame"] or CreateFrame("Frame" ,"mppePartyInfoFrame", ChallengesFrame)
--     ClearFrameContents(PartyInfoFrame) -- 关键：每次运行都先清空
--     PartyInfoFrame:SetSize(265, 135)
--     PartyInfoFrame:SetPoint("BOTTOMRIGHT", ChallengesFrame, "BOTTOMRIGHT", -10 + xoffset, 75 + yoffset)
--     PartyInfoFrame:Show() -- 确保显示
    
--     local pif_bg = PartyInfoFrame:CreateTexture(nil, "BACKGROUND")
--     pif_bg:SetAllPoints()
--     pif_bg:SetAtlas("ChallengeMode-guild-background")
    
--     local pif_refresh

--     local pif_title = PartyInfoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
--     pif_title:SetPoint("TOPLEFT", 5, -5)
--     pif_title:SetText(mppe.Translate['PartyInfo'])
--     pif_title:SetFont("GameFontNormal", 50, "OUTLINE")

--     local pif_lfgTitle = PartyInfoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
--     pif_lfgTitle:SetPoint("TOPRIGHT", -5, -5)
--     pif_lfgTitle:SetSize(150,pif_title:GetHeight())
--     pif_lfgTitle:SetText(mppe.LFG_Info and mppe.LFG_Info.typeName)
--     pif_lfgTitle:SetFont("GameFontNormal", 50, "OUTLINE")
--     pif_lfgTitle:SetTextColor(1,1,1,1)
--     local _lfgTooltip = mppe.LFG_Info.titleName or nil
--     pif_lfgTitle:SetScript("OnEnter", function(self)
--         if _lfgTooltip then
--             GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--             GameTooltip:SetText(_lfgTooltip)
--             GameTooltip:Show()
--         end
--     end)
--     pif_lfgTitle:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

--     local pif_line = PartyInfoFrame:CreateTexture(nil, "ARTWORK")
--     pif_line:SetSize(PartyInfoFrame:GetWidth(), 1)
--     pif_line:SetAtlas("spec-dividerline", false)
--     pif_line:SetPoint("TOP", PartyInfoFrame, "TOP", 0, -22)

--     local _, _Realm = UnitFullName("Player")
--     local _pMember = {}
--     for i = 1, pCount do
--         local _player = {
--             name = "",
--             realm = "",
--             fullName = "",
--             NameRealm = "",
--             bYou = false,
--             bSameRealm = false,
--             bLeader = false,           
--             class = "",
--             spec = 0,
--             hexColor = "",
--             role = "",
--             roleId = 9,
--             score = 0,
--             runs = {},
--             ksLv = 0,
--             ksId = 0,
--             iLv = nil,
--             -- bHaveThis = false,
--         }
--         if i == 1 then _player.name, _player.realm = UnitFullName("Player") _player.bYou = true
--         else _player.name, _player.realm = UnitFullName("Party"..tostring(i-1)) end
--         if not _player.realm then _player.realm = _Realm end
--         _player.bSameRealm = (_Realm == _player.realm)
--         if _player.bSameRealm then _player.fullName = _player.name else _player.fullName = string.format("%s-%s", _player.name, _player.realm) end
--         _player.NameRealm = string.format("%s-%s", _player.name, _player.realm)
--         _player.bLeader = UnitIsGroupLeader(_player.fullName)
--         _, _player.class, _ = UnitClass(_player.fullName)
--         if _player.bYou then 
--             _player.spec = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization()) 
--             _player.ksId = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0
--             _player.ksLv = C_MythicPlus.GetOwnedKeystoneLevel() or 0
--             _, _player.iLv, _ = GetAverageItemLevel()
--         else  
--             local playerData = mppe.PartyKeystone[_player.NameRealm]
--             if playerData then 
--                 _player.ksId =  playerData.ksId or 0
--                 _player.ksLv = playerData.ksLv or 0
--                 _player.score = playerData.rating or 0
--                 _player.iLv = playerData.iLv
--                 _player.spec = playerData.specId or 0
                
--             end
--         end
--         local _classSpec = mppe.ClassSpec[_player.class]
--         if _classSpec then _player.hexColor = mppe.ClassSpec[_player.class][0].color else _player.hexColor = "ffffffff" end
--         _player.role = UnitGroupRolesAssigned(_player.fullName)
--         if _player.role == "TANK" then _player.roleId = 1 elseif _player.role == "HEALER" then _player.roleId = 2 elseif _player.role == "DAMAGER" then _player.roleId = 3 end
--         _pMember[i] = _player
--         local _playerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(_player.fullName)
--         _player.runs = _playerMythicPlusRatingSummary and _playerMythicPlusRatingSummary.runs
--         --_player.runs = mppe.PartyBest and mppe.PartyBest[_player.fullName].runs
--         _player.score = _playerMythicPlusRatingSummary and _playerMythicPlusRatingSummary.currentSeasonScore or _player.score
--         _player.runsList, _player.runsMap = MythicRunsDunFiller(_player.runs or {})
--         --mppe.DebugPrint(_player)
--     end
--     table.sort(_pMember, function(a, b)
--         if a.bYou ~= b.bYou then return a.bYou end
--         if a.roleId ~= b.roleId then return a.roleId < b.roleId end
--         return a.name < b.name
--     end)

--     local pif_Member = {}
--     for i, _p in ipairs(_pMember) do        
--         local party = CreateFrame("Frame", nil, PartyInfoFrame)
--         party:SetSize(PartyInfoFrame:GetWidth(), 21.5)
--         if i == 1 then 
--             party:SetPoint("TOP",pif_line,"BOTTOM", 0, -2)
--         else 
--             party:SetPoint("TOP",pif_Member[i-1],"BOTTOM", 0, 0)
--         end

--         -- 添加高亮背景
--         local highlight = party:CreateTexture(nil, "BACKGROUND")
--         highlight:SetAllPoints(party)
--         highlight:SetColorTexture(1, 1, 1, 0.1) -- 半透明白色
--         highlight:Hide()
--         party.highlight = highlight
        
--         -- 鼠标计数器
--         party.mouseOverCount = 0
        
--         -- 函数：增加鼠标计数并显示高亮
--         local function AddMouseOver(self)
--             self.mouseOverCount = self.mouseOverCount + 1
--             if self.mouseOverCount == 1 then
--                 self.highlight:Show()
--             end
--         end
        
--         -- 函数：减少鼠标计数并可能隐藏高亮
--         local function RemoveMouseOver(self)
--             self.mouseOverCount = math.max(0, self.mouseOverCount - 1)
--             if self.mouseOverCount == 0 then
--                 self.highlight:Hide()
--             end
--         end

--         _p.ksId = tonumber(_p.ksId)
--         _p.ksLv = tonumber(_p.ksLv)
--         if type(_p.ksId) ~= "number" then _p.ksId = 0 end
--         if type(_p.ksLv) ~= "number" then _p.ksLv = 0 end
--         party.pRecordTooltip = GeneratePlayerRunsInfo(_p.name, _p.realm, _p.score, _p.hexColor, _p.runsList)
--         party.dRecordTooltip = GenerateDungeonRunsInfo(_pMember, _p.ksId)

--         local _, _specName, _, _pIconId, _specRole, _, _className = GetSpecializationInfoByID(_p.spec)

--         if not _specName then 
--             _specName = mppe.Translate[((mppe.ClassSpec[_p.class] or {})[_p.spec] or (mppe.ClassSpec[_p.class] or {})[0] or {}).name or "UNKNOWN"] 
--         end
--         if not _pIconId then 
--             _pIconId = ((mppe.ClassSpec[_p.class] or {})[_p.spec] or (mppe.ClassSpec[_p.class] or {})[0] or {}).icon or 0 
--         end
--         if not _specRole then 
--             _specRole = mppe.Translate['UNKNOWN'] 
--         end
--         if not _className then 
--             _className = mppe.Translate[_p.class] 
--         end

--         local pIcon = party:CreateTexture(nil, "OVERLAY")        
--         pIcon:SetSize(20, 20)
--         pIcon:SetPoint("LEFT",party,"LEFT", 16, 0)
--         if tonumber(_pIconId) then 
--             pIcon:SetTexture(_pIconId) 
--         else 
--             pIcon:SetAtlas(_pIconId) 
--         end
--         pIcon.tooltipText = string.format("%s(%s) %s", _specName, mppe.Translate[_specRole], _className)
--         pIcon:SetScript("OnEnter", function(self)
--             AddMouseOver(self:GetParent())
--             if self.tooltipText then
--                 GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--                 GameTooltip:SetText(self.tooltipText)
--                 GameTooltip:Show()
--             end
--         end)
--         pIcon:SetScript("OnLeave", function(self)
--             RemoveMouseOver(self:GetParent())
--             GameTooltip:Hide()
--         end)
        
--         local pRole = party:CreateTexture(nil, "ARTWORK")
--         pRole:SetSize(20, 20)
--         if _specRole == "TANK" then 
--             _specRole = 1 
--         elseif _specRole == "HEALER" then 
--             _specRole = 2 
--         else 
--             _specRole = 3 
--         end
--         local _roleId = (_p.roleId == 9 and _specRole) and _specRole or _p.roleId
--         if _roleId == 1 then 
--             pRole:SetAtlas("GM-icon-role-tank", false)
--         elseif _roleId == 2 then 
--             pRole:SetAtlas("GM-icon-role-healer", false)
--         else 
--             pRole:SetAtlas("GM-icon-role-dps", true) 
--         end
--         pRole:SetPoint("RIGHT",pIcon,"LEFT", 3, -1)
--         pRole:SetTexCoord(1, 0, 0, 1)
--         local pLeader = party:CreateTexture(nil, "ARTWORK")
--         pLeader:SetSize(14, 14)
--         if _p.bLeader then 
--             pLeader:SetAtlas("plunderstorm-glues-icon-leader", false)
--             pLeader:SetPoint("BOTTOM",pRole,"TOP", 0, -9)
--             pRole:SetPoint("RIGHT",pIcon,"LEFT", 3, -3)
--         end

--         local _name = _p.name
--         _p.iLv = tonumber(_p.iLv)
--         if type(_p.iLv) ~= "number" then _p.iLv = "" else _name = string.format("%d|T:1:1|t|||T:1:1|t%s", _p.iLv, _name) end
--         local pName = party:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")        
--         pName:SetWordWrap(false)
--         pName:SetJustifyH("LEFT")
--         pName:SetPoint("LEFT",pIcon,"RIGHT", 0, 0)
--         pName:SetText(_name)
--         pName:SetWidth(party:GetWidth()/2 - 20)
--         pName:SetTextColor(mppe.ColorHexToRGBA(_p.hexColor))
--         pName:SetScript("OnEnter", function(self)
--             AddMouseOver(self:GetParent())
--             if self:GetParent().pRecordTooltip then
--                 GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--                 GameTooltip:AddLine(self:GetParent().pRecordTooltip)
--                 GameTooltip:Show()
--             end
--         end)
--         pName:SetScript("OnLeave", function(self)
--             RemoveMouseOver(self:GetParent())
--             GameTooltip:Hide()
--         end)

--         -- _p.iLv = tonumber(_p.iLv)
--         -- print(_p.iLv)
--         -- if type(_p.iLv) ~= "number" then _p.iLv = "" else string.format("(%d)",_p.iLv) end
--         -- local piLv = party:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
--         -- piLv:SetWidth(40)
--         -- piLv:SetWordWrap(false)
--         -- piLv:SetJustifyH("LEFT")
--         -- piLv:SetPoint("LEFT",pName,"RIGHT", 0, 0)
--         -- piLv:SetText(_p.iLv)
--         -- piLv:SetScript("OnEnter", function(self)
--         --     if self:GetParent().pRecordTooltip then
--         --         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--         --         GameTooltip:SetText(self:GetParent().pRecordTooltip)
--         --         GameTooltip:Show()
--         --     end
--         -- end)
--         -- piLv:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

--         local _pks = ""
--         if _p.ksId > 0 then
--             _pks = string.format("%s%s",(_p.ksLv > 0 and _p.ksLv or ""), mppe.Translate[mppe.Dungeons[_p.ksId].Name])
--         end

--         local pKs = party:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
--         pKs:SetWidth(party:GetWidth()/2 - 20)
--         pKs:SetWordWrap(false)
--         pKs:SetPoint("RIGHT", party, "RIGHT", -2, 0)
--         pKs:SetPoint("LEFT", pName, "RIGHT", 2, 0)
--         pKs:SetJustifyH("RIGHT")
--         pKs:SetText(_pks)
--         pKs:SetScript("OnEnter", function(self)
--             AddMouseOver(self:GetParent())
--             if self:GetParent().dRecordTooltip and self:GetParent().dRecordTooltip ~= "" then
--                 GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--                 GameTooltip:SetText(self:GetParent().dRecordTooltip)
--                 GameTooltip:Show()
--             end
--         end)
--         pKs:SetScript("OnLeave", function(self) 
--             RemoveMouseOver(self:GetParent())
--             GameTooltip:Hide()
--         end)
        
--         -- 父框架的鼠标事件
--         party:SetScript("OnEnter", function(self)
--             AddMouseOver(self)
--         end)
        
--         party:SetScript("OnLeave", function(self)
--             RemoveMouseOver(self)
--         end)
        
--         pif_Member[i] = party
--     end
--     PartyInfoFrame.Member = pif_Member
-- end

local function GeneratePartyInfoV2()  
    local weeklyChest = ChallengesFrame.WeeklyInfo.Child.WeeklyChest
    weeklyChest:ClearAllPoints()
    weeklyChest:SetPoint("LEFT", 100, 0)
    local description = ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus
    description:SetWordWrap(true)
    description:SetSize(200, 90)

    local xoffset = MythicPlusPageExtensionDB.PartyKeyStone_xOffset and MythicPlusPageExtensionDB.PartyKeyStone_xOffset or 0
    local yoffset = MythicPlusPageExtensionDB.PartyKeyStone_yOffset and MythicPlusPageExtensionDB.PartyKeyStone_yOffset or 0
    local pCount = 1
    if IsInGroup() and not IsInRaid() then
        pCount = GetNumGroupMembers()
    end

    local PartyInfoFrame = _G["mppePartyInfoFrame"] or CreateFrame("Frame" ,"mppePartyInfoFrame", ChallengesFrame)
    ClearFrameContents(PartyInfoFrame) -- 关键：每次运行都先清空
    PartyInfoFrame:SetSize(265, 135)
    PartyInfoFrame:SetPoint("BOTTOMRIGHT", ChallengesFrame, "BOTTOMRIGHT", -10 + xoffset, 75 + yoffset)
    PartyInfoFrame:Show() -- 确保显示
    
    local pif_bg = PartyInfoFrame:CreateTexture(nil, "BACKGROUND")
    pif_bg:SetAllPoints()
    pif_bg:SetAtlas("ChallengeMode-guild-background")
    
    local pif_refresh

    local pif_title = PartyInfoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    pif_title:SetPoint("TOPLEFT", 5, -5)
    pif_title:SetText(mppe.Translate['PartyInfo'])
    --pif_title:SetFont("GameFontNormal", 50, "OUTLINE")
    pif_title:SetFont(ChatFontNormal:GetFont(), 15, "OUTLINE")

    local pif_lfgTitle = PartyInfoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    pif_lfgTitle:SetPoint("TOPRIGHT", -5, -5)
    pif_lfgTitle:SetSize(150,pif_title:GetHeight())
    pif_lfgTitle:SetText(mppe.LFG_Info and mppe.LFG_Info.typeName)
    pif_lfgTitle:SetFont(ChatFontNormal:GetFont(), 15, "OUTLINE")
    pif_lfgTitle:SetTextColor(1,1,1,1)
    local _lfgTooltip = mppe.LFG_Info.titleName or nil
    pif_lfgTitle:SetScript("OnEnter", function(self)
        if _lfgTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(_lfgTooltip)
            GameTooltip:Show()
        end
    end)
    pif_lfgTitle:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    local pif_line = PartyInfoFrame:CreateTexture(nil, "ARTWORK")
    pif_line:SetSize(PartyInfoFrame:GetWidth(), 1)
    pif_line:SetAtlas("spec-dividerline", false)
    pif_line:SetPoint("TOP", PartyInfoFrame, "TOP", 0, -22)

    --local _
    local _pMember = {}
    for i = 1, pCount do
        --print(tostring(time()).."^^^"..tostring(i)..":"..tostring(pCount))
        local _name, _realm 
        if mppe.Mine.Name == nil then mppe.Mine.Name = UnitName("Player") end
        if mppe.Mine.Realm == nil then mppe.Mine.Realm = GetRealmName() end
        if i == 1 then 
            _name, _realm = mppe.Mine.Name, mppe.Mine.Realm
        else _name, _realm = UnitFullName("Party"..tostring(i-1)) end
        local _player = pe.GetPlayer(_name, _realm)
        _player.bLeader = UnitIsGroupLeader(_player.fullName)
        
        local _classSpec = mppe.ClassSpec[_player.class]
        if _classSpec then _player.hexColor = mppe.ClassSpec[_player.class][0].color else _player.hexColor = "ffffffff" end

        _player.role = UnitGroupRolesAssigned(_player.fullName)
        if _player.role == "TANK" then _player.roleId = 1 elseif _player.role == "HEALER" then _player.roleId = 2 elseif _player.role == "DAMAGER" then _player.roleId = 3 end

        _pMember[i] = _player
        _player.runsList, _player.runsMap = MythicRunsDunFiller(_player.runs or {})
    end
    table.sort(_pMember, function(a, b)
        if a.bYou ~= b.bYou then return a.bYou end
        if a.roleId ~= b.roleId then return a.roleId < b.roleId end
        return a.name < b.name
    end)

    local pif_Member = {}
    for i, _p in ipairs(_pMember) do        
        local party = CreateFrame("Frame", nil, PartyInfoFrame)
        party:SetSize(PartyInfoFrame:GetWidth(), 21.5)
        if i == 1 then 
            party:SetPoint("TOP",pif_line,"BOTTOM", 0, -2)
        else 
            party:SetPoint("TOP",pif_Member[i-1],"BOTTOM", 0, 0)
        end

        -- 添加高亮背景
        local highlight = party:CreateTexture(nil, "BACKGROUND")
        highlight:SetAllPoints(party)
        highlight:SetColorTexture(1, 1, 1, 0.1) -- 半透明白色
        highlight:Hide()
        party.highlight = highlight
        
        -- 鼠标计数器
        party.mouseOverCount = 0
        
        -- 函数：增加鼠标计数并显示高亮
        local function AddMouseOver(self)
            self.mouseOverCount = self.mouseOverCount + 1
            if self.mouseOverCount == 1 then
                self.highlight:Show()
            end
        end
        
        -- 函数：减少鼠标计数并可能隐藏高亮
        local function RemoveMouseOver(self)
            self.mouseOverCount = math.max(0, self.mouseOverCount - 1)
            if self.mouseOverCount == 0 then
                self.highlight:Hide()
            end
        end

        _p.ksId = tonumber(_p.ksId)
        _p.ksLv = tonumber(_p.ksLv)
        if type(_p.ksId) ~= "number" then _p.ksId = 0 end
        if type(_p.ksLv) ~= "number" then _p.ksLv = 0 end
        party.pRecordTooltip = GeneratePlayerRunsInfo(_p.name, _p.realm, _p.score, _p.hexColor, _p.runsList)
        party.dRecordTooltip = GenerateDungeonRunsInfo(_pMember, _p.ksId)
        --print(_p.spec)
        local _, _specName, _, _pIconId, _specRole, _, _className = GetSpecializationInfoByID(_p.spec or 0)

        if not _specName then 
            _specName = mppe.Translate[((mppe.ClassSpec[_p.class] or {})[_p.spec] or (mppe.ClassSpec[_p.class] or {})[0] or {}).name or "UNKNOWN"] 
        end
        if not _pIconId then 
            _pIconId = ((mppe.ClassSpec[_p.class] or {})[_p.spec] or (mppe.ClassSpec[_p.class] or {})[0] or {}).icon or 0 
        end
        if not _specRole then 
            _specRole = mppe.Translate['UNKNOWN'] 
        end
        if not _className then 
            _className = mppe.Translate[_p.class] 
        end

        local pIcon = party:CreateTexture(nil, "OVERLAY")        
        pIcon:SetSize(20, 20)
        pIcon:SetPoint("LEFT",party,"LEFT", 16, 0)
        if tonumber(_pIconId) then 
            pIcon:SetTexture(_pIconId) 
        else 
            pIcon:SetAtlas(_pIconId) 
        end
        pIcon.tooltipText = string.format("%s(%s) %s", _specName, mppe.Translate[_specRole], _className)
        pIcon:SetScript("OnEnter", function(self)
            AddMouseOver(self:GetParent())
            if self.tooltipText then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.tooltipText)
                GameTooltip:Show()
            end
        end)
        pIcon:SetScript("OnLeave", function(self)
            RemoveMouseOver(self:GetParent())
            GameTooltip:Hide()
        end)
        
        local pRole = party:CreateTexture(nil, "ARTWORK")
        pRole:SetSize(20, 20)
        if _specRole == "TANK" then 
            _specRole = 1 
        elseif _specRole == "HEALER" then 
            _specRole = 2 
        else 
            _specRole = 3 
        end
        local _roleId = (_p.roleId == 9 and _specRole) and _specRole or _p.roleId
        if _roleId == 1 then 
            pRole:SetAtlas("GM-icon-role-tank", false)
        elseif _roleId == 2 then 
            pRole:SetAtlas("GM-icon-role-healer", false)
        else 
            pRole:SetAtlas("GM-icon-role-dps", true) 
        end
        pRole:SetPoint("RIGHT",pIcon,"LEFT", 3, -1)
        pRole:SetTexCoord(1, 0, 0, 1)
        local pLeader = party:CreateTexture(nil, "ARTWORK")
        pLeader:SetSize(14, 14)
        if _p.bLeader then 
            pLeader:SetAtlas("plunderstorm-glues-icon-leader", false)
            pLeader:SetPoint("BOTTOM",pRole,"TOP", 0, -9)
            pRole:SetPoint("RIGHT",pIcon,"LEFT", 3, -3)
        end

        local _name = _p.name
        _p.iLv = tonumber(_p.iLv)
        if type(_p.iLv) ~= "number" then _p.iLv = "" else _name = string.format("%d|T:1:1|t|||T:1:1|t%s", _p.iLv, _name) end
        local pName = party:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")        
        pName:SetWordWrap(false)
        pName:SetJustifyH("LEFT")
        pName:SetPoint("LEFT",pIcon,"RIGHT", 0, 0)
        pName:SetText(_name)
        pName:SetWidth(party:GetWidth()/2 - 20)
        pName:SetTextColor(mppe.ColorHexToRGBA(_p.hexColor))
        pName:SetScript("OnEnter", function(self)
            AddMouseOver(self:GetParent())
            if self:GetParent().pRecordTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self:GetParent().pRecordTooltip)
                GameTooltip:Show()
            end
        end)
        pName:SetScript("OnLeave", function(self)
            RemoveMouseOver(self:GetParent())
            GameTooltip:Hide()
        end)

        -- _p.iLv = tonumber(_p.iLv)
        -- print(_p.iLv)
        -- if type(_p.iLv) ~= "number" then _p.iLv = "" else string.format("(%d)",_p.iLv) end
        -- local piLv = party:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        -- piLv:SetWidth(40)
        -- piLv:SetWordWrap(false)
        -- piLv:SetJustifyH("LEFT")
        -- piLv:SetPoint("LEFT",pName,"RIGHT", 0, 0)
        -- piLv:SetText(_p.iLv)
        -- piLv:SetScript("OnEnter", function(self)
        --     if self:GetParent().pRecordTooltip then
        --         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        --         GameTooltip:SetText(self:GetParent().pRecordTooltip)
        --         GameTooltip:Show()
        --     end
        -- end)
        -- piLv:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

        local _pks = ""
        if _p.ksId > 0 then
            _pks = string.format("%s%s",(_p.ksLv > 0 and _p.ksLv or ""), mppe.Translate[mppe.Dungeons[_p.ksId].Name])
        end

        local pKs = party:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        pKs:SetWidth(party:GetWidth()/2 - 20)
        pKs:SetWordWrap(false)
        pKs:SetPoint("RIGHT", party, "RIGHT", -2, 0)
        pKs:SetPoint("LEFT", pName, "RIGHT", 2, 0)
        pKs:SetJustifyH("RIGHT")
        pKs:SetText(_pks)
        pKs:SetScript("OnEnter", function(self)
            AddMouseOver(self:GetParent())
            if self:GetParent().dRecordTooltip and self:GetParent().dRecordTooltip ~= "" then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self:GetParent().dRecordTooltip)
                GameTooltip:Show()
            end
        end)
        pKs:SetScript("OnLeave", function(self) 
            RemoveMouseOver(self:GetParent())
            GameTooltip:Hide()
        end)
        
        -- 父框架的鼠标事件
        party:SetScript("OnEnter", function(self)
            AddMouseOver(self)
        end)
        
        party:SetScript("OnLeave", function(self)
            RemoveMouseOver(self)
        end)
        
        pif_Member[i] = party
    end
    PartyInfoFrame.Member = pif_Member
end

-- 刷新/初始化小队信息框架
-- 需要防止重复触发
function mppe.RefreshPartyInfo()
    if MythicPlusPageExtensionDB.PartyKeyStone_Enable then
        -- 设置 ShowPartyInfo
        if PVEFrame:IsShown() and ChallengesFrame then
            C_Timer.After(0.05, function() GeneratePartyInfoV2() end)
        end
    end
end