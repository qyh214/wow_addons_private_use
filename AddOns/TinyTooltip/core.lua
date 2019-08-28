
-------------------------------------
-- Core Author:M
-------------------------------------

TinyTooltip = {}

local LibEvent = LibStub:GetLibrary("LibEvent.7000")
local LibMedia = LibStub:GetLibrary("LibSharedMedia-3.0", true)

local AFK = AFK
local DND = DND
local MALE = MALE
local BOSS = BOSS
local DEAD = DEAD
local ELITE = ELITE
local FEMALE = FEMALE
local TARGET = TARGET
local PLAYER = PLAYER
local RARE = GARRISON_MISSION_RARE
local OFFLINE = FRIENDS_LIST_OFFLINE
local BASE_MOVEMENT_SPEED = BASE_MOVEMENT_SPEED or 7

--BLZ function (Fixed for classic WOW)
local UnitEffectiveLevel = UnitEffectiveLevel or function() end
local UnitGroupRolesAssigned = UnitGroupRolesAssigned or function() end
local UnitGroupRolesAssigned = UnitGroupRolesAssigned  or function() end
local UnitIsQuestBoss = UnitIsQuestBoss or function() end
local IsFlying = IsFlying or function() end

local addon = TinyTooltip

-- language & global vars
addon.L, addon.G = {}, {}
setmetatable(addon.L, {__index = function(_, k) return k end})
setmetatable(addon.G, {__index = function(_, k) return _G[k] or k end})

-- tooltips
addon.tooltips = {
    GameTooltip,
    ItemRefTooltip,
    ShoppingTooltip1,
    ShoppingTooltip2,
    WorldMapTooltip,
    ItemRefShoppingTooltip1,
    ItemRefShoppingTooltip2,
    NamePlateTooltip,
}

-- 圖標集
addon.icons = {
    Alliance  = "|TInterface\\TargetingFrame\\UI-PVP-ALLIANCE:14:14:0:0:64:64:10:36:2:38|t",
    Horde     = "|TInterface\\TargetingFrame\\UI-PVP-HORDE:14:14:0:0:64:64:4:38:2:36|t",
    Neutral   = "|TInterface\\Timer\\Panda-Logo:14|t",
    pvp       = "|TInterface\\TargetingFrame\\UI-PVP-FFA:14:14:0:0:64:64:10:36:0:38|t",
    class     = "|TInterface\\TargetingFrame\\UI-Classes-Circles:14:14:0:0:256:256:%d:%d:%d:%d|t",
    battlepet = "|TInterface\\Timer\\Panda-Logo:15|t",
    pettype   = "|TInterface\\TargetingFrame\\PetBadge-%s:14|t",
    questboss = "|TInterface\\TargetingFrame\\PortraitQuestBadge:0|t",
    TANK      = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:0:19:22:41|t",
    HEALER    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:1:20|t",
    DAMAGER   = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:22:41|t",
}

-- 背景
addon.bgs = {
    gradual = "Interface\\Buttons\\GreyscaleRamp64",
    dark    = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    alpha   = "Interface\\Tooltips\\UI-Tooltip-Background",
    rock    = "Interface\\FrameGeneral\\UI-Background-Rock",
    marble  = "Interface\\FrameGeneral\\UI-Background-Marble",
}

-- 配置 (elements鍵不合併)
function addon:MergeVariable(src, dst)
    dst.version = src.version
    for k, v in pairs(src) do
        if (dst[k] == nil) then
            dst[k] = v
        elseif (type(dst[k]) == "table" and k~="elements") then
            self:MergeVariable(v, dst[k])
        end
    end
    return dst
end

-- 找行
function addon:FindLine(tooltip, keyword)
    local line, text
    for i = 2, tooltip:NumLines() do
        line = _G[tooltip:GetName() .. "TextLeft" .. i]
        text = line:GetText() or ""
        if (strfind(text, keyword)) then
            return line, i, _G[tooltip:GetName() .. "TextRight" .. i]
        end
    end
end

-- 刪行
function addon:HideLine(tooltip, keyword)
    local line, text
    for i = 2, tooltip:NumLines() do
        line = _G[tooltip:GetName() .. "TextLeft" .. i]
        text = line:GetText() or ""
        if (strfind(text, keyword)) then
            line:SetText(nil)
            break
        end
    end
end

