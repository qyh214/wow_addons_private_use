local _, D4 = ...
local hooksecurefunc = _G["hooksecurefunc"]
local GetBuildInfo = _G["GetBuildInfo"]
local CreateFrame = _G["CreateFrame"]
local InCombatLockdown = _G["InCombatLockdown"]
local GetTime = _G["GetTime"]
local tinsert = _G["tinsert"]
local tremove = _G["tremove"]
local CUSTOM_CLASS_COLORS = _G["CUSTOM_CLASS_COLORS"]
local RAID_CLASS_COLORS = _G["RAID_CLASS_COLORS"]
local GetAtlasInfo = _G["GetAtlasInfo"]
--[[ Basics ]]
local buildNr = select(4, GetBuildInfo())
local buildName = "CLASSIC"
if buildNr >= 100000 then
    buildName = "RETAIL"
elseif buildNr >= 50000 then
    buildName = "MISTS"
elseif buildNr >= 40000 then
    buildName = "CATA"
elseif buildNr >= 30000 then
    buildName = "WRATH"
elseif buildNr >= 20000 then
    buildName = "TBC"
end

function D4:GetWoWBuildNr()
    return buildNr
end

function D4:GetWoWBuild()
    return buildName
end

D4.oldWow = D4.oldWow or false
if _G["C_Timer"] == nil then
    D4:MSG("[D4] ADD MISSING: C_Timer")
    _G["C_Timer"] = {}
    local f = CreateFrame("Frame")
    f.tab = {}
    f:HookScript(
        "OnUpdate",
        function()
            for i, v in pairs(f.tab) do
                if v[1] < GetTime() then
                    local func = v[2]
                    func()
                    tremove(f.tab, i)
                end
            end
        end
    )

    C_Timer.After = function(duration, callback)
        tinsert(f.tab, {GetTime() + duration, callback})
    end

    D4.oldWow = true
end

local eaf = CreateFrame("Frame")
eaf.tab = {}
eaf:Hide()
eaf:SetScript(
    "OnUpdate",
    function(self, elapsed)
        local currentTime = GetTime()
        for i = #self.tab, 1, -1 do
            local data = self.tab[i]
            if data[1] <= currentTime then
                local func = data[2]
                table.remove(self.tab, i)
                func()
            end
        end

        if #self.tab == 0 then
            self:Hide()
        end
    end
)

function D4:ExtraAfter(duration, callback, from)
    table.insert(eaf.tab, {GetTime() + duration, callback, from})
    eaf:Show()
end

if _G["C_Widget"] == nil then
    _G["C_Widget"] = {}
    function C_Widget.IsWidget(frame)
        if frame and frame.GetName then return true end

        return false
    end
end

local countAfter = {}
local countAfterEvents = {}
local debug = false
function D4:SetDebug(bo)
    debug = bo
end

local ready = false
local test = CreateFrame("frame")
test:RegisterEvent("PLAYER_ENTERING_WORLD")
test:SetScript(
    "OnEvent",
    function(...)
        ready = true
        test:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
)

function D4:After(time, callback, from)
    if from == nil then
        D4:INFO("[AFTER] MISSING FROM", time)

        return
    end

    if callback == nil then
        D4:INFO("[AFTER] CALLBACK IS NIL", time, from)

        return
    end

    if debug then
        countAfter[from] = countAfter[from] or 0
        countAfter[from] = countAfter[from] + 1
    end

    if not ready then
        D4:ExtraAfter(
            time,
            function()
                callback()
            end, from
        )

        return
    end

    C_Timer.After(
        time,
        function()
            callback()
        end
    )
end

function D4:GetCountAfter()
    return countAfter
end

function D4:GetCountAfterEvents()
    return countAfterEvents
end

function D4:GetClassColor(class)
    local colorTab = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
    if CUSTOM_CLASS_COLORS == nil and D4:GetWoWBuild() == "CLASSIC" and class == "SHAMAN" then return 0, 0.44, 0.87, "FF0070DE" end
    if colorTab[class] then return colorTab[class].r, colorTab[class].g, colorTab[class].b, colorTab[class].colorStr end

    return 1, 1, 1, "ffffffff"
end

if GetClassColor == nil then
    D4:MSG("[D4] ADD MISSING: GetClassColor")
    GetClassColor = function(class)
        local color = D4:GetClassColor(class)
        if color then return color.r, color.g, color.b, color.colorStr end

        return 1, 1, 1, "ffffffff"
    end

    D4.oldWow = true
end

function D4:IsOldWow()
    return D4.oldWow
end

function D4:RegisterEvent(frame, event, unit)
    if C_EventUtils == nil then
        frame:RegisterEvent(event)
        D4:MSG("[D4] MISSING C_EventUtils")

        return
    end

    if C_EventUtils.IsEventValid(event) then
        if unit then
            frame:RegisterUnitEvent(event, unit)
        else
            frame:RegisterEvent(event)
        end
    end
end

function D4:UnregisterEvent(frame, event)
    if C_EventUtils == nil then
        frame:UnregisterEvent(event)

        return
    end

    if C_EventUtils.IsEventValid(event) then
        frame:UnregisterEvent(event)
    end
end

function D4:OnEvent(frame, callback, from)
    if from == nil then
        D4:INFO("[D4][OnEvent] Missing from")

        return
    end

    frame:HookScript(
        "OnEvent",
        function(sel, event, ...)
            if debug then
                countAfterEvents[from] = countAfterEvents[from] or 0
                countAfterEvents[from] = countAfterEvents[from] + 1
            end

            callback(sel, event, ...)
        end
    )
