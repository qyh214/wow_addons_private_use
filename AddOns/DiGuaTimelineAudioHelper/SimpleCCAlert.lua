
-- -- ==========================================
-- -- 姓名板下方：绿色圆环施法提示
-- -- ==========================================
-- local InterruptAlertFrame = CreateFrame("Frame")
-- InterruptAlertFrame.rings = {} 
-- local plateref = {}

-- -- 贴图路径（确保路径正确）
-- local RING_PATH = [[Interface\AddOns\DiGuaTimelineAudioHelper\Ring_20px.tga]]

-- local function ShowInterruptRing(u)
--     local plate = C_NamePlate.GetNamePlateForUnit(u)
--     if not plate then return end
--     local interruptible = select(7, UnitChannelInfo(u))
--     -- 防止重复显示
--     if plateref[u] and InterruptAlertFrame.rings[plateref[u]]:IsShown() then return end

--     local i = #InterruptAlertFrame.rings + 1
    
--     -- 1. 创建环形容器
--     local ring = CreateFrame("Frame", nil, InterruptAlertFrame)
--     ring:SetSize(100, 100) -- 圆环大小
    
--     -- 3. 创建绿色圆环 (主体)
--     local fg = ring:CreateTexture(nil, "BACKGROUND")
--     fg:SetAllPoints()
--     fg:SetTexture(RING_PATH)
--     fg:SetVertexColor(0, 1, 0, 1) -- 纯绿色
--     fg:SetAlphaFromBoolean(interruptible, 0.5, 1)
--     -- 4. 位置控制：姓名板下方 100 像素
--     ring:SetPoint("TOP", plate, "BOTTOM", 0, -20)
    
--     -- 显示
--     ring:Show()
    
--     InterruptAlertFrame.rings[i] = ring
--     plateref[u] = i
-- end

-- -- 事件逻辑
-- InterruptAlertFrame:SetScript("OnEvent", function(self, e, u)
--     if not u or not u:find("^nameplate%d") then return end
--     if u and u:find("nameplate") and UnitCanAttack("player", u) then
--         if e == "UNIT_SPELLCAST_CHANNEL_START" or e == "UNIT_AURA" then
--             print("UNIT_SPELLCAST_CHANNEL_START")
--             local aura1 = C_UnitAuras.GetAuraDataByIndex(u, 1, "HELPFUL")
--             if not aura1 then
--                 print("UNIT_AURA")
--                 ShowInterruptRing(u)
--             end

--         elseif e == "NAME_PLATE_UNIT_REMOVED" then
--             if plateref[u] then
--                 local ring = InterruptAlertFrame.rings[plateref[u]]
--                 if ring then
--                     ring:Hide()
--                 end
--                 plateref[u] = nil
--             end
--         end
--     end
-- end)

-- InterruptAlertFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
-- InterruptAlertFrame:RegisterEvent("UNIT_AURA")
-- InterruptAlertFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

-- print("|cff00ff00绿色圆环提示已加载！位置：姓名板下方100像素|r")



-- 创建一个核心的隐藏框架来处理所有事件
local CCAlertFrame = CreateFrame("Frame")
local encID = 3179
local platetexts = {}
local plateref = {}

-- 简单的难度检查 (14 = 正常团队副本史诗难度, 16 = 史诗难度)
local function IsMythicDifficulty()
    local _, _, difficultyID = GetInstanceInfo()
    return difficultyID == 16 
end