-- 刪行
function addon:HideLines(tooltip, number, endNumber)
    endNumber = endNumber or 999
    for i = number, tooltip:NumLines() do
        if (endNumber >= i) then
            _G[tooltip:GetName() .. "TextLeft" .. i]:SetText(nil)
        end
    end
end

-- 取行
function addon:GetLine(tooltip, number)
    local num = tooltip:NumLines()
    if (number > num) then
        tooltip:AddLine(" ")
        return self:GetLine(tooltip, num+1)
    end
    return _G[tooltip:GetName() .. "TextLeft" .. number], _G[tooltip:GetName() .. "TextRight" .. number]
end

-- 顔色
function addon:GetHexColor(color, g, b)
    if (g and b) then
        return ("%02x%02x%02x"):format(color*255, g*255, b*255)
    elseif color.r then
        return ("%02x%02x%02x"):format(color.r*255, color.g*255, color.b*255)
    else
        local r, g, b = unpack(color)
        return ("%02x%02x%02x"):format(r*255, g*255, b*255)
    end
end

-- 顔色
function addon:GetRGBColor(hex)
    if (not hex) then return 1, 1, 1 end
    if (string.match(hex, "^%x%x%x%x%x%x$")) then
        local r = tonumber(strsub(hex,1,2),16) or 255
        local g = tonumber(strsub(hex,3,4),16) or 255
        local b = tonumber(strsub(hex,5,6),16) or 255
        return r/255, g/255, b/255
    end
end

--字體
function addon:GetFont(font, default)
    if (font == "default") then
        font = default
    elseif (font and _G[font]) then
        font = _G[font].GetFont and _G[font]:GetFont()
    elseif(font and LibMedia and LibMedia:IsValid("font", font)) then
        font = LibMedia:Fetch("font", font)
    end
    return font or default
end

--背景
function addon:GetBgFile(bgvalue)
    if (self.bgs[bgvalue]) then
        return self.bgs[bgvalue]
    end
    if (LibMedia) then
        return LibMedia:Fetch("background", bgvalue)
    end
end

--Bar
function addon:GetBarFile(bgvalue)
    if (bgvalue and LibMedia and LibMedia:IsValid("statusbar", bgvalue)) then
        return LibMedia:Fetch("statusbar", bgvalue)
    else
        return bgvalue
    end
end

-- 任務怪
function addon:GetQuestBossIcon(unit)
    if UnitIsQuestBoss(unit) then
        return self.icons.questboss
    end
end

-- PVP圖標
function addon:GetPVPIcon(unit)
    if (UnitIsPVPFreeForAll(unit)) then
        return self.icons.pvp
    end
end

-- 角色圖標
function addon:GetRoleIcon(unit)
    local role = UnitGroupRolesAssigned(unit)
    if (role) then
        return self.icons[strupper(role)]
    end
end

-- 陣營圖標
function addon:GetFactionIcon(factionGroup)
    return self.icons[factionGroup]
end

-- 標記圖標
function addon:GetRaidIcon(unit)
    local index = GetRaidTargetIndex(unit)
    if (index and ICON_LIST[index]) then
        return ICON_LIST[index] .. "0|t"
    end
end

-- 職業圖標
function addon:GetClassIcon(class)
    if (not class) then return end
    local x1, x2, y1, y2 = unpack(CLASS_ICON_TCOORDS[strupper(class)])
    return format(self.icons.class, x1*256, x2*256, y1*256, y2*256)
end