end

function D4:ForeachChildren(frame, callback, from)
    if frame == nil then
        D4:MSG("[ForeachChildren] frame == nil", from)

        return
    end

    if frame.GetNumChildren == nil or frame.GetChildren == nil then
        D4:MSG("[ForeachChildren] frame.GetNumChildren == nil or  frame.GetChildren == nil", from)

        return
    end

    if callback == nil then
        D4:MSG("[ForeachChildren] Missing Callback", from)

        return
    end

    for x = 1, frame:GetNumChildren() do
        local child = select(x, frame:GetChildren())
        if child then
            local ret = callback(child, x)
            if ret then return ret end
        else
            return
        end
    end
end

function D4:ForeachRegions(frame, callback, from)
    if frame == nil then
        D4:MSG("[ForeachRegions] frame == nil", from)

        return
    end

    if frame.GetNumRegions == nil or frame.GetRegions == nil then
        D4:MSG("[ForeachRegions] frame.GetNumRegions == nil or  frame.GetRegions == nil", from)

        return
    end

    if callback == nil then
        D4:MSG("[ForeachRegions] Missing Callback", from)

        return
    end

    for x = 1, frame:GetNumRegions() do
        local region = select(x, frame:GetRegions())
        if region then
            local ret = callback(region, x)
            if ret then return ret end
        else
            return
        end
    end
end

--[[ QOL ]]
local callbacks = {}
local fSecure = CreateFrame("Frame")
D4:RegisterEvent(fSecure, "PLAYER_REGEN_ENABLED")
D4:OnEvent(
    fSecure,
    function()
        xpcall(
            function(call)
                for i, func in pairs(calls) do
                    func()
                end

                callbacks = {}
            end, function(err) end, callbacks
        )
    end, "fSecure"
)

function D4:SafeExec(sel, func, from)
    if sel == nil then
        D4:MSG("[D4][SafeExec] MISSING FRAME", from)

        return
    end

    if from == nil then
        D4:MSG("[D4][SafeExec] MISSING FROM", D4:GetName(sel))

        return
    end

    if InCombatLockdown() and sel:IsProtected() then
        callbacks[from] = func

        return
    end

    local ok = xpcall(
        function(fun)
            func()
        end, function(err) end, func
    )

    if not ok then
        callbacks[from] = func
    end
end

function D4:GetCVar(name)
    if C_CVar and C_CVar.GetCVar then return C_CVar.GetCVar(name) end
    if GetCVar then return GetCVar(name) end
    D4:MSG("[D4][GetCVar] FAILED")

    return nil
end

function D4:GetItemInfo(itemID)
    if itemID == nil then return nil end
    if C_Item and C_Item.GetItemInfo then return C_Item.GetItemInfo(itemID) end
    if GetItemInfo then return GetItemInfo(itemID) end
    D4:MSG("[D4][GetItemInfo] FAILED")

    return nil
end

function D4:GetItemCount(itemID)
    if itemID == nil then return nil end
    if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(itemID) end
    if GetItemCount then return GetItemCount(itemID) end
    D4:MSG("[D4][GetItemCount] FAILED")

    return nil
end

function D4:GetSpellPowerCost(spellId)
    if spellId == nil then return nil end
    if C_Spell and C_Spell.GetSpellPowerCost then return C_Spell.GetSpellPowerCost(spellId) end
    if GetSpellPowerCost then return GetSpellPowerCost(spellId) end
    D4:MSG("[D4][GetSpellPowerCost] FAILED")

    return nil
end

function D4:GetSpellInfo(spellID)
    if spellID == nil then return nil end
    if C_Spell and C_Spell.GetSpellInfo then
        local tab = C_Spell.GetSpellInfo(spellID)
        if tab then return tab.name, nil, tab.iconID, tab.castTime, tab.minRange, tab.maxRange, tab.spellID end

        return tab
    end

    if GetSpellInfo then return GetSpellInfo(spellID) end
    D4:MSG("[D4][GetSpellInfo] FAILED")

    return nil
end

function D4:IsSpellInRange(spellID, spellType, unit)
    if spellID == nil then return nil end
    if C_Spell and C_Spell.IsSpellInRange then return C_Spell.IsSpellInRange(spellID, unit) end
    if IsSpellInRange then return IsSpellInRange(spellID, spellType, unit) end
    D4:MSG("[D4][IsSpellInRange] FAILED")

    return nil
end

function D4:GetSpellCharges(spellID)
    if spellID == nil then return nil end
    if C_Spell and C_Spell.GetSpellCharges then return C_Spell.GetSpellCharges(spellID) end
    if GetSpellCharges then return GetSpellCharges(spellID) end
    D4:MSG("[D4][GetSpellCharges] FAILED")

    return nil
end

function D4:GetSpellCastCount(...)
    if C_Spell and C_Spell.GetSpellCastCount then return C_Spell.GetSpellCastCount(...) end
    if GetSpellCastCount then return GetSpellCastCount(...) end
    D4:MSG("[D4][GetSpellCastCount] FAILED")

    return nil
end

function D4:GetMouseFocus()
    if GetMouseFoci then return GetMouseFoci()[1] end
    if GetMouseFocus then return GetMouseFocus() end
    D4:MSG("[D4][GetMouseFocus] FAILED")

    return nil
