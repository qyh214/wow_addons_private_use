-- Atlas Icon Browser for DandersFrames
-- Opens with /df atlas or /dfatlas

local atlasFrame = nil
local ICONS_PER_ROW = 12
local ICON_SIZE = 32
local ICON_PADDING = 4
local PAGE_SIZE = 120  -- 10 rows of 12

-- Validated atlas icons that are known to exist in modern WoW
local ATLAS_LIST = {
    -- Checkmarks and confirmations
    "common-icon-checkmark",
    "common-icon-checkmark-yellow",
    "common-icon-redx",
    
    -- Navigation arrows
    "common-icon-backarrow",
    "common-icon-forwardarrow",
    "common-icon-undo",
    "common-icon-redo",
    "common-icon-rotateleft",
    "common-icon-rotateright",
    
    -- Dropdown arrows
    "common-dropdown-icon-up",
    "common-dropdown-icon-down",
    
    -- Search
    "common-search-magnifyingglass",
    
    -- Zoom
    "common-icon-zoomin",
    "common-icon-zoomout",
    
    -- Bags
    "bags-icon-addslots",
    "bags-greenarrow",
    "bags-redarrow",
    "bags-newitem",
    
    -- Ping markers
    "ping_marker_star",
    "ping_marker_warning",
    "ping_marker_assist",
    "ping_marker_attack",
    "ping_marker_onmyway",
    "ping_marker_threat",
    
    -- Group finder / roles
    "groupfinder-icon-class-healer",
    "groupfinder-icon-class-tank",
    "groupfinder-icon-class-dps",
    "roleicon-tiny-tank",
    "roleicon-tiny-healer",
    "roleicon-tiny-dps",
    "UI-LFG-RoleIcon-Tank",
    "UI-LFG-RoleIcon-Healer",
    "UI-LFG-RoleIcon-DPS",
    
    -- Voice chat
    "voicechat-icon-mic",
    "voicechat-icon-mic-mute",
    "voicechat-icon-speaker",
    "voicechat-icon-speaker-mute",
    
    -- Collections
    "collections-icon-favorites",
    "Favorites-Star",
    
    -- Transmog
    "transmog-icon-hidden",
    "transmog-icon-remove",
    
    -- Professions
    "Professions-Icon-Lock",
    
    -- Edit mode
    "editmode-up",
    "editmode-down",
    
    -- Garrison
    "Garr_Building-Plus",
    
    -- Communities
    "communities-icon-addgroupplus",
    "communities-icon-searchmagnifyingglass",
    
    -- Chat
    "chatframe-button-icon-voicechat",
    
    -- Social
    "socialqueuing-icon-group",
    "socialqueuing-icon-eye",
    
    -- Calendar
    "Calendar_EventIcon_PVP01",
    "Calendar_EventIcon_Raid01",
    "Calendar_EventIcon_Dungeon01",
    
    -- Quest
    "QuestNormal",
    "QuestRepeatableTurnin",
    "QuestLegendaryTurnin",
    "QuestBonusObjective",
    "QuestDaily",
    
    -- Minimap tracking
    "Minimap_tracking_mailbox",
    "Minimap_tracking_banker",
    "Minimap_tracking_auctioneer",
    "Minimap_tracking_flightmaster",
    "Minimap_tracking_innkeeper",
    "Minimap_tracking_repair",
    "Minimap_tracking_battlemaster",
    
    -- HUD elements
    "UI-HUD-ActionBar-IconFrame-AddRow",
    "UI-HUD-ActionBar-PageDownArrow",
    "UI-HUD-ActionBar-PageUpArrow",
    
    -- Target markers (raid icons)
    "Raid-Icon-Star",
    "Raid-Icon-Circle",
    "Raid-Icon-Diamond",
    "Raid-Icon-Triangle",
    "Raid-Icon-Moon",
    "Raid-Icon-Square",
    "Raid-Icon-Cross",
    "Raid-Icon-Skull",
    
    -- Pet battle
    "petbattle-health",
    "petbattle-speed", 
    "petbattle-attack",
    
    -- Misc UI
    "GM_ChatIcon",
    "services-icon-warning",
    "services-icon-info",
    "Newplayertutorial-icon-mouse-leftbutton",
    "Newplayertutorial-icon-mouse-rightbutton",
    "NPE_ExclamationPoint",
    
    -- Coins
    "nameplates-icon-elite-gold",
    "nameplates-icon-elite-silver",
    
    -- Death
    "poi-graveyard-neutral",
    
    -- Level up
    "levelup-icon-bag",
    
    -- Auction house
    "auctionhouse-icon-bid",
    "auctionhouse-icon-buyout",
    "auctionhouse-icon-favorite",
    
    -- Close/X buttons
    "common-icon-redx",
    
    -- Difficulty icons
    "UI-HUD-Minimap-GuildBanner-Up",
    "UI-HUD-Minimap-GuildBanner-Down",
    
    -- Copy-like icons (document/page)
    "poi-workorders",
    "questlog-icon-lore",
    "QuestSharing-QuestLog-Active",
    "QuestSharing-QuestLog-ButtonIcon",
    
    -- Settings/gear
    "options-icon",
    "mechagon-projects",
    
    -- Plus/Add
    "communities-icon-addchannelplus",
    "Garr_Building-Plus",
    "communities-icon-addgroupplus",
    
    -- Minus/Remove
    "communities-icon-redx",
    
    -- Info
    "QuestTurnin",
    "QuestBang",
    
    -- Lock
    "Professions-Icon-Lock",
    "transmog-icon-locked",
    
    -- Eye/View
    "socialqueuing-icon-eye",
    "groupfinder-eye-flipbook",
    
    -- Refresh
    "UI-RefreshButton",
    
    -- Star/Favorite
    "loottoast-star-normal",
    "bags-icon-star",
    
    -- Warning/Alert
    "services-icon-warning",
    "Ping_Marker_Warning",
    
    -- Question mark
    "QuestRepeatableTurnin",
    
    -- Checkboxes
    "common-checkbox-unchecked",
    "common-checkbox-checked",
    "common-checkbox-checked-disabled",
    "common-checkbox-unchecked-disabled",
    
    -- Radio buttons  
    "common-radiobutton-unchecked",
    "common-radiobutton-checked",
}