-- 戰寵
function addon:GetBattlePet(unit)
    if (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
        local petType = UnitBattlePetType(unit)
        return self.icons.battlepet, format(self.icons.pettype, PET_TYPE_SUFFIX[petType] or "")
    end
end

-- 移動速度
function addon:GetUnitSpeed(unit)
    local _, speed, flightSpeed, swimSpeed = GetUnitSpeed(unit)
    if (not speed or speed == 0) then return end
    speed = speed/BASE_MOVEMENT_SPEED*100
    swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100
	flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100
	if (UnitIsOtherPlayersPet(unit)) then
    elseif (IsSwimming(unit)) then
		speed = swimSpeed
	elseif (IsFlying(unit)) then
		speed = flightSpeed
	end
    return speed+0.5
end

-- 頭銜 @param2:true為前綴
function addon:GetTitle(name, pvpName)
    if (not pvpName) then return end
    if (name == pvpName) then return end
    local pos = string.find(pvpName, name)
    local title = pvpName:gsub(name, "", 1)
    title = title:gsub(",", ""):gsub("，", "")
    title = strtrim(title)
    return title, pos ~= 1
end

-- 性別
function addon:GetGender(gender)
    if (gender == 2) then
        return MALE, "male"
    elseif (gender == 3) then
        return FEMALE, "female"
    end
end

-- NPC頭銜
function addon:GetNpcTitle(tip)
    local line, index = self:FindLine(tip, "^"..LEVEL)
    if (not line or index <= 2) then return end
    return self:GetLine(tip, 2)
end

--地區
function addon:GetZone(unit, unitname, realm)
    if not IsInGroup() then return end
    local t, i = string.match(unit, "(.-)(%d+)")
    if (i and t == "raid") then
        return select(7, GetRaidRosterInfo(i))
    elseif (i and t == "party") then
        local name, zone
        local fullname = unitname .. "-" .. realm
        for j = 1, 5 do
            name, _, _, _, _, _, zone = GetRaidRosterInfo(j)
            if (name and not string.find(name, "-") and name == unitname) then
                return zone
            elseif (name and string.find(name, "-") and name == fullname) then
                return zone
            end
        end
    end
end

-- 全信息
local t = {}
function addon:GetUnitInfo(unit)
    local name, realm = UnitName(unit)
    local pvpName = UnitPVPName(unit)
    local gender = UnitSex(unit)
    local level = UnitLevel(unit)
    local effectiveLevel = UnitEffectiveLevel(unit)
    local raceName, race = UnitRace(unit)
    local className, class = UnitClass(unit)
    local factionGroup, factionName = UnitFactionGroup(unit)
    local reaction = UnitReaction(unit, "player")
    local guildName, guildRank, guildIndex, guildRealm = GetGuildInfo(unit)
    local classif = UnitClassification(unit)
    local role = UnitGroupRolesAssigned(unit)

    t.raidIcon     = self:GetRaidIcon(unit)
    t.pvpIcon      = self:GetPVPIcon(unit)
    t.factionIcon  = self:GetFactionIcon(factionGroup)
    t.classIcon    = self:GetClassIcon(class)
    t.roleIcon     = self:GetRoleIcon(unit)
    t.questIcon    = self:GetQuestBossIcon(unit)
    --t.battlepetIcon = self:GetBattlePet(unit)
    t.factionName  = factionName
    t.role         = role ~= "NONE" and role
    t.name         = name
    t.gender       = self:GetGender(gender)
    t.realm        = realm or GetRealmName()
    t.levelValue   = level >= 0 and level or "??"
    t.className    = className
    t.raceName     = raceName
    t.guildName    = guildName
    t.guildRank    = guildRank
    t.guildIndex   = guildName and guildIndex
    t.guildRealm   = guildRealm
    t.statusAFK    = UnitIsAFK(unit) and AFK
    t.statusDND    = UnitIsDND(unit) and DND
    t.statusDC     = not UnitIsConnected(unit) and OFFLINE
    t.reactionName = reaction and _G["FACTION_STANDING_LABEL"..reaction]
    t.creature     = UnitCreatureType(unit)
    t.classifBoss  = (level==-1 or classif == "worldboss") and BOSS
    t.classifElite = classif == "elite" and ELITE
    t.classifRare  = (classif == "rare" or classif == "rareelite") and RARE
    t.isPlayer     = UnitIsPlayer(unit) and PLAYER
    t.moveSpeed    = self:GetUnitSpeed(unit)
    t.zone         = self:GetZone(unit, t.name, t.realm)
    t.unit         = unit                     --unit
    t.level        = level                    --1~123|-1
    t.effectiveLevel = effectiveLevel or level
    t.race         = race                     --nil|NightElf|Troll...
    t.class        = class                    --DRUID|HUNTER...
    t.factionGroup = factionGroup             --Alliance|Horde|Neutral
    t.reaction     = reaction                 --nil|1|2|3|4|5|6|7|8
    t.classif      = classif                  --normal|worldboss|elite|rare|rareelite
    t.title, t.titleIsPrefix = self:GetTitle(name, pvpName)
    if (t.classifBoss) then t.classifElite = false end
    return t
end

-- Filter
function addon:CheckFilter(config, raw)
    if (IsAltKeyDown() or IsControlKeyDown()) then return true end
    if (not config.enable) then return end
    if (config.filter == "" or config.filter == "none") then
        return true
    end
    if (config.filter) then
        local key, oppo, func
        key = strsplit(":", config.filter)
        key, oppo = key:gsub("not%s+", "")
        func = self.filterfunc[key]
        if (func) then
            local res = func(raw, select(2,strsplit(":", config.filter)))
            if (oppo > 0) then
                return not res
            else
                return res
            end
        end
    end
    return true
end

-- 格式化數據
function addon:FormatData(value, config, raw)
    local color, wildcard = config.color, config.wildcard
    if (self.colorfunc[color]) then
        color = select(4, self.colorfunc[color](raw))
    end
    if (color == "" or color == "default" or color == "none") then
        return (wildcard):format(value)
    else
        if (type(color)=="table") then color = self:GetHexColor(color) end
        return ("|cff"..color..wildcard.."|r"):format(value)
    end
end

-- 獲取數據
function addon:GetUnitData(unit, elements, raw)
    local data = {}
    local config, name, title
    if (not raw) then
        raw = self:GetUnitInfo(unit)
    end
    for i, v in ipairs(elements) do
        data[i] = {}
        for ii, e in ipairs(v) do
            config = elements[e]
            if (self:CheckFilter(config, raw) and raw[e]) then
                if (e == "name") then name = #data[i]+1 end   --name位置
                if (e == "title") then title = #data[i]+1 end --title位置
                if (config.color and config.wildcard) then
                    if (e == "title" and name == #data[i] and raw.titleIsPrefix) then
                        tinsert(data[i], name, self:FormatData(raw[e], config, raw))
                    elseif (e == "name" and title == #data[i] and not raw.titleIsPrefix) then
                        tinsert(data[i], title, self:FormatData(raw[e], config, raw))
                    else
                        tinsert(data[i], self:FormatData(raw[e], config, raw))
                    end
                else
                    tinsert(data[i], raw[e])
                end
            end
        end
    end
    for i = #data, 1, -1 do
        if (not data[i][1]) then tremove(data, i) end
    end
    return data
end


addon.filterfunc, addon.colorfunc = {}, {}

addon.colorfunc.class = function(raw)
    if (CUSTOM_CLASS_COLORS) then
        local color = CUSTOM_CLASS_COLORS[raw.class]
        if color then
            return color.r, color.g, color.b, addon:GetHexColor(color.r, color.g, color.b)
        end
        return 1, 1, 1, "ffffff"
    end
    local r, g, b = GetClassColor(raw.class)
    return r, g, b, addon:GetHexColor(r, g, b)
end

addon.colorfunc.level = function(raw)
    local color = GetCreatureDifficultyColor(raw.effectiveLevel>0 and raw.effectiveLevel or 999)
    return color.r, color.g, color.b, addon:GetHexColor(color)
end

addon.colorfunc.reaction = function(raw)
    local color = FACTION_BAR_COLORS[raw.reaction or 4]
    return color.r, color.g, color.b, addon:GetHexColor(color)
end

addon.colorfunc.itemQuality = function(raw)
    local color = ITEM_QUALITY_COLORS[raw.itemQuality or 0]
    return color.r, color.g, color.b, addon:GetHexColor(color)
end

addon.colorfunc.selection = function(raw)
    local r, g, b = UnitSelectionColor(raw.unit)
    return r, g, b, addon:GetHexColor(r, g, b)
end

addon.colorfunc.faction = function(raw)
    if (raw.factionGroup == "Neutral") then
        return 0.9, 0.7, 0, "e5b200"
    elseif (raw.factionGroup == UnitFactionGroup("player")) then
        return 0, 1, 0.2, "00cc33"
    else
        return 1, 0.2, 0, "dd3300"
    end
end

addon.filterfunc.reaction6 = function(raw, reaction)
    return (raw.reaction or 4) >= 6
end

addon.filterfunc.reaction5 = function(raw, reaction)
    return (raw.reaction or 4) >= 5
end

addon.filterfunc.reaction = function(raw, reaction)
    return (raw.reaction or 4) >= (tonumber(reaction) or 5)
end

addon.filterfunc.inraid = function(raw)
    return IsInRaid()
end

addon.filterfunc.incombat = function(raw)
    return InCombatLockdown()
end

addon.filterfunc.samerealm = function(raw)
    return raw.realm == GetRealmName()
end

addon.filterfunc.samecrossrealm = function(raw)
    return UnitRealmRelationship(raw.unit) == LE_REALM_RELATION_SAME
end

addon.filterfunc.inpvp = function(raw)
    return select(2, IsInInstance()) == "pvp"
end

addon.filterfunc.inarena = function(raw)
    return select(2, IsInInstance()) == "arena"
end

addon.filterfunc.ininstance = function(raw)
    return IsInInstance()
end

addon.filterfunc.sameguild = function(raw)
    local name, _, _, server = GetGuildInfo("player")
    if (name and name == raw.guildName and server == raw.guildRealm) then
        return true
    end
end

LibEvent:attachTrigger("tooltip.scale", function(self, frame, scale)
    frame:SetScale(scale)
end)

LibEvent:attachTrigger("tooltip.anchor.cursor", function(self, frame, parent)
    frame:SetOwner(parent, "ANCHOR_CURSOR")
end)

LibEvent:attachTrigger("tooltip.anchor.cursor.right", function(self, frame, parent, offsetX, offsetY)
    frame:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", tonumber(offsetX) or 30, tonumber(offsetY) or -12)
end)

LibEvent:attachTrigger("tooltip.anchor.static", function(self, frame, parent, offsetX, offsetY, anchorPoint)
    local anchor = select(2, frame:GetPoint())
    if (anchor == UIParent) then
        frame:ClearAllPoints()
        frame:SetPoint(anchorPoint or "BOTTOMRIGHT", UIParent, anchorPoint or "BOTTOMRIGHT", tonumber(offsetX) or (-CONTAINER_OFFSET_X-13), tonumber(offsetY) or CONTAINER_OFFSET_Y)
    end
end)

LibEvent:attachTrigger("tooltip.anchor.none", function(self, frame, parent)
    frame:SetOwner(parent, "ANCHOR_NONE")
    frame:Hide()
end)

LibEvent:attachTrigger("tooltip.style.mask", function(self, frame, boolean)
    LibEvent:trigger("tooltip.style.init", frame)
    frame.style.mask:SetShown(boolean)
end)

LibEvent:attachTrigger("tooltip.style.background", function(self, frame, r, g, b, a)
    LibEvent:trigger("tooltip.style.init", frame)
    local rr, gg, bb, aa = frame.style:GetBackdropColor()
    if (rr ~= r or gg ~= g or bb ~= b or aa ~= a) then
        frame.style:SetBackdropColor(r or rr, g or gg, b or bb, a or aa)
    end
end)

LibEvent:attachTrigger("tooltip.style.bgfile", function(self, frame, bgvalue)
    LibEvent:trigger("tooltip.style.init", frame)
    local bgfile = addon:GetBgFile(bgvalue)
    local backdrop = frame.style:GetBackdrop()
    local r, g, b, a = frame.style:GetBackdropColor()
    local rr, gg, bb, aa = frame.style:GetBackdropBorderColor()
    if (backdrop.bgFile ~= bgfile) then
        backdrop.bgFile = bgfile
        frame.style:SetBackdrop(backdrop)
        frame.style:SetBackdropColor(r, g, b, a)
        frame.style:SetBackdropBorderColor(rr, gg, bb, aa)
    end
end)

LibEvent:attachTrigger("tooltip.style.border.size", function(self, frame, size)
    LibEvent:trigger("tooltip.style.init", frame)
    local backdrop = frame.style:GetBackdrop()
    local r, g, b, a = frame.style:GetBackdropColor()
    if (backdrop.edgeFile == "Interface\\Buttons\\WHITE8X8") then
        backdrop.edgeSize = size
        backdrop.insets.top = size
        backdrop.insets.left = size
        backdrop.insets.right = size
        backdrop.insets.bottom = size
        frame.style:SetBackdrop(backdrop)
        frame.style:SetBackdropColor(r, g, b, a)
        frame.style.inside:SetPoint("TOPLEFT", frame.style, "TOPLEFT", size, -size)
        frame.style.inside:SetPoint("BOTTOMRIGHT", frame.style, "BOTTOMRIGHT", -size, size)
    end
end)

LibEvent:attachTrigger("tooltip.style.border.corner", function(self, frame, corner)
    LibEvent:trigger("tooltip.style.init", frame)
    local backdrop = frame.style:GetBackdrop()
    local r, g, b, a = frame.style:GetBackdropColor()
    if (corner == "angular") then
        backdrop.edgeFile = "Interface\\Buttons\\WHITE8X8"
        backdrop.edgeSize = min(backdrop.edgeSize, 6)
        frame.style.mask:SetPoint("TOPLEFT", 1, -1)
        frame.style.mask:SetPoint("BOTTOMRIGHT", frame.style, "TOPRIGHT", -1, -32)
        frame.style.outside:Show()
        frame.style.inside:Show()
        frame.style.inside:SetPoint("TOPLEFT", frame.style, "TOPLEFT", backdrop.edgeSize, -backdrop.edgeSize)
        frame.style.inside:SetPoint("BOTTOMRIGHT", frame.style, "BOTTOMRIGHT", -backdrop.edgeSize, backdrop.edgeSize)
    elseif (LibMedia and LibMedia:IsValid("border", corner)) then
        backdrop.edgeFile = LibMedia:Fetch("border", corner)
        backdrop.edgeSize = 14
        backdrop.insets.top = 3
        backdrop.insets.left = 3
        backdrop.insets.right = 3
        backdrop.insets.bottom = 3
        frame.style.mask:SetPoint("TOPLEFT", 3, -3)
        frame.style.mask:SetPoint("BOTTOMRIGHT", frame.style, "TOPRIGHT", -3, -32)
        frame.style.inside:Hide()
        frame.style.outside:Hide()
    else
        backdrop.edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"
        backdrop.edgeSize = 14
        backdrop.insets.top = 3
        backdrop.insets.left = 3
        backdrop.insets.right = 3
        backdrop.insets.bottom = 3
        frame.style.mask:SetPoint("TOPLEFT", 3, -3)
        frame.style.mask:SetPoint("BOTTOMRIGHT", frame.style, "TOPRIGHT", -3, -32)
        frame.style.inside:Hide()
        frame.style.outside:Hide()
    end
    frame.style:SetBackdrop(backdrop)
    frame.style:SetBackdropColor(r, g, b, a)
end)

LibEvent:attachTrigger("tooltip.style.border.color", function(self, frame, r, g, b, a)
    LibEvent:trigger("tooltip.style.init", frame)
    local rr, gg, bb, aa = frame.style:GetBackdropBorderColor()
    if (rr ~= r or gg ~= g or bb ~= b or aa ~= a) then
        frame.style:SetBackdropBorderColor(r or rr, g or gg, b or bb, a or aa)
    end
end)

local defaultHeaderFont, defaultHeaderSize, defaultHeaderFlag = GameTooltipHeaderText:GetFont()
LibEvent:attachTrigger("tooltip.style.font.header", function(self, frame, fontObject, fontSize, fontFlag)
    local font, size, flag = GameTooltipHeaderText:GetFont()
    font = addon:GetFont(fontObject, defaultHeaderFont)
    if (fontSize == "default") then
        size = defaultHeaderSize
    elseif (type(fontSize) == "number") then
        size = fontSize
    end
    if (fontFlag == "default") then
        flag = defaultHeaderFlag
    else
        flag = fontFlag or flag
    end
    GameTooltipHeaderText:SetFont(font, size, flag)
end)

local defaultBodyFont, defaultBodySize, defaultBodyFlag = GameTooltipText:GetFont()
LibEvent:attachTrigger("tooltip.style.font.body", function(self, frame, fontObject, fontSize, fontFlag)
    local font, size, flag = GameTooltipHeaderText:GetFont()
    font = addon:GetFont(fontObject, defaultBodyFont)
    if (fontSize == "default") then
        size = defaultBodySize
    elseif (type(fontSize) == "number") then
        size = fontSize
    end
    if (fontFlag == "default") then
        flag = defaultBodyFlag
    else
        flag = fontFlag or flag
    end
    GameTooltipText:SetFont(font, size, flag)
end)

LibEvent:attachTrigger("tooltip.statusbar.height", function(self, height)
    GameTooltipStatusBar:SetHeight(height or 12)
end)

LibEvent:attachTrigger("tooltip.statusbar.text", function(self, boolean)
    GameTooltipStatusBar.forceHideText = not boolean
end)

LibEvent:attachTrigger("tooltip.statusbar.font", function(self, font, size, flag)
    if (not GameTooltipStatusBar.TextString) then return end
    local origFont, origSize, origFlag = GameTooltipStatusBar.TextString:GetFont()
    font = addon:GetFont(font, NumberFontNormal:GetFont())
    if (flag == "default") then flag = "THINOUTLINE" end
    if (font ~= origFont or size ~= origSize or flag ~= origFlag) then
        GameTooltipStatusBar.TextString:SetFont(font or origFont, size or origSize, flag or origFlag)
    end
end)

LibEvent:attachTrigger("tooltip.statusbar.texture", function(self, bgvalue)
    GameTooltipStatusBar:SetStatusBarTexture(addon:GetBarFile(bgvalue))
end)

LibEvent:attachTrigger("tooltip.statusbar.position", function(self, position, offsetX, offsetY)
    LibEvent:trigger("tooltip.style.init", GameTooltip)
    GameTooltip.style:ClearAllPoints()
    GameTooltipStatusBar:ClearAllPoints()
    local backdrop = GameTooltip.style:GetBackdrop()
    if (not GameTooltipStatusBar:IsShown()) then position = "" end
    if (position == "bottom") then
        local offset = backdrop.edgeFile == "Interface\\Tooltips\\UI-Tooltip-Border" and 5 or backdrop.edgeSize + 1
        if (not offsetX or offsetX == 0) then offsetX = offset end
        if (not offsetY or offsetY == 0) then offsetY = -offset end
        GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", offsetX, 2)
        GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -offsetX, 2)
        GameTooltip.style:SetPoint("TOPLEFT")
        GameTooltip.style:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar, "BOTTOMRIGHT", offsetX, offsetY)
    elseif (position == "top") then
        local offset = backdrop.edgeFile == "Interface\\Tooltips\\UI-Tooltip-Border" and 4 or backdrop.edgeSize
        if (not offsetX or offsetX == 0) then offsetX = offset end
        if (not offsetY or offsetY == 0) then offsetY = offset end
        GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", offsetX, -4)
        GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -offsetX, -4)
        GameTooltip.style:SetPoint("TOPLEFT", GameTooltipStatusBar, "TOPLEFT", -offsetX, offsetY)
        GameTooltip.style:SetPoint("BOTTOMRIGHT")
    else
        local offset = backdrop.edgeFile == "Interface\\Tooltips\\UI-Tooltip-Border" and 2 or 0
        GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", offset, -1)
        GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -offset, -1)
        GameTooltip.style:SetAllPoints()
    end