end

function D4:GetItemGem(hyperLink, index)
    if C_Item and C_Item.GetItemGem then return C_Item.GetItemGem(hyperLink, index) end
    if GetItemGem then return GetItemGem(hyperLink, index) end

    return nil, nil
end

function D4:GetDetailedItemLevelInfo(itemInfo)
    if C_Item and C_Item.GetDetailedItemLevelInfo then return C_Item.GetDetailedItemLevelInfo(itemInfo) end
    if GetDetailedItemLevelInfo then return GetDetailedItemLevelInfo(itemInfo) end

    return nil, nil, nil
end

function D4:GetContainerItemInfo(bagID, slotID)
    if slotID < 0 then return nil end
    if C_Container and C_Container.GetContainerItemInfo then return C_Container.GetContainerItemInfo(bagID, slotID) end
    if GetContainerItemInfo then return GetContainerItemInfo(bagID, slotID) end

    return nil
end

function D4:GetContainerItemLink(bagID, slotID)
    if slotID < 0 then return nil end
    if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bagID, slotID) end
    if GetContainerItemLink then return GetContainerItemLink(bagID, slotID) end

    return nil
end

local function D4GetContainerNumSlots(bagID)
    if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bagID) end
    if GetContainerNumSlots then return GetContainerNumSlots(bagID) end

    return nil
end

function D4:GetContainerNumSlots(bagID)
    local cur = D4GetContainerNumSlots(bagID)
    local max = cur
    if bagID == 0 and IsAccountSecured and not IsAccountSecured() then
        max = cur + 4
    end

    return max, cur
end

function D4:UnitAura(...)
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then return C_UnitAuras.GetAuraDataByIndex(...) end
    if UnitAura then return UnitAura(...) end
    D4:MSG("[D4][UnitAura] FAILED")

    return nil
end

function D4:LoadAddOn(name)
    if C_AddOns and C_AddOns.LoadAddOn then return C_AddOns.LoadAddOn(name) end
    if LoadAddOn then return LoadAddOn(name) end
    D4:MSG("[D4][LoadAddOn] FAILED")

    return nil
end

function D4:IsAddOnLoaded(name, from)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local loaded, _ = C_AddOns.IsAddOnLoaded(name)

        return loaded
    end

    if IsAddOnLoaded then return IsAddOnLoaded(name) end
    D4:MSG("[D4][IsAddOnLoaded] FAILED")

    return nil
end

function D4:IsAddonLoaded(name, from)
    return D4:IsAddOnLoaded(name, from)
end

function D4:AtlasExists(atlas)
    if atlas == nil then return false end
    if C_Texture and C_Texture.GetAtlasInfo(atlas) then
        return true
    elseif GetAtlasInfo and GetAtlasInfo(atlas) then
        return true
    end

    return false
end

local ICON_TAG_LIST_EN = {
    ["star"] = 1,
    ["yellow"] = 1,
    ["cirlce"] = 2,
    ["orange"] = 2,
    ["diamond"] = 3,
    ["triangle"] = 4,
    ["moon"] = 5,
    ["square"] = 6,
    ["blue"] = 6,
    ["cross"] = 7,
    ["red"] = 7,
    ["skull"] = 8,
}

local function FixIconChat(sel, event, message, author, ...)
    if ICON_LIST then
        for tag in string.gmatch(message, "%b{}") do
            local term = strlower(string.gsub(tag, "[{}]", ""))
            if ICON_TAG_LIST_EN[term] and ICON_LIST[ICON_TAG_LIST_EN[term]] then
                message = string.gsub(message, tag, ICON_LIST[ICON_TAG_LIST_EN[term]] .. "0|t")
            end
        end
    end

    return false, message, author, ...
end

D4:After(
    2,
    function()
        local chatChannels = {}
        for i, v in pairs(_G) do
            if string.find(i, "CHAT_MSG_", 1, true) and not tContains(chatChannels, i) then
                tinsert(chatChannels, i)
            end
        end

        for id, channelName in pairs(chatChannels) do
            ChatFrame_AddMessageEventFilter(channelName, FixIconChat)
        end

        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FixIconChat)
    end, "D4 1"
)