-- 核心：显示姓名板文本
local function DisplayNameplateText(u)
    local plate = C_NamePlate.GetNamePlateForUnit(u)
    if plate then
        local interruptible = select(8, UnitCastingInfo(u))
        for i = 1, #platetexts + 1 do
            if platetexts[i] and not platetexts[i]:IsShown() then
                platetexts[i]:SetText("CC")
                platetexts[i].bgTexture:SetColorTexture(0, 1, 0, 0.8)
                platetexts[i]:ClearAllPoints()
                platetexts[i]:SetPoint("BOTTOM", plate, "TOP", 0, 0)
                platetexts[i]:Show()
                platetexts[i].bgFrame:Show()
                platetexts[i].unit = u
                plateref[u] = i
                if issecretvalue(interruptible) then
                    platetexts[i]:SetAlphaFromBoolean(not interruptible, 0, 1)
                    platetexts[i].bgFrame:SetAlphaFromBoolean(not interruptible, 0, 1)
                end
                return
            elseif not platetexts[i] then
                platetexts[i] = CCAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                -- 独立运行时使用系统默认标准字体
                platetexts[i]:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE") 
                platetexts[i]:SetPoint("BOTTOM", plate, "TOP", 0, 0)
                platetexts[i]:SetShadowColor(0, 0, 0, 1)
                platetexts[i]:SetTextColor(1, 1, 1, 1)
                
                platetexts[i].bgFrame = CreateFrame("Frame", nil, CCAlertFrame)
                platetexts[i].bgFrame:SetFrameStrata("BACKGROUND")
                platetexts[i].bgTexture = platetexts[i].bgFrame:CreateTexture(nil, "BACKGROUND")
                platetexts[i].bgTexture:SetColorTexture(0, 1, 0, 0.8)
                platetexts[i].bgTexture:SetAllPoints(platetexts[i].bgFrame)
                platetexts[i].bgFrame:SetSize(25, 25)
                platetexts[i].bgFrame:SetPoint("CENTER", platetexts[i], "CENTER", 0, 0)
                
                platetexts[i]:SetText("CC")
                platetexts[i]:Show()
                platetexts[i].bgFrame:Show()
                platetexts[i].unit = u
                plateref[u] = i
                if issecretvalue(interruptible) then
                    platetexts[i]:SetAlphaFromBoolean(not interruptible, 0, 1)
                    platetexts[i].bgFrame:SetAlphaFromBoolean(not interruptible, 0, 1)
                end
                return
            end
        end
    end
end

-- 核心：更新姓名板
local function UpdateNameplateTexts(e, u)
    if e == "NAME_PLATE_UNIT_REMOVED" then
        if plateref[u] then
            if platetexts[plateref[u]] then
                platetexts[plateref[u]]:Hide()
                platetexts[plateref[u]].bgFrame:Hide()
                platetexts[plateref[u]].unit = nil
                plateref[u] = nil
                return
            end
        end
        for i, v in ipairs(platetexts) do
            if v.unit == u then
                v:Hide()
                v.bgFrame:Hide()
                v.unit = nil
            end
        end
    elseif e == "NAME_PLATE_UNIT_ADDED" or e == "UNIT_AURA" or e == "UNIT_SPELLCAST_START" then
        if (e == "UNIT_AURA" or e == "UNIT_SPELLCAST_START") and not u:find("^nameplate%d") then return end
        if UnitLevel(u) ~= -1 then
            local aura1 = C_UnitAuras.GetAuraDataByIndex(u, 1, "HELPFUL")
            if aura1 then -- 目标身上有特定增益时触发
                if plateref[u] and platetexts[plateref[u]] then
                    platetexts[plateref[u]]:Hide()
                    platetexts[plateref[u]].bgFrame:Hide()
                    platetexts[plateref[u]].unit = nil
                    plateref[u] = nil
                end
                DisplayNameplateText(u)
            end
        end
    end
end

-- 战斗事件分发器
CCAlertFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        local encounterID = ...
        if encounterID == encID and IsMythicDifficulty() then
            self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
            self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
            self:RegisterEvent("UNIT_AURA")
            self:RegisterEvent("UNIT_SPELLCAST_START")
            self:Show()
        end
    elseif event == "ENCOUNTER_END" then
        local encounterID = ...
        if encounterID == encID then
            for i, v in ipairs(platetexts) do
                v:Hide()
                if v.bgFrame then v.bgFrame:Hide() end
            end
            self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
            self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
            self:UnregisterEvent("UNIT_AURA")
            self:UnregisterEvent("UNIT_SPELLCAST_START")
            self:Hide()
        end
    else
        -- 处理姓名板相关事件
        local unit = ...
        UpdateNameplateTexts(event, unit)
    end
end)

-- 基础监听首领战开启与结束
CCAlertFrame:RegisterEvent("ENCOUNTER_START")
CCAlertFrame:RegisterEvent("ENCOUNTER_END")
CCAlertFrame:Hide()