end)

LibEvent:attachTrigger("tooltip.style.init", function(self, tip)
    if (not tip or tip.style) then return end
    local backdrop = {
        bgFile   = "Interface\\RaidFrame\\UI-RaidFrame-GroupBg",
        insets   = {left = 3, right = 3, top = 3, bottom = 3},
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
    }
    tip:SetBackdrop(nil)
    tip.style = CreateFrame("Frame", nil, tip)
    tip.style:SetFrameLevel(tip:GetFrameLevel())
    tip.style:SetAllPoints()
    tip.style:SetBackdrop(backdrop)
    tip.style:SetBackdropColor(0, 0, 0, 0.9)
    tip.style:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    tip.style.inside = CreateFrame("Frame", nil, tip.style)
    tip.style.inside:SetBackdrop({edgeSize=1,edgeFile="Interface\\Buttons\\WHITE8X8"})
    tip.style.inside:SetPoint("TOPLEFT", tip.style, "TOPLEFT", 1, -1)
    tip.style.inside:SetPoint("BOTTOMRIGHT", tip.style, "BOTTOMRIGHT", -1, 1)
    tip.style.inside:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.8)
    tip.style.inside:Hide()
    tip.style.outside = CreateFrame("Frame", nil, tip.style)
    tip.style.outside:SetBackdrop({edgeSize=1,edgeFile="Interface\\Buttons\\WHITE8X8"})
    tip.style.outside:SetPoint("TOPLEFT", tip.style, "TOPLEFT", -1, 1)
    tip.style.outside:SetPoint("BOTTOMRIGHT", tip.style, "BOTTOMRIGHT", 1, -1)
    tip.style.outside:SetBackdropBorderColor(0, 0, 0, 0.5)
    tip.style.outside:Hide()
    tip.style.mask = tip.style:CreateTexture(nil, "OVERLAY")
    tip.style.mask:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    tip.style.mask:SetPoint("TOPLEFT", 3, -3)
    tip.style.mask:SetPoint("BOTTOMRIGHT", tip.style, "TOPRIGHT", -3, -32)
    tip.style.mask:SetBlendMode("ADD")
    tip.style.mask:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.9, 0.9, 0.9, 0.4)
    tip.style.mask:Hide()
    tip:HookScript("OnShow", function(self) LibEvent:trigger("tooltip:show", self) end)
    tip:HookScript("OnHide", function(self) LibEvent:trigger("tooltip:hide", self) end)
    if (tip:HasScript("OnTooltipSetUnit")) then
        tip:HookScript("OnTooltipSetUnit", function(self)
            local unit = select(2, self:GetUnit())
            if (not unit) then return end
            LibEvent:trigger("tooltip:unit", self, unit)
        end)
    end
    if (tip:HasScript("OnTooltipSetItem")) then
        tip:HookScript("OnTooltipSetItem", function(self)
            local link = select(2, self:GetItem())
            if (not link) then return end
            LibEvent:trigger("tooltip:item", self, link)
        end)
    end
    if (tip:HasScript("OnTooltipSetSpell")) then
        tip:HookScript("OnTooltipSetSpell", function(self) LibEvent:trigger("tooltip:spell", self) end)
    end
    if (tip:HasScript("OnTooltipCleared")) then
        tip:HookScript("OnTooltipCleared", function(self) LibEvent:trigger("tooltip:cleared", self) end)
    end
    if (tip:HasScript("OnTooltipSetQuest")) then
        tip:HookScript("OnTooltipSetQuest", function(self) LibEvent:trigger("tooltip:quest", self) end)
    end
    if (tip == GameTooltip) then
        tip.GetBackdrop = function(self) return self.style:GetBackdrop() end
        tip.GetBackdropColor = function(self) return self.style:GetBackdropColor() end
        tip.GetBackdropBorderColor = function(self) return self.style:GetBackdropBorderColor() end
        if (not tip.BigFactionIcon) then
            tip.BigFactionIcon = tip:CreateTexture(nil, "OVERLAY")
            tip.BigFactionIcon:SetPoint("TOPRIGHT", tip, "TOPRIGHT", 18, 0)
            tip.BigFactionIcon:SetBlendMode("ADD")
            tip.BigFactionIcon:SetScale(0.25)
            tip.BigFactionIcon:SetAlpha(0.40)
        end
    end
    if (tip.DisableDrawLayer) then
        tip:DisableDrawLayer("BACKGROUND")
    end
    LibEvent:trigger("tooltip:init", tip)
    for _, v in pairs(addon.tooltips) do
        if (tip == v) then return end
    end
    addon.tooltips[#addon.tooltips+1] = tip
end)