if D4:GetWoWBuild() == "CLASSIC" then
    D4:After(
        2,
        function()
            -- FIX HEALTH
            D4.fixedHealth = D4.fixedHealth or false
            if D4.fixedHealth == false then
                D4.fixedHealth = true
                local foundText = false
                local HealthBarTexts = {_G["TargetFrameHealthBar"].RightText, _G["TargetFrameHealthBar"].LeftText, _G["TargetFrameHealthBar"].TextString, _G["TargetFrameTextureFrameDeadText"]}
                for _, healthBar in pairs(HealthBarTexts) do
                    if _G["TargetFrameHealthBar"].TextString ~= nil then
                        foundText = true
                    end
                end

                if foundText == false then
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameHealthBarText", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameHealthBarTextLeft", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameHealthBarTextRight", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameManaBarText", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameManaBarTextLeft", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameManaBarTextRight", "BORDER", "TextStatusBarText")
                    _G["TargetFrameHealthBarText"]:ClearAllPoints()
                    _G["TargetFrameHealthBarTextLeft"]:ClearAllPoints()
                    _G["TargetFrameHealthBarTextRight"]:ClearAllPoints()
                    _G["TargetFrameManaBarText"]:ClearAllPoints()
                    _G["TargetFrameManaBarTextLeft"]:ClearAllPoints()
                    _G["TargetFrameManaBarTextRight"]:ClearAllPoints()
                    _G["TargetFrameHealthBarText"]:SetPoint("CENTER", _G["TargetFrameHealthBar"], "CENTER", 0, 0)
                    _G["TargetFrameHealthBarTextLeft"]:SetPoint("LEFT", _G["TargetFrameHealthBar"], "LEFT", 0, 0)
                    _G["TargetFrameHealthBarTextRight"]:SetPoint("RIGHT", _G["TargetFrameHealthBar"], "RIGHT", 0, 0)
                    _G["TargetFrameManaBarText"]:SetPoint("CENTER", _G["TargetFrameManaBar"], "CENTER", 0, 0)
                    _G["TargetFrameManaBarTextLeft"]:SetPoint("LEFT", _G["TargetFrameManaBar"], "LEFT", 2, 0)
                    _G["TargetFrameManaBarTextRight"]:SetPoint("RIGHT", _G["TargetFrameManaBar"], "RIGHT", -2, 0)
                    _G["TargetFrameHealthBar"].LeftText = _G["TargetFrameHealthBarTextLeft"]
                    _G["TargetFrameHealthBar"].RightText = _G["TargetFrameHealthBarTextRight"]
                    _G["TargetFrameManaBar"].LeftText = _G["TargetFrameManaBarTextLeft"]
                    _G["TargetFrameManaBar"].RightText = _G["TargetFrameManaBarTextRight"]
                    UnitFrameHealthBar_Initialize("target", _G["TargetFrameHealthBar"], _G["TargetFrameHealthBarText"], true)
                    UnitFrameManaBar_Initialize("target", _G["TargetFrameManaBar"], _G["TargetFrameManaBarText"], true)
                    if FocusFrame then
                        UnitFrameHealthBar_Initialize("focus", _G["FocusFrameHealthBar"], _G["FocusFrameHealthBarText"], true)
                        UnitFrameManaBar_Initialize("focus", _G["FocusFrameManaBar"], _G["FocusFrameManaBarText"], true)
                    end

                    local function TextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
                        if statusFrame.LeftText and statusFrame.RightText then
                            statusFrame.LeftText:SetText("")
                            statusFrame.RightText:SetText("")
                            statusFrame.LeftText:Hide()
                            statusFrame.RightText:Hide()
                        end

                        if (tonumber(valueMax) ~= valueMax or valueMax > 0) and not statusFrame.pauseUpdates then
                            statusFrame:Show()
                            if (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) or statusFrame.forceShow then
                                textString:Show()
                            elseif statusFrame.lockShow > 0 and (not statusFrame.forceHideText) then
                                textString:Show()
                            else
                                textString:SetText("")
                                textString:Hide()

                                return
                            end

                            if value == 0 and statusFrame.zeroText then
                                textString:SetText(statusFrame.zeroText)
                                statusFrame.isZero = 1
                                textString:Show()

                                return
                            end

                            statusFrame.isZero = nil
                            local valueDisplay = value
                            local valueMaxDisplay = valueMax
                            if statusFrame.numericDisplayTransformFunc then
                                valueDisplay, valueMaxDisplay = statusFrame.numericDisplayTransformFunc(value, valueMax)
                            else
                                valueDisplay = AbbreviateLargeNumbers(value)
                                valueMaxDisplay = AbbreviateLargeNumbers(valueMax)
                            end

                            local shouldUsePrefix = statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable))
                            local displayMode = GetCVar("statusTextDisplay")
                            if statusFrame.showNumeric then
                                displayMode = "NUMERIC"
                            end

                            if statusFrame.disablePercentages and displayMode == "PERCENT" then
                                displayMode = "NUMERIC"
                            end

                            if valueMax <= 0 or displayMode == "NUMERIC" or displayMode == "NONE" then
                                if shouldUsePrefix then
                                    textString:SetText(statusFrame.prefix .. " " .. valueDisplay .. " / " .. valueMaxDisplay)
                                else
                                    textString:SetText(valueDisplay .. " / " .. valueMaxDisplay)
                                end
                            elseif displayMode == "BOTH" then
                                if statusFrame.LeftText and statusFrame.RightText then
                                    if not statusFrame.disablePercentages and (not statusFrame.powerToken or statusFrame.powerToken == "MANA") then
                                        statusFrame.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%")
                                        statusFrame.LeftText:Show()
                                    end

                                    statusFrame.RightText:SetText(valueDisplay)
                                    statusFrame.RightText:Show()
                                    textString:Hide()
                                else
                                    valueDisplay = valueDisplay .. " / " .. valueMaxDisplay
                                    if not statusFrame.disablePercentages then
                                        valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay
                                    end
                                end

                                textString:SetText(valueDisplay)
                            elseif displayMode == "PERCENT" then
                                valueDisplay = math.ceil((value / valueMax) * 100) .. "%"
                                if shouldUsePrefix then
                                    textString:SetText(statusFrame.prefix .. " " .. valueDisplay)
                                else
                                    textString:SetText(valueDisplay)
                                end
                            end
                        else
                            textString:Hide()
                            textString:SetText("")
                            if not statusFrame.alwaysShow then
                                statusFrame:Hide()
                            else
                                statusFrame:SetValue(0)
                            end
                        end
                    end

                    hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", TextStatusBar_UpdateTextStringWithValues)
                end
            end
        end, "FixHealth"
    )