local currentPage = 1
local totalPages = 1
local filteredList = {}
local validatedAtlases = {}
local searchText = ""

-- Validate which atlases actually exist
local function ValidateAtlases()
    validatedAtlases = {}
    for _, atlasName in ipairs(ATLAS_LIST) do
        -- Try to get atlas info - if it exists, the info won't be nil
        local info = C_Texture.GetAtlasInfo(atlasName)
        if info then
            table.insert(validatedAtlases, atlasName)
        end
    end
    
    -- Remove duplicates
    local seen = {}
    local unique = {}
    for _, atlas in ipairs(validatedAtlases) do
        if not seen[atlas] then
            seen[atlas] = true
            table.insert(unique, atlas)
        end
    end
    validatedAtlases = unique
    
    print("|cff7373f2DandersFrames:|r Found " .. #validatedAtlases .. " valid atlases")
end

local function GetFilteredList()
    if searchText == "" then
        return validatedAtlases
    end
    
    local filtered = {}
    local search = searchText:lower()
    for _, atlas in ipairs(validatedAtlases) do
        if atlas:lower():find(search, 1, true) then
            table.insert(filtered, atlas)
        end
    end
    return filtered
end

local function UpdateDisplay()
    if not atlasFrame then return end
    
    filteredList = GetFilteredList()
    totalPages = math.max(1, math.ceil(#filteredList / PAGE_SIZE))
    currentPage = math.min(currentPage, totalPages)
    
    -- Update page label
    atlasFrame.pageLabel:SetText(string.format("Page %d / %d (%d icons)", currentPage, totalPages, #filteredList))
    
    -- Hide ALL icons first and clear their textures
    for i, icon in ipairs(atlasFrame.icons) do
        icon:Hide()
        icon.texture:SetTexture(nil)
        icon.texture:SetAtlas(nil)
        icon.atlasName = nil
    end
    
    -- Show current page's icons
    local startIdx = (currentPage - 1) * PAGE_SIZE + 1
    local endIdx = math.min(startIdx + PAGE_SIZE - 1, #filteredList)
    
    local iconIdx = 0
    for i = startIdx, endIdx do
        iconIdx = iconIdx + 1
        local icon = atlasFrame.icons[iconIdx]
        local atlasName = filteredList[i]
        
        if icon and atlasName then
            icon.texture:SetAtlas(atlasName, true)
            icon.atlasName = atlasName
            icon:Show()
        end
    end
    
    -- Update button states
    atlasFrame.prevBtn:SetEnabled(currentPage > 1)
    atlasFrame.nextBtn:SetEnabled(currentPage < totalPages)
    
    if currentPage <= 1 then
        atlasFrame.prevBtn:SetAlpha(0.5)
    else
        atlasFrame.prevBtn:SetAlpha(1)
    end
    
    if currentPage >= totalPages then
        atlasFrame.nextBtn:SetAlpha(0.5)
    else
        atlasFrame.nextBtn:SetAlpha(1)
    end
end

local function CreateAtlasBrowser()
    -- Validate atlases on first open
    if #validatedAtlases == 0 then
        ValidateAtlases()
    end
    
    if atlasFrame then
        atlasFrame:Show()
        currentPage = 1
        searchText = ""
        if atlasFrame.searchBox then
            atlasFrame.searchBox:SetText("")
        end
        UpdateDisplay()
        return
    end
    
    -- Colors
    local C_BG = {r = 0.12, g = 0.12, b = 0.14}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.20}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    local C_ACCENT = {r = 0.45, g = 0.45, b = 0.95}
    local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
    
    local frameWidth = ICONS_PER_ROW * (ICON_SIZE + ICON_PADDING) + 40
    local frameHeight = 10 * (ICON_SIZE + ICON_PADDING) + 120
    
    atlasFrame = CreateFrame("Frame", "DFAtlasBrowser", UIParent, "BackdropTemplate")
    atlasFrame:SetSize(frameWidth, frameHeight)
    atlasFrame:SetPoint("CENTER")
    atlasFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    atlasFrame:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, 0.95)
    atlasFrame:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
    atlasFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    atlasFrame:SetMovable(true)
    atlasFrame:EnableMouse(true)
    atlasFrame:SetClampedToScreen(true)
    
    -- Header
    local header = CreateFrame("Frame", nil, atlasFrame)
    header:SetHeight(30)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() atlasFrame:StartMoving() end)
    header:SetScript("OnDragStop", function() atlasFrame:StopMovingOrSizing() end)
    
    local title = header:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("LEFT", 10, 0)
    title:SetText("Atlas Icon Browser")
    title:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -5, 0)
    closeBtn:SetNormalFontObject("DFFontNormalLarge")
    closeBtn:SetText("×")
    closeBtn:GetFontString():SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    closeBtn:SetScript("OnClick", function() atlasFrame:Hide() end)
    closeBtn:SetScript("OnEnter", function(self) self:GetFontString():SetTextColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function(self) self:GetFontString():SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b) end)
    
    -- Search box
    local searchFrame = CreateFrame("Frame", nil, atlasFrame, "BackdropTemplate")
    searchFrame:SetSize(200, 24)
    searchFrame:SetPoint("TOPLEFT", 10, -35)
    searchFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    searchFrame:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    searchFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local searchLabel = searchFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    searchLabel:SetPoint("LEFT", 5, 0)
    searchLabel:SetText("Search:")
    searchLabel:SetTextColor(C_TEXT.r * 0.7, C_TEXT.g * 0.7, C_TEXT.b * 0.7)
    
    local searchBox = CreateFrame("EditBox", nil, searchFrame)
    searchBox:SetSize(140, 20)
    searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 5, 0)
    searchBox:SetFontObject("DFFontNormalSmall")
    searchBox:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    searchBox:SetScript("OnTextChanged", function(self)
        searchText = self:GetText()
        currentPage = 1
        UpdateDisplay()
    end)
    atlasFrame.searchBox = searchBox
    
    -- Page label
    atlasFrame.pageLabel = atlasFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    atlasFrame.pageLabel:SetPoint("TOP", 0, -40)
    atlasFrame.pageLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Prev/Next buttons
    local function CreateNavButton(text, xOffset)
        local btn = CreateFrame("Button", nil, atlasFrame, "BackdropTemplate")
        btn:SetSize(60, 22)
        btn:SetPoint("TOPRIGHT", xOffset, -35)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        btn.text = btnText
        
        btn:SetScript("OnEnter", function(self)
            if self:IsEnabled() then
                self:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        end)
        
        return btn
    end
    
    atlasFrame.nextBtn = CreateNavButton("Next >", -10)
    atlasFrame.nextBtn:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            UpdateDisplay()
        end
    end)
    
    atlasFrame.prevBtn = CreateNavButton("< Prev", -75)
    atlasFrame.prevBtn:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            UpdateDisplay()
        end
    end)
    
    -- Icon container
    local iconContainer = CreateFrame("Frame", nil, atlasFrame)
    iconContainer:SetPoint("TOPLEFT", 15, -65)
    iconContainer:SetPoint("BOTTOMRIGHT", -15, 40)
    
    -- Create icon buttons
    atlasFrame.icons = {}
    for i = 1, PAGE_SIZE do
        local row = math.floor((i - 1) / ICONS_PER_ROW)
        local col = (i - 1) % ICONS_PER_ROW
        
        local icon = CreateFrame("Button", nil, iconContainer, "BackdropTemplate")
        icon:SetSize(ICON_SIZE, ICON_SIZE)
        icon:SetPoint("TOPLEFT", col * (ICON_SIZE + ICON_PADDING), -row * (ICON_SIZE + ICON_PADDING))
        icon:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        icon:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        icon:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        
        local tex = icon:CreateTexture(nil, "ARTWORK")
        tex:SetPoint("TOPLEFT", 2, -2)
        tex:SetPoint("BOTTOMRIGHT", -2, 2)
        icon.texture = tex
        
        icon:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
            if self.atlasName then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self.atlasName, 1, 1, 1)
                GameTooltip:AddLine("Click to copy name", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            end
        end)
        icon:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
            GameTooltip:Hide()
        end)
        icon:SetScript("OnClick", function(self)
            if self.atlasName then
                -- Show copy popup
                if not atlasFrame.copyPopup then
                    local popup = CreateFrame("Frame", nil, atlasFrame, "BackdropTemplate")
                    popup:SetSize(300, 70)
                    popup:SetPoint("CENTER")
                    popup:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                        edgeFile = "Interface\\Buttons\\WHITE8x8",
                        edgeSize = 1,
                    })
                    popup:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, 1)
                    popup:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
                    popup:SetFrameLevel(atlasFrame:GetFrameLevel() + 10)
                    
                    local label = popup:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
                    label:SetPoint("TOP", 0, -8)
                    label:SetText("Press Ctrl+C to copy:")
                    label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                    
                    local editBox = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
                    editBox:SetSize(280, 22)
                    editBox:SetPoint("TOP", label, "BOTTOM", 0, -6)
                    editBox:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                        edgeFile = "Interface\\Buttons\\WHITE8x8",
                        edgeSize = 1,
                    })
                    editBox:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                    editBox:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
                    editBox:SetFontObject("DFFontNormalSmall")
                    editBox:SetTextColor(1, 1, 1)
                    editBox:SetAutoFocus(false)
                    editBox:SetJustifyH("CENTER")
                    editBox:SetScript("OnEscapePressed", function() popup:Hide() end)
                    editBox:SetScript("OnEnterPressed", function() popup:Hide() end)
                    popup.editBox = editBox
                    
                    local closeBtn2 = CreateFrame("Button", nil, popup, "BackdropTemplate")
                    closeBtn2:SetSize(50, 18)
                    closeBtn2:SetPoint("BOTTOM", 0, 6)
                    closeBtn2:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                        edgeFile = "Interface\\Buttons\\WHITE8x8",
                        edgeSize = 1,
                    })
                    closeBtn2:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                    closeBtn2:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
                    local closeBtnText2 = closeBtn2:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
                    closeBtnText2:SetPoint("CENTER")
                    closeBtnText2:SetText("Close")
                    closeBtnText2:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                    closeBtn2:SetScript("OnClick", function() popup:Hide() end)
                    
                    popup:Hide()
                    atlasFrame.copyPopup = popup
                end
                
                atlasFrame.copyPopup.editBox:SetText(self.atlasName)
                atlasFrame.copyPopup:Show()
                atlasFrame.copyPopup.editBox:SetFocus()
                atlasFrame.copyPopup.editBox:HighlightText()
            end
        end)
        
        icon:Hide()
        atlasFrame.icons[i] = icon
    end
    
    -- Instructions
    local instructions = atlasFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    instructions:SetPoint("BOTTOM", 0, 12)
    instructions:SetText("Hover for name • Click to copy • Search to filter")
    instructions:SetTextColor(C_TEXT.r * 0.6, C_TEXT.g * 0.6, C_TEXT.b * 0.6)
    
    UpdateDisplay()
end

-- Slash command
SLASH_DFATLAS1 = "/dfatlas"
SlashCmdList["DFATLAS"] = function()
    CreateAtlasBrowser()
end

-- Also hook into /df atlas
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    C_Timer.After(2, function()
        local oldSlashHandler = SlashCmdList["DANDERSFRAMES"]
        if oldSlashHandler then
            SlashCmdList["DANDERSFRAMES"] = function(msg)
                if msg and msg:lower() == "atlas" then
                    CreateAtlasBrowser()
                else
                    oldSlashHandler(msg)
                end
            end
        end
    end)
end)

print("|cff7373f2DandersFrames:|r Atlas Browser loaded. Use |cffffffff/dfatlas|r to open.")