LibEvent:attachTrigger("TINYTOOLTIP_GENERAL_INIT", function(self)
    LibEvent:trigger("tooltip.style.font.header", GameTooltip, addon.db.general.headerFont, addon.db.general.headerFontSize, addon.db.general.headerFontFlag)
    LibEvent:trigger("tooltip.style.font.body", GameTooltip, addon.db.general.bodyFont, addon.db.general.bodyFontSize, addon.db.general.bodyFontFlag)
    LibEvent:trigger("tooltip.statusbar.height", addon.db.general.statusbarHeight)
    LibEvent:trigger("tooltip.statusbar.text", addon.db.general.statusbarText)
    LibEvent:trigger("tooltip.statusbar.font", addon.db.general.statusbarFont, addon.db.general.statusbarFontSize, addon.db.general.statusbarFontFlag)
    LibEvent:trigger("tooltip.statusbar.texture", addon.db.general.statusbarTexture)
    for _, tip in pairs(addon.tooltips) do
        LibEvent:trigger("tooltip.style.init", tip)
        LibEvent:trigger("tooltip.scale", tip, addon.db.general.scale)
        LibEvent:trigger("tooltip.style.mask", tip, addon.db.general.mask)
        LibEvent:trigger("tooltip.style.bgfile", tip, addon.db.general.bgfile)
        LibEvent:trigger("tooltip.style.border.corner", tip, addon.db.general.borderCorner)
        LibEvent:trigger("tooltip.style.border.size", tip, addon.db.general.borderSize)
        LibEvent:trigger("tooltip.style.border.color", tip, unpack(addon.db.general.borderColor))
        LibEvent:trigger("tooltip.style.background", tip, unpack(addon.db.general.background))
    end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
    LibEvent:trigger("tooltip:anchor", self, parent)
end)

-- tooltip:init
-- tooltip:anchor
-- tooltip:show
-- tooltip:hide
-- tooltip:unit
-- tooltip:item
-- tooltip:spell
-- tooltip:quest
-- tooltip:cleared