end

function D4:ReplaceStr(text, old, new)
    text = tostring(text or "")
    old = tostring(old or "")
    if old == "" then return text end
    new = tostring(new or "")
    local parts = {}
    local startPos = 1
    while true do
        local b, e = text:find(old, startPos, true)
        if not b then
            table.insert(parts, text:sub(startPos))
            break
        end

        table.insert(parts, text:sub(startPos, b - 1))
        table.insert(parts, new)
        startPos = e + 1
    end

    return table.concat(parts)
end

local genderNames = {"", "Male", "Female"}
function D4:GetClassAtlas(class)
    return ("classicon-%s"):format(class)
end

function D4:GetClassIcon(class)
    return "|A:" .. D4:GetClassAtlas(class) .. ":16:16:0:0|a"
end

function D4:GetRaceAtlas(race, gender)
    return ("raceicon-%s-%s"):format(race:lower(), gender:lower())
end

function D4:GetRaceIcon(race, gender)
    if race:lower() == "scourge" and C_Texture.GetAtlasInfo(D4:GetRaceAtlas(race, genderNames[gender])) == nil then
        race = "Undead"
    end

    local atlas = "|A:" .. D4:GetRaceAtlas(race, genderNames[gender]) .. ":16:16:0:0|a"
    if C_Texture.GetAtlasInfo(D4:GetRaceAtlas(race, genderNames[gender])) == nil then
        D4:INFO("[D4][GetRaceIcon] INVALID ATLAS", race, gender)
    end

    return atlas
end

local units = {"player"}
for i = 1, 4 do
    table.insert(units, "party" .. i)
end

for i = 1, 40 do
    table.insert(units, "raid" .. i)
end

local specIcons = {
    ["DEATHKNIGHT"] = {
        [1] = 135770,
        [2] = 135773,
        [3] = 135775,
    },
    ["DEMONHUNTER"] = {
        [1] = 1247264,
        [2] = 1247265,
    },
    ["DRUID"] = {
        [1] = 136096,
        [2] = 132115,
        [3] = 132276,
        [4] = 136041,
    },
    ["EVOKER"] = {
        [1] = 4511811,
        [2] = 4511812,
        [3] = 5198700,
    },
    ["HUNTER"] = {
        [1] = 132164,
        [2] = 132222,
        [3] = 132215,
    },
    ["MAGE"] = {
        [1] = 135932,
        [2] = 135812,
        [3] = 135846,
    },
    ["MONK"] = {
        [1] = 608951,
        [2] = 608952,
        [3] = 608953,
    },
    ["PALADIN"] = {
        [1] = 135920,
        [2] = 135893,
        [3] = 135873,
    },
    ["PRIEST"] = {
        [1] = 135940,
        [2] = 135920,
        [3] = 136207,
    },
    ["ROGUE"] = {
        [1] = 136189,
        [2] = 132282,
        [3] = 132320,
    },
    ["SHAMAN"] = {
        [1] = 136048,
        [2] = 132314,
        [3] = 136043,
    },
    ["WARLOCK"] = {
        [1] = 136145,
        [2] = 136172,
        [3] = 136186,
    },
    ["WARRIOR"] = {
        [1] = 132292,
        [2] = 132347,
        [3] = 134952,
    },
}

local classIds = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 3,
    ["ROGUE"] = 4,
    ["PRIEST"] = 5,
    ["DEATHKNIGHT"] = 6,
    ["SHAMAN"] = 7,
    ["MAGE"] = 8,
    ["WARLOCK"] = 9,
    ["MONK"] = 10,
    ["DRUID"] = 11,
    ["DEMONHUNTER"] = 12,
    ["EVOKER"] = 13,
}

local specRoless = {
    ["DEATHKNIGHT"] = {
        [1] = "TANK",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["DEMONHUNTER"] = {
        [1] = "DAMAGER",
        [2] = "TANK",
        [3] = "DAMAGER",
    },
    ["EVOKER"] = {
        [1] = "DAMAGER",
        [2] = "HEALER",
        [3] = "HEALER",
    },
    ["HUNTER"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["MAGE"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["MONK"] = {
        [1] = "TANK",
        [2] = "HEALER",
        [3] = "DAMAGER",
    },
    ["PALADIN"] = {
        [1] = "HEALER",
        [2] = "TANK",
        [3] = "DAMAGER",
    },
    ["PRIEST"] = {
        [1] = "HEALER",
        [2] = "HEALER",
        [3] = "DAMAGER",
    },
    ["ROGUE"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["SHAMAN"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "HEALER",
    },
    ["WARLOCK"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["WARRIOR"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "TANK",
    },
}

if D4:GetWoWBuild() == "RETAIL" then
    specRoless["DRUID"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "TANK",
        [4] = "HEALER",
    }
else
    specRoless["DRUID"] = {
        [1] = "DAMAGER",
        [2] = "TANK",
        [3] = "HEALER",
    }
end

function D4:GetSpecTable()
    return specRoless
end

function D4:GetRole(unit)
    if UnitGroupRolesAssigned then return UnitGroupRolesAssigned(unit) end
    D4:MSG("[D4] FAILED TO GET ROLE FOR", unit)

    return "NONE"
end

function D4:GetRoleByTab(className, specId)
    return specRoless[className][specId]
end

function D4:GetSpecIcon(className, specId)
    if specId == nil then return nil end
    if GetSpecializationInfoForClassID then
        local classId = classIds[className]
        if classId then
            local _, _, _, icon = GetSpecializationInfoForClassID(classId, specId)
            if icon then return icon end
        end
    end

    return specIcons[className][specId]
end

local icons = {}
local searchIcons = true
function D4:GetTalentIcons()
    if searchIcons then
        if GetSpecialization and GetSpecialization() then
            if GetSpecializationInfo then
                for i = 1, 4 do
                    local name, _, _, icon = GetSpecializationInfo(i)
                    if name and icon then
                        searchIcons = false
                        icons[name] = icon
                    end
                end
            end
        elseif GetPrimaryTalentTree and GetPrimaryTalentTree() then
            if GetTalentTabInfo then
                for i = 1, 4 do
                    local name, _, _, icon = GetTalentTabInfo(i)
                    if name and icon then
                        searchIcons = false
                        icons[name] = icon
                    end
                end
            end
        elseif GetTalentTabInfo then
            for i = 1, 4 do
                local name, _, _, icon = GetTalentTabInfo(i)
                if name and icon then
                    searchIcons = false
                    icons[name] = icon
                end
            end
        end
    end

    return icons
end

function D4:GetTalentInfo()
    local specid, icon
    if GetSpecialization and GetSpecialization() then
        specid = GetSpecialization()
        if GetSpecializationInfo then
            _, _, _, icon = GetSpecializationInfo(specid)
        end

        return specid, icon
    elseif D4:GetWoWBuild() ~= "TBC" and GetPrimaryTalentTree and GetPrimaryTalentTree() then
        specid = GetPrimaryTalentTree()
        if specid and GetTalentTabInfo then
            _, _, _, icon = GetTalentTabInfo(specid)
        end

        return specid, icon
    elseif GetTalentTabInfo then
        local ps = 0
        for i = 1, 4 do
            local _, _, _, iconTexture, pointsSpent = GetTalentTabInfo(i)
            if pointsSpent ~= nil and pointsSpent > ps then
                ps = pointsSpent
                specid = i
                icon = iconTexture
                local _, class = UnitClass("PLAYER")
                if GetActiveTalentGroup and class == "DRUID" and D4:GetWoWBuild() ~= "CATA" and D4:GetWoWBuild() ~= "TBC" then
                    local group = GetActiveTalentGroup()
                    local role = GetTalentGroupRole(group)
                    if role == "DAMAGER" then
                        specid = 2
                        icon = 132115
                    elseif role == "TANK" then
                        specid = 3
                    end
                end
            end

            if icon == nil then
                local _, class = UnitClass("PLAYER")
                icon = D4:GetSpecIcon(class, specid)
                if icon == nil then
                    if class == "DRUID" then
                        icon = 625999
                    elseif class == "HUNTER" then
                        icon = 626000
                    elseif class == "MAGE" then
                        icon = 626001
                    elseif class == "PALADIN" then
                        if specid == 1 then
                            icon = 135920
                        elseif specid == 2 then
                            icon = 135893
                        elseif specid == 3 then
                            icon = 135873
                        end
                    elseif class == "PRIEST" then
                        icon = 626004
                    elseif class == "ROGUE" then
                        icon = 626005
                    elseif class == "SHAMAN" then
                        icon = 626006
                    elseif class == "WARLOCK" then
                        icon = 626007
                    elseif class == "WARRIOR" then
                        icon = 626008
                    end
                end
            end
        end

        return specid, icon
    end

    return nil, nil
end

function D4:GetRoleByGuid(guid)
    if UnitGroupRolesAssigned == nil then return "NONE" end
    for i, unit in pairs(units) do
        if UnitGUID(unit) == guid then return UnitGroupRolesAssigned(unit) end
    end

    return "NONE"
end

function D4:GetRoleIcon(role)
    if role == "" then return "" end
    if role == "NONE" then return "" end
    if role == "DAMAGER" then
        return "UI-LFG-RoleIcon-DPS"
    elseif role == "HEALER" then
        return "UI-LFG-RoleIcon-HEALER"
    elseif role == "TANK" then
        return "UI-LFG-RoleIcon-TANK"
    end

    return ""
end

function D4:GetHeroSpecId()
    local heroSpecID = nil
    if C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec then
        heroSpecID = C_ClassTalents.GetActiveHeroTalentSpec()
    end

    return heroSpecID
end

function D4:GetFrameByName(name)
    local frame = _G[name]
    if type(frame) == "table" then return frame end
    if name:find("%.") then
        local parts = {strsplit(".", name)}
        frame = _G[parts[1]]
        for i = 2, #parts do
            if type(frame) ~= "table" then return nil end
            frame = frame[parts[i]]
        end

        return type(frame) == "table" and frame or nil
    end

    local baseName, index = name:match("([^%[]+)%[(%d+)%]")
    if baseName and index and index ~= nil then
        if type(index) == "string" then
            index = tonumber(index)
        end

        if type(index) ~= "number" then return nil end
        local f = _G[baseName]

        return f and select(index, f:GetRegions()) or nil
    end

    return nil
end

local f = CreateFrame("Frame")
D4:RegisterEvent(f, "PLAYER_LOGIN")
D4:OnEvent(
    f,
    function(self, event, ...)
        if GetTrackingTexture then
            local trackingTexture = GetTrackingTexture()
            if trackingTexture and MiniMapTracking and MiniMapTrackingIcon and not MiniMapTrackingIcon:GetTexture() then
                MiniMapTrackingIcon:SetTexture(trackingTexture)
                MiniMapTracking:Show()
            end
        end
    end, "MiniMapTracking"
)

function D4:DrawDebug(name, callback, fontSize, sw, sh, p1, p2, p3, p4, p5)
    sw = sw or 100
    sh = sh or 50
    p1 = p1 or "CENTER"
    p2 = p2 or UIParent
    p3 = p3 or "CENTER"
    p4 = p4 or 0
    p5 = p5 or 0
    local fDebug = CreateFrame("Frame", name)
    fDebug:SetSize(sw, sh)
    fDebug:SetPoint(p1, p2, p3, p4, p5)
    fDebug.header = fDebug:CreateFontString(nil, nil, "GameFontNormal")
    fDebug.header:SetPoint("CENTER", fDebug, "CENTER", 0, 200)
    fDebug.header:SetSize(sw, sh)
    fDebug.header:SetJustifyH("LEFT")
    --fDebug.header:SetText(name)
    if fontSize then
        D4:SetFontSize(fDebug.header, fontSize)
    end

    fDebug.text = fDebug:CreateFontString(nil, nil, "GameFontNormal")
    fDebug.text:SetPoint("CENTER", fDebug, "CENTER", 0, 0)
    fDebug.text:SetSize(sw, sh)
    fDebug.text:SetJustifyH("LEFT")
    if fontSize then
        D4:SetFontSize(fDebug.text, fontSize)
    end

    local function Think()
        local text = callback()
        fDebug.text:SetText(text)
        D4:After(
            0.2,
            function()
                Think()
            end, "D4:DD " .. name
        )
    end

    Think()

    return fDebug
end

function D4:EasyFind(word, exact)
    word = string.lower(word)
    for i, v in pairs(_G) do
        if exact then
            if i and type(i) == "string" and string.lower(i) == word then
                print("i", i, "v", v)
            end

            if v and type(v) == "string" and string.lower(v) == word then
                print("i", i, "v", v)
            end
        else
            if i and type(i) == "string" and string.find(string.lower(i), word, 1, true) then
                print("i", i, "v", v)
            end

            if v and type(v) == "string" and string.find(string.lower(v), word, 1, true) then
                print("i", i, "v", v)
            end
        end
    end
end

function D4:FindInGlobal(name, exact, ...)
    local args = {...}
    D4:After(
        0.1,
        function()
            for i, v in pairs(_G) do
                if exact then
                    if v and type(v) == "string" and v == name then
                        print("i", i, "v", v)
                    end
                else
                    if v and type(v) == "string" and string.find(v, name, 1, true) then
                        if #args > 0 then
                            local all = true
                            for x, w in pairs(args) do
                                if string.find(v, w, 1, true) == nil then
                                    all = false
                                    break
                                end
                            end

                            if all then
                                print("v", v, "i", i)
                            end
                        else
                            print("v", v, "i", i)
                        end
                    end
                end
            end
        end, "FindInGlobal"
    )
end

D4:After(
    1,
    function()
        if D4:GetWoWBuild() == "TBC" and PlayerFrame.RangeFix == nil then
            PlayerFrame.RangeFix = true
            local cufs = {}
            hooksecurefunc(
                "CompactUnitFrame_OnLoad",
                function(frame)
                    local name = frame:GetName()
                    if name and name:sub(1, 7) == "Compact" then
                        cufs[frame] = true
                    end
                end
            )

            for i = 1, 5 do
                cufs[_G["CompactPartyFrameMember" .. i]] = true
                cufs[_G["CompactPartyFramePet" .. i]] = true
            end

            C_Timer.NewTicker(
                0.29,
                function()
                    for frame in pairs(cufs) do
                        if frame and frame:IsShown() then
                            local unit = frame.displayedUnit
                            if unit and unit ~= "" then
                                local inRange = UnitInRange(unit)
                                frame:SetAlpha(inRange and 1 or 0.45)
                            end
                        end
                    end
                end
            )
        end

        if (D4:GetWoWBuild() == "TBC" or D4:GetWoWBuild() == "RETAIL") and PlayerFrame.RoleFix == nil then
            PlayerFrame.RoleFix = true
            D4:AddTrans("enUS", "LID_CHOOSEROLE", "Select Role")
            D4:AddTrans("deDE", "LID_CHOOSEROLE", "Rolle wählen")
            D4:AddTrans("enUS", "LID_NOTLEADER", "Not Leader")
            D4:AddTrans("deDE", "LID_NOTLEADER", "Nicht Anführer")
            D4:AddTrans("enUS", "LID_TANK", "Tank")
            D4:AddTrans("deDE", "LID_TANK", "Schutz")
            D4:AddTrans("enUS", "LID_HEALER", "Healer")
            D4:AddTrans("deDE", "LID_HEALER", "Heiler")
            D4:AddTrans("enUS", "LID_DAMAGER", "Damage")
            D4:AddTrans("deDE", "LID_DAMAGER", "Schadem")
            D4:AddTrans("enUS", "LID_NOROLE", "No Role")
            D4:AddTrans("deDE", "LID_NOROLE", "Keine Rolle")
            local function IsRole(unit, role)
                return UnitGroupRolesAssigned(unit) == role
            end

            local function CanClassBeRole(unit, targetRole)
                local tab = D4:GetSpecTable()
                local _, class = UnitClass(unit, targetRole)
                if tab[class] then
                    for i, role in pairs(tab[class]) do
                        if role == targetRole then return true end
                    end
                else
                    D4:MSG("[CanClassBeRole] Failed to find Class", class)
                end

                return false
            end

            local function SetupRoleMenu(ownerRegion, rootDescription, contextData)
                if D4:GetWoWBuild() == "RETAIL" then
                    local _, _, difficultyID = GetInstanceInfo()
                    if difficultyID ~= 208 then return end
                end

                if rootDescription.EnumerateElementDescriptions then
                    for _, elementData in rootDescription:EnumerateElementDescriptions() do
                        if elementData.isD4 then return end
                    end
                end

                local unit = contextData.unit
                if unit == nil then return end
                if not UnitIsPlayer(unit) then return end
                if not IsInGroup() and not IsInRaid() then return end
                local isLeader = UnitIsGroupLeader("player")
                local isAssistant = UnitIsGroupAssistant("player")
                local roleMenu = MenuUtil.CreateButton(D4:Trans("LID_CHOOSEROLE") .. " (by D4KiR)")
                roleMenu.isD4 = true
                if D4:GetWoWBuild() == "TBC" then
                    rootDescription:Insert(roleMenu, 2)
                else
                    local insertIndex = nil
                    if rootDescription.EnumerateElementDescriptions then
                        for index, elementData in rootDescription:EnumerateElementDescriptions() do
                            if elementData.text and elementData.text:find(INSTANCE_WALK_IN_LEAVE or "Leave Delve") then
                                insertIndex = index + 1
                                break
                            end
                        end
                    end

                    if insertIndex then
                        rootDescription:Insert(roleMenu, insertIndex - 1)
                    else
                        rootDescription:Insert(roleMenu, 2)
                    end
                end

                if UnitIsUnit(unit, "player") or isLeader or isAssistant then
                    roleMenu:SetEnabled(true)
                else
                    roleMenu:SetEnabled(false)
                end

                local tankBtn = roleMenu:CreateRadio(
                    "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t " .. D4:Trans("LID_TANK"),
                    function() return IsRole(unit, "TANK") end,
                    function()
                        UnitSetRole(unit, "TANK")
                    end
                )

                tankBtn:SetEnabled(CanClassBeRole(unit, "TANK"))
                local healBtn = roleMenu:CreateRadio(
                    "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t " .. D4:Trans("LID_HEALER"),
                    function() return IsRole(unit, "HEALER") end,
                    function()
                        UnitSetRole(unit, "HEALER")
                    end
                )

                healBtn:SetEnabled(CanClassBeRole(unit, "HEALER"))
                local dpsBtn = roleMenu:CreateRadio(
                    "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t " .. D4:Trans("LID_DAMAGER"),
                    function() return IsRole(unit, "DAMAGER") end,
                    function()
                        UnitSetRole(unit, "DAMAGER")
                    end
                )

                dpsBtn:SetEnabled(CanClassBeRole(unit, "DAMAGER"))
                roleMenu:CreateRadio(
                    D4:Trans("LID_NOROLE"),
                    function() return IsRole(unit, "NONE") end,
                    function()
                        UnitSetRole(unit, "NONE")
                    end
                )
            end

            local menuTypes = {"MENU_UNIT_SELF", "MENU_UNIT_TARGET", "MENU_UNIT_FOCUS", "MENU_UNIT_PARTY", "MENU_UNIT_RAID", "MENU_UNIT_PLAYER", "MENU_UNIT_RAID_PLAYER"}
            for _, menuType in ipairs(menuTypes) do
                Menu.ModifyMenu(
                    menuType,
                    function(ownerRegion, rootDescription, contextData)
                        SetupRoleMenu(ownerRegion, rootDescription, contextData, "target")
                    end
                )
            end
        end
    end, "SetRole FIX"
)

local inspectCache = {}
local itemLevelCache = {}
local CACHE_DURATION = 3600
function D4:GetInspectILvl(unit)
    local totalLevel = 0
    local itemCount = 0
    local slots = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
    for _, slotId in ipairs(slots) do
        local itemLink = GetInventoryItemLink(unit, slotId)
        if itemLink then
            local _, _, _, itemLevel = GetItemInfo(itemLink)
            if itemLevel and itemLevel > 0 then
                totalLevel = totalLevel + itemLevel
                itemCount = itemCount + 1
            end
        end
    end

    if itemCount == 0 then return 0 end

    return totalLevel / itemCount
end

function D4:GetInspectCache(guid)
    local data = inspectCache[guid]
    if data then
        if GetTime() < data then
            return data
        else
            inspectCache[guid] = nil
        end
    end

    return nil
end

function D4:SaveToInspectCache(guid)
    inspectCache[guid] = GetTime() + 4
end

function D4:GetCachedItemLevel(guid)
    local data = itemLevelCache[guid]
    if data then
        if GetTime() < data.expires then
            return data.ilevel
        else
            itemLevelCache[guid] = nil
        end
    end

    return nil
end

function D4:SaveToItemLevelCache(guid, ilevel)
    itemLevelCache[guid] = {
        ilevel = ilevel,
        expires = GetTime() + CACHE_DURATION
    }
end
