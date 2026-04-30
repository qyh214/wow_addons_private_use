local addonName, DF = ...

-- ============================================================
-- DANDERSFRAMES SEARCH SYSTEM
-- Provides searchable settings with inline editable results
-- ============================================================

local Search = {}
DF.Search = Search

-- ============================================================
-- UI CONSTANTS (match GUI styling)
-- ============================================================
local C_BACKGROUND = {r = 0.11, g = 0.11, b = 0.11, a = 0.98}
local C_PANEL      = {r = 0.16, g = 0.16, b = 0.16, a = 1}
local C_BORDER     = {r = 0, g = 0, b = 0, a = 1}
local C_ACCENT     = {r = 0.2, g = 0.6, b = 1.0, a = 1}
local C_RAID       = {r = 1.0, g = 0.4, b = 0.2, a = 1}
local C_HOVER      = {r = 0.25, g = 0.25, b = 0.25, a = 1}

local function GetThemeColor()
    if DF.GUI and DF.GUI.SelectedMode == "raid" then return C_RAID else return C_ACCENT end
end

local function CreateBackdrop(frame, bgAlpha)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    local a = bgAlpha or C_BACKGROUND.a
    frame:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, a)
    frame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, C_BORDER.a)
end

-- ============================================================
-- SEARCH REGISTRY
-- ============================================================
Search.Registry = {}
Search.CurrentTab = nil
Search.CurrentSection = nil
Search.RegistryBuilt = false

-- ============================================================
-- CONTEXT TRACKING
-- ============================================================
function Search:SetCurrentTab(tabName, tabLabel)
    self.CurrentTab = tabName
    self.CurrentTabLabel = tabLabel
    self.CurrentSection = nil
end

function Search:SetCurrentSection(sectionName)
    self.CurrentSection = sectionName
end

-- ============================================================
-- REGISTRATION FUNCTIONS
-- Now stores all metadata needed to recreate widgets
-- ============================================================
local registrationId = 0

function Search:Register(entry)
    if self.RegistryBuilt then
        return entry
    end
    
    -- Allow registration if we have either a string dbKey OR a searchKey for custom widgets
    local hasValidKey = (entry.dbKey and type(entry.dbKey) == "string") or 
                        (entry.searchKey and type(entry.searchKey) == "string")
    
    if not hasValidKey then
        return entry
    end
    
    -- Get current mode and check if this setting exists in that mode's defaults
    local currentMode = DF.GUI and DF.GUI.SelectedMode or "party"
    local defaults = (currentMode == "raid") and DF.RaidDefaults or DF.PartyDefaults
    
    -- If entry has a dbKey, check if it exists in the current mode's defaults
    -- Skip settings that don't exist for the current mode
    if entry.dbKey and type(entry.dbKey) == "string" and defaults then
        if defaults[entry.dbKey] == nil then
            -- This setting doesn't exist in the current mode's defaults, skip it
            return entry
        end
    end
    
    -- Specific exceptions: settings that should only appear in one mode
    -- Add dbKeys here that should be excluded from search in the opposite mode
    local partyOnlySettings = {
        -- Settings that should only appear in party mode
    }
    local raidOnlySettings = {
        -- Settings that should only appear in raid mode
        ["hideBlizzardRaidFrames"] = true,
    }
    
    if currentMode == "party" and entry.dbKey and raidOnlySettings[entry.dbKey] then
        return entry
    end
    if currentMode == "raid" and entry.dbKey and partyOnlySettings[entry.dbKey] then
        return entry
    end
    
    registrationId = registrationId + 1
    entry.id = registrationId
    entry.tab = self.CurrentTab
    entry.tabLabel = self.CurrentTabLabel
    entry.section = self.CurrentSection or "General"
    -- Store the current mode (party/raid) for filtering search results
    entry.mode = currentMode
    
    -- Auto-generate keywords from label
    if entry.label then
        entry.keywords = entry.keywords or {}
        for word in string.gmatch(entry.label:lower(), "%w+") do
            if #word > 2 then
                table.insert(entry.keywords, word)
            end
        end
    end
    
    if entry.section then
        for word in string.gmatch(entry.section:lower(), "%w+") do
            if #word > 2 then
                table.insert(entry.keywords, word)
            end
        end
    end
    
    if entry.tab then
        table.insert(entry.keywords, entry.tab:lower())
    end
    
    table.insert(self.Registry, entry)
    return entry
end

function Search:ClearRegistry()
    self.Registry = {}
    registrationId = 0
    self.RegistryBuilt = false
end

function Search:MarkRegistryBuilt()
    self.RegistryBuilt = true
end

function Search:InvalidateRegistry()
    self.RegistryBuilt = false
end

function Search:RefreshIfActive()
    -- If search results are currently shown and there's a search query, refresh the results
    if self.ResultsPanel and self.ResultsPanel:IsShown() and self.SearchBar then
        local query = self.SearchBar.editbox:GetText()
        if query and query ~= "" then
            -- Don't refresh during combat
            if not InCombatLockdown() then
                self:ShowResults(query)
            end
        end
    end
end

function Search:EnsureRegistry()
    local currentMode = DF.GUI and DF.GUI.SelectedMode or "party"
    -- Rebuild registry if it wasn't built yet, is empty, or was built for a different mode
    if not self.RegistryBuilt or #self.Registry == 0 or self.BuiltForMode ~= currentMode then
        self:BuildFullRegistry()
    end
end

function Search:BuildFullRegistry()
    self.Registry = {}
    registrationId = 0
    
    if not DF.GUI or not DF.GUI.Pages then 
        return 
    end
    
    local originalTab = DF.GUI.CurrentPageName
    
    -- Store the mode we're building for
    self.BuiltForMode = DF.GUI.SelectedMode
    
    for tabName, page in pairs(DF.GUI.Pages) do
        self:SetCurrentTab(tabName, page.tabLabel or tabName)
        self.CurrentSection = nil
        
        local wasShown = page:IsShown()
        
        if page.Refresh then
            page:Refresh()
        end
        
        if not wasShown then
            page:Hide()
        end
    end
    
    if originalTab and DF.GUI.Pages[originalTab] then
        DF.GUI.Pages[originalTab]:Show()
        if DF.GUI.Pages[originalTab].RefreshStates then
            DF.GUI.Pages[originalTab]:RefreshStates()
        end
    end
    
    self.RegistryBuilt = true
end

-- ============================================================
-- KEYWORD ALIASES
-- ============================================================
Search.KeywordAliases = {
    -- Transparency related
    ["transparency"] = {"alpha", "opacity", "fade"},
    ["alpha"] = {"transparency", "opacity", "fade"},
    ["opacity"] = {"alpha", "transparency", "fade"},
    ["fade"] = {"alpha", "transparency", "opacity"},
    
    -- Size related
    ["size"] = {"width", "height", "scale", "thickness"},
    ["big"] = {"scale", "size", "large"},
    ["small"] = {"scale", "size"},
    
    -- Position related
    ["position"] = {"anchor", "offset", "location"},
    ["move"] = {"position", "anchor", "offset"},
    ["location"] = {"position", "anchor"},
    
    -- Color related
    ["color"] = {"colour", "rgb", "tint"},
    ["colour"] = {"color", "rgb", "tint"},
    
    -- Text related
    ["text"] = {"font", "label"},
    ["font"] = {"text", "typeface"},
    
    -- Visibility related
    ["hide"] = {"show", "visible", "hidden", "display"},
    ["show"] = {"hide", "visible", "display"},
    ["visible"] = {"hide", "show", "hidden"},
    
    -- Bar related
    ["bar"] = {"health", "resource", "power", "absorb"},
    ["health"] = {"hp", "life"},
    
    -- Icon related (NOTE: buff and debuff are NOT aliases of each other)
    ["icon"] = {"aura", "role", "leader"},
    ["aura"] = {"icon"},
    
    -- Frame related
    ["frame"] = {"unit", "party", "raid", "layout"},
    ["unit"] = {"frame", "player", "target"},
    
    -- Group label related
    ["label"] = {"group", "text", "number"},
    ["group"] = {"raid", "label"},
}

-- ============================================================
-- WORD STEMMING
-- Strips common suffixes so "buff" matches "buffs" equally
-- ============================================================
function Search:StemWord(word)
    if not word or #word < 3 then return word end
    
    word = word:lower()
    
    -- Remove common plural/verb suffixes
    -- Order matters - check longer suffixes first
    if word:sub(-3) == "ies" and #word > 4 then
        return word:sub(1, -4) .. "y"  -- "entries" -> "entry"
    elseif word:sub(-2) == "es" and #word > 3 then
        local stem = word:sub(1, -3)
        -- Handle cases like "boxes" -> "box", "classes" -> "class"
        if word:sub(-3, -3):match("[sxz]") or word:sub(-4, -3) == "ch" or word:sub(-4, -3) == "sh" then
            return stem
        end
        return word:sub(1, -2)  -- Just remove 's' for other cases
    elseif word:sub(-1) == "s" and #word > 3 and not word:sub(-2, -2):match("[su]") then
        return word:sub(1, -2)  -- "buffs" -> "buff", but not "class" -> "clas"
    elseif word:sub(-3) == "ing" and #word > 5 then
        return word:sub(1, -4)  -- "scaling" -> "scal"
    elseif word:sub(-2) == "ed" and #word > 4 then
        return word:sub(1, -3)  -- "enabled" -> "enabl"
    end
    
    return word
end

-- Check if two words match (considering stemming)
function Search:WordsMatch(word1, word2)
    if not word1 or not word2 then return false end
    
    word1 = word1:lower()
    word2 = word2:lower()
    
    -- Direct match
    if word1 == word2 then return true end
    
    -- Stemmed match
    local stem1 = self:StemWord(word1)
    local stem2 = self:StemWord(word2)
    
    if stem1 == stem2 then return true end
    
    -- One contains the other's stem (for partial matching)
    if stem1:find(stem2, 1, true) or stem2:find(stem1, 1, true) then
        return true
    end
    
    return false
end

-- Check if a word appears in text (with stemming support)
-- Returns: found (bool), isWholeWord (bool), isPartOfAnotherWord (bool)
function Search:WordInText(word, text)
    if not word or not text then return false, false, false end
    
    word = word:lower()
    text = text:lower()
    local stemmedWord = self:StemWord(word)
    
    -- First, check each word in the text individually
    for textWord in text:gmatch("%w+") do
        local stemmedTextWord = self:StemWord(textWord)
        
        -- Exact match or stemmed match of a whole word
        if textWord == word or stemmedTextWord == stemmedWord then
            return true, true, false
        end
        
        -- Check if search word is contained WITHIN this text word (e.g., "buff" in "debuff")
        -- This is a partial match and should be penalized
        if #textWord > #word and textWord:find(word, 1, true) then
            -- It's a substring of a larger word - this is NOT a good match
            -- "buff" found in "debuff" should return found=true, isWholeWord=false, isPartOfAnotherWord=true
            return true, false, true
        end
    end
    
    return false, false, false
end

-- ============================================================
-- SEARCH FUNCTION
-- Improved scoring: exact matches >> partial matches >> aliases
-- Now with stemming support
-- ============================================================
function Search:Find(query)
    if not query or query == "" then return {} end
    
    self:EnsureRegistry()
    
    query = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if #query < 2 then return {} end
    
    local results = {}
    local queryWords = {}
    local queryWordsStemmed = {}
    local numQueryWords = 0
    
    -- Split query into individual words and their stems
    for word in string.gmatch(query, "%w+") do
        table.insert(queryWords, word)
        table.insert(queryWordsStemmed, self:StemWord(word))
        numQueryWords = numQueryWords + 1
    end
    
    -- Build expanded query with aliases (but track which are exact vs aliases)
    local exactWords = {}      -- Words the user actually typed (and stems)
    local aliasWords = {}      -- Words added via aliases (lower priority)
    
    for i, word in ipairs(queryWords) do
        exactWords[word] = true
        exactWords[queryWordsStemmed[i]] = true  -- Also add stemmed version
        
        if self.KeywordAliases[word] then
            for _, alias in ipairs(self.KeywordAliases[word]) do
                if not exactWords[alias] then
                    aliasWords[alias] = true
                end
            end
        end
        -- Check aliases for stemmed word too
        if self.KeywordAliases[queryWordsStemmed[i]] then
            for _, alias in ipairs(self.KeywordAliases[queryWordsStemmed[i]]) do
                if not exactWords[alias] then
                    aliasWords[alias] = true
                end
            end
        end
    end
    
    for _, entry in ipairs(self.Registry) do
        -- All entries in registry are for the current mode (registry is rebuilt when mode changes)
        local score = 0
        local exactWordsMatched = 0
        
        local labelLower = entry.label and entry.label:lower() or ""
        local sectionLower = entry.section and entry.section:lower() or ""
        local dbKeyLower = (entry.dbKey and type(entry.dbKey) == "string") and entry.dbKey:lower() or ""
        
        -- ===========================================
        -- HIGHEST PRIORITY: Full query match in label
        -- "buff scale" found exactly in "Buff Scale" = huge bonus
        -- ===========================================
        if labelLower:find(query, 1, true) then
            score = score + 1000
            exactWordsMatched = numQueryWords
        else
            -- ===========================================
            -- Check each query word against the label
            -- ===========================================
            for i, word in ipairs(queryWords) do
                local found, isWholeWord, isPartOfAnotherWord = self:WordInText(word, labelLower)
                
                if found then
                    if isPartOfAnotherWord then
                        -- "buff" found inside "debuff" - very low score, almost a non-match
                        score = score + 5
                    elseif isWholeWord or #word >= 4 then
                        score = score + 200
                        exactWordsMatched = exactWordsMatched + 1
                    else
                        score = score + 100
                        exactWordsMatched = exactWordsMatched + 1
                    end
                end
            end
            
            -- ===========================================
            -- Lower priority: Alias word matches in label
            -- ===========================================
            for word in pairs(aliasWords) do
                local found, isWholeWord, isPartOfAnotherWord = self:WordInText(word, labelLower)
                if found and not isPartOfAnotherWord then
                    score = score + 30
                end
            end
        end
        
        -- ===========================================
        -- BONUS: Multiple query words matched = more relevant
        -- ===========================================
        if numQueryWords > 1 and exactWordsMatched >= numQueryWords then
            score = score + 500
        elseif numQueryWords > 1 and exactWordsMatched > 1 then
            score = score + (exactWordsMatched * 100)
        end
        
        -- ===========================================
        -- MEDIUM PRIORITY: Section name matches
        -- ===========================================
        for _, word in ipairs(queryWords) do
            local found, isWholeWord, isPartOfAnotherWord = self:WordInText(word, sectionLower)
            if found and not isPartOfAnotherWord then
                score = score + 50
            elseif found and isPartOfAnotherWord then
                score = score + 5  -- Minimal score for partial match
            end
        end
        
        -- ===========================================
        -- LOWER PRIORITY: Keyword matches
        -- ===========================================
        if entry.keywords then
            for _, keyword in ipairs(entry.keywords) do
                for _, word in ipairs(queryWords) do
                    if self:WordsMatch(keyword, word) then
                        score = score + 40
                    elseif keyword:find(word, 1, true) and #keyword > #word then
                        -- Word is substring of keyword - low score
                        score = score + 5
                    end
                end
                for alias in pairs(aliasWords) do
                    if self:WordsMatch(keyword, alias) then
                        score = score + 10
                    end
                end
            end
        end
        
        -- ===========================================
        -- LOWEST PRIORITY: dbKey matches
        -- ===========================================
        if dbKeyLower ~= "" then
            for _, word in ipairs(queryWords) do
                if dbKeyLower:find(word, 1, true) then
                    score = score + 25
                end
            end
        end
        
        if score > 0 then
            table.insert(results, {entry = entry, score = score})
        end
    end
    
    table.sort(results, function(a, b) return a.score > b.score end)
    
    local finalResults = {}
    for _, result in ipairs(results) do
        table.insert(finalResults, result.entry)
    end
    
    return finalResults
end

-- ============================================================
-- INLINE WIDGET FACTORIES
-- Create actual editable widgets in search results
-- ============================================================

function Search:CreateInlineCheckbox(parent, entry)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(340, 30)
    
    -- Check if this is a custom checkbox (no dbKey, uses custom get/set)
    if entry.isCustom or not entry.dbKey then
        -- For custom checkboxes, just show the label with a note to use the settings page
        local text = container:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
        text:SetPoint("LEFT", 0, 0)
        text:SetText(entry.label)
        text:SetTextColor(0.8, 0.8, 0.8)
        
        local note = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        note:SetPoint("LEFT", text, "RIGHT", 10, 0)
        note:SetText("|cff888888(click header to edit)|r")
        
        return container
    end
    
    local db = DF.db[DF.GUI.SelectedMode]
    local dbKey = entry.dbKey
    
    local cb = CreateFrame("CheckButton", nil, container)
    cb:SetSize(20, 20)
    cb:SetPoint("LEFT", 0, 0)
    CreateBackdrop(cb)
    cb:SetBackdropColor(0, 0, 0, 0.5)
    
    cb.Check = cb:CreateTexture(nil, "OVERLAY")
    cb.Check:SetTexture("Interface\\Buttons\\WHITE8x8")
    local c = GetThemeColor()
    cb.Check:SetVertexColor(c.r, c.g, c.b)
    cb.Check:SetPoint("CENTER")
    cb.Check:SetSize(12, 12)
    cb:SetCheckedTexture(cb.Check)
    
    local text = container:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    text:SetText(entry.label)
    
    cb:SetChecked(db[dbKey] or false)
    
    cb:SetScript("OnClick", function(self)
        db[dbKey] = self:GetChecked()
        DF:UpdateAll()
    end)
    
    return container
end

function Search:CreateInlineSlider(parent, entry)
    local db = DF.db[DF.GUI.SelectedMode]
    local dbKey = entry.dbKey
    local minVal = entry.minVal or 0
    local maxVal = entry.maxVal or 100
    local step = entry.step or 1
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(340, 50)
    
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(entry.label)
    
    local slider = CreateFrame("Slider", nil, container, "BackdropTemplate")
    slider:SetPoint("TOPLEFT", 0, -18)
    slider:SetSize(250, 6)
    CreateBackdrop(slider)
    slider:SetBackdropColor(0, 0, 0, 0.8)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(8, 14)
    local c = GetThemeColor()
    thumb:SetColorTexture(c.r, c.g, c.b, 1)
    slider:SetThumbTexture(thumb)
    
    local input = CreateFrame("EditBox", nil, container)
    input:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    input:SetSize(45, 20)
    CreateBackdrop(input)
    input:SetBackdropColor(0, 0, 0, 0.5)
    input:SetFontObject(DFFontHighlightSmall)
    input:SetJustifyH("CENTER")
    input:SetAutoFocus(false)
    input:SetTextInsets(2, 2, 0, 0)
    
    local currentVal = db[dbKey] or minVal
    slider:SetValue(currentVal)
    if step < 1 then
        input:SetText(string.format("%.2f", currentVal))
    else
        input:SetText(string.format("%d", currentVal))
    end
    
    local suppressCallback = false
    
    -- Track drag state - no lightweight function for search sliders
    local isDragging = false
    slider:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDragging = true
            DF:OnSliderDragStart(nil)
        end
    end)
    slider:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and isDragging then
            isDragging = false
            DF:OnSliderDragStop()
        end
    end)
    
    slider:SetScript("OnValueChanged", function(self, value)
        if suppressCallback then return end
        if step >= 1 then value = math.floor(value + 0.5) end
        db[dbKey] = value
        if not input:HasFocus() then
            if step < 1 then
                input:SetText(string.format("%.2f", value))
            else
                input:SetText(string.format("%d", value))
            end
        end
        DF:ThrottledUpdateAll()
    end)
    
    input:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            if val < minVal then val = minVal end
            if val > maxVal then val = maxVal end
            db[dbKey] = val
            suppressCallback = true
            slider:SetValue(val)
            suppressCallback = false
        end
        self:ClearFocus()
        DF:UpdateAll()
    end)
    
    input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    
    return container
end

function Search:CreateInlineColorPicker(parent, entry)
    local db = DF.db[DF.GUI.SelectedMode]
    local dbKey = entry.dbKey
    local hasAlpha = entry.hasAlpha
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(340, 30)
    
    local btn = CreateFrame("Button", nil, container)
    btn:SetSize(200, 24)
    btn:SetPoint("LEFT", 0, 0)
    CreateBackdrop(btn)
    btn:SetBackdropColor(0, 0, 0, 0.3)
    
    local swatch = btn:CreateTexture(nil, "OVERLAY")
    swatch:SetSize(20, 16)
    swatch:SetPoint("RIGHT", -4, 0)
    
    local txt = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    txt:SetPoint("LEFT", 5, 0)
    txt:SetText(entry.label)
    
    local function UpdateSwatch()
        if db[dbKey] then
            local c = db[dbKey]
            swatch:SetColorTexture(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
        else
            swatch:SetColorTexture(1, 1, 1, 1)
        end
    end
    UpdateSwatch()
    
    btn:SetScript("OnClick", function()
        local c = db[dbKey] or {r=1, g=1, b=1, a=1}
        
        local info = {
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = hasAlpha and ColorPickerFrame:GetColorAlpha() or (c.a or 1)
                db[dbKey] = {r = r, g = g, b = b, a = a}
                UpdateSwatch()
                DF:UpdateAll()
            end,
            hasOpacity = hasAlpha,
            opacityFunc = function()
                local a = ColorPickerFrame:GetColorAlpha()
                if a and db[dbKey] then
                    db[dbKey].a = a
                    UpdateSwatch()
                    DF:UpdateAll()
                end
            end,
            cancelFunc = function(restore)
                if restore then
                    db[dbKey] = {r = restore.r, g = restore.g, b = restore.b, a = restore.a or restore.opacity or 1}
                    UpdateSwatch()
                    DF:UpdateAll()
                end
            end,
            r = c.r or 1, g = c.g or 1, b = c.b or 1, opacity = c.a or 1,
        }
        
        -- Mark this as a DandersFrames color picker call
        if DF.GUI and DF.GUI.MarkColorPickerCall then
            DF.GUI:MarkColorPickerCall()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0.3)
    end)
    
    return container
end

function Search:CreateInlineDropdown(parent, entry)
    local db = DF.db[DF.GUI.SelectedMode]
    local dbKey = entry.dbKey
    local values = entry.values or {}
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(340, 55)
    
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(entry.label)
    
    local btn = CreateFrame("Button", nil, container)
    btn:SetPoint("TOPLEFT", 0, -15)
    btn:SetSize(200, 24)
    CreateBackdrop(btn)
    btn:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnText:SetPoint("LEFT", 8, 0)
    btnText:SetText(values[db[dbKey]] or "Select...")
    
    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    arrow:SetVertexColor(0.7, 0.7, 0.7)
    
    local list = CreateFrame("Frame", nil, btn)
    list:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    list:SetWidth(200)
    CreateBackdrop(list)
    list:SetBackdropColor(0.1, 0.1, 0.1, 1)
    list:Hide()
    list:SetFrameStrata("TOOLTIP")
    
    local function Select(key, display)
        db[dbKey] = key
        btnText:SetText(display)
        list:Hide()
        DF:UpdateAll()
    end
    
    local keys = {}
    for k, v in pairs(values) do
        -- Skip _order key and any non-string values (like tables)
        if k ~= "_order" and type(v) == "string" then
            table.insert(keys, k)
        end
    end
    table.sort(keys, function(a, b)
        return (values[a] or "") < (values[b] or "")
    end)
    
    local yOff, count = -4, 0
    for _, k in ipairs(keys) do
        local v = values[k]
        local opt = CreateFrame("Button", nil, list)
        opt:SetHeight(20)
        opt:SetPoint("TOPLEFT", 4, yOff)
        opt:SetPoint("TOPRIGHT", -4, yOff)
        
        local t = opt:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        t:SetPoint("LEFT", 4, 0)
        t:SetText(v)
        
        opt:SetScript("OnEnter", function()
            t:SetTextColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b)
        end)
        opt:SetScript("OnLeave", function()
            t:SetTextColor(1, 1, 1)
        end)
        opt:SetScript("OnClick", function()
            Select(k, v)
        end)
        
        yOff = yOff - 20
        count = count + 1
    end
    list:SetHeight((count * 20) + 8)
    
    btn:SetScript("OnClick", function()
        if list:IsShown() then
            list:Hide()
        else
            list:Show()
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.1, 0.1, 0.1, 1)
    end)
    
    return container
end

-- ============================================================
-- CREATE RESULT WIDGET WITH INLINE EDITOR
-- ============================================================
function Search:CreateResultWidget(parent, entry, index)
    local widget = CreateFrame("Frame", nil, parent)
    widget:SetSize(parent:GetWidth() - 20, 75)
    
    CreateBackdrop(widget)
    widget:SetBackdropColor(0.14, 0.14, 0.14, 1)
    widget:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    
    -- Clickable Breadcrumb (Tab > Section)
    local tabDisplay = entry.tabLabel or entry.tab or "Unknown"
    local sectionDisplay = entry.section or ""
    
    -- Create breadcrumb as a styled clickable button
    local breadcrumb = CreateFrame("Button", nil, widget)
    breadcrumb:SetPoint("TOPLEFT", 8, -5)
    breadcrumb:SetHeight(18)
    
    -- Add button background
    CreateBackdrop(breadcrumb)
    breadcrumb:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    breadcrumb:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
    
    local breadcrumbText = breadcrumb:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    breadcrumbText:SetPoint("LEFT", 8, 0)
    
    local fullPath = tabDisplay .. (sectionDisplay ~= "" and ("  >  " .. sectionDisplay) or "")
    breadcrumbText:SetText(fullPath)
    breadcrumbText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Size the button to fit the text with padding
    local textWidth = breadcrumbText:GetStringWidth()
    breadcrumb:SetWidth(textWidth + 24)
    
    -- Hover effect - highlight the whole button
    breadcrumb:SetScript("OnEnter", function(self)
        local c = GetThemeColor()
        self:SetBackdropColor(c.r * 0.4, c.g * 0.4, c.b * 0.4, 0.9)
        self:SetBackdropBorderColor(c.r, c.g, c.b, 1)
        breadcrumbText:SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Go to " .. tabDisplay, 1, 1, 1)
        GameTooltip:Show()
    end)
    
    breadcrumb:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        self:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
        breadcrumbText:SetTextColor(0.7, 0.7, 0.7)
        GameTooltip:Hide()
    end)
    
    -- Click to navigate
    breadcrumb:SetScript("OnClick", function()
        Search:NavigateToTab(entry.tab, entry.section)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    -- Create the actual editable widget based on type
    local inlineWidget
    local widgetHeight = 30
    
    if entry.widgetType == "checkbox" then
        inlineWidget = self:CreateInlineCheckbox(widget, entry)
        widgetHeight = 30
    elseif entry.widgetType == "slider" then
        inlineWidget = self:CreateInlineSlider(widget, entry)
        widgetHeight = 50
    elseif entry.widgetType == "colorpicker" then
        inlineWidget = self:CreateInlineColorPicker(widget, entry)
        widgetHeight = 30
    elseif entry.widgetType == "dropdown" then
        inlineWidget = self:CreateInlineDropdown(widget, entry)
        widgetHeight = 55
    end
    
    if inlineWidget then
        inlineWidget:SetPoint("TOPLEFT", 10, -28)
    end
    
    -- Adjust widget height based on content
    widget:SetHeight(widgetHeight + 38)
    
    widget.entry = entry
    widget.calculatedHeight = widgetHeight + 38
    return widget
end

-- ============================================================
-- NAVIGATION
-- ============================================================
function Search:NavigateToTab(tabName, sectionName)
    if not tabName then return end
    
    -- Clear search
    if self.SearchBar and self.SearchBar.editbox then
        self.SearchBar.editbox:SetText("")
        self.SearchBar.editbox:ClearFocus()
    end
    self:HideResults()
    
    -- Switch to the correct tab
    if DF.GUI and DF.GUI.Tabs and DF.GUI.Tabs[tabName] then
        DF.GUI.Tabs[tabName]:Click()
        
        -- If we have a section, try to scroll to it after a short delay
        if sectionName and sectionName ~= "" then
            C_Timer.After(0.1, function()
                self:ScrollToSection(tabName, sectionName)
            end)
        end
    end
end

function Search:ScrollToSection(tabName, sectionName)
    if not DF.GUI or not DF.GUI.Pages then return end
    
    local page = DF.GUI.Pages[tabName]
    if not page or not page.children then return end
    
    -- Find the header matching the section name
    for _, widget in ipairs(page.children) do
        -- Check if this is a header with matching text
        if widget.GetText and widget:GetText() == sectionName then
            -- Try to scroll to this widget
            local widgetTop = widget:GetTop()
            local pageTop = page:GetTop()
            
            if widgetTop and pageTop then
                local offset = pageTop - widgetTop - 20
                if offset > 0 and page.SetVerticalScroll then
                    local maxScroll = page.child:GetHeight() - page:GetHeight()
                    page:SetVerticalScroll(math.min(offset, math.max(0, maxScroll)))
                end
            end
            break
        end
    end
end

-- ============================================================
-- SEARCH BAR
-- ============================================================
function Search:CreateSearchBar(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(150, 28)
    
    CreateBackdrop(frame)
    frame:SetBackdropColor(0, 0, 0, 0.7)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("LEFT", 6, 0)
    icon:SetSize(12, 12)
    icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\search")
    icon:SetVertexColor(0.6, 0.6, 0.6)
    
    local editbox = CreateFrame("EditBox", nil, frame)
    editbox:SetPoint("LEFT", 22, 0)
    editbox:SetPoint("RIGHT", -24, 0)
    editbox:SetHeight(20)
    editbox:SetFontObject(DFFontHighlightSmall)
    editbox:SetAutoFocus(false)
    editbox:SetTextInsets(2, 2, 0, 0)
    
    local placeholder = frame:CreateFontString(nil, "OVERLAY", "DFFontDisableSmall")
    placeholder:SetPoint("LEFT", 24, 0)
    placeholder:SetText("Search...")
    placeholder:SetTextColor(0.5, 0.5, 0.5)
    
    local clearBtn = CreateFrame("Button", nil, frame)
    clearBtn:SetSize(16, 16)
    clearBtn:SetPoint("RIGHT", -4, 0)
    local clearIcon = clearBtn:CreateTexture(nil, "OVERLAY")
    clearIcon:SetAllPoints()
    clearIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    clearIcon:SetVertexColor(0.5, 0.5, 0.5)
    clearBtn:SetScript("OnEnter", function() clearIcon:SetVertexColor(1, 0.3, 0.3) end)
    clearBtn:SetScript("OnLeave", function() clearIcon:SetVertexColor(0.5, 0.5, 0.5) end)
    clearBtn:Hide()
    
    editbox:SetScript("OnEditFocusGained", function()
        frame:SetBackdropBorderColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b, 1)
        placeholder:Hide()
    end)
    
    editbox:SetScript("OnEditFocusLost", function()
        frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        if editbox:GetText() == "" then
            placeholder:Show()
        end
    end)
    
    editbox:SetScript("OnTextChanged", function(self, userInput)
        local text = self:GetText()
        if text and text ~= "" then
            placeholder:Hide()
            clearBtn:Show()
            if userInput then
                -- Don't search during combat - building registry creates UI elements
                if InCombatLockdown() then
                    Search:ShowCombatMessage()
                else
                    Search:ShowResults(text)
                end
            end
        else
            if not self:HasFocus() then
                placeholder:Show()
            end
            clearBtn:Hide()
            Search:HideResults()
        end
    end)
    
    editbox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        Search:HideResults()
    end)
    
    editbox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    
    clearBtn:SetScript("OnClick", function()
        editbox:SetText("")
        editbox:ClearFocus()
        Search:HideResults()
    end)
    
    frame.editbox = editbox
    frame.placeholder = placeholder
    frame.clearBtn = clearBtn
    
    self.SearchBar = frame
    return frame
end

-- ============================================================
-- RESULTS PANEL
-- ============================================================
function Search:CreateResultsPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    
    CreateBackdrop(panel)
    panel:SetBackdropColor(0.12, 0.12, 0.12, 1)
    panel:SetBackdropBorderColor(0, 0, 0, 1)
    panel:Hide()
    
    local header = panel:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetText("Search Results")
    local c = GetThemeColor()
    header:SetTextColor(c.r, c.g, c.b)
    panel.header = header
    
    local countText = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    countText:SetPoint("LEFT", header, "RIGHT", 10, 0)
    countText:SetTextColor(0.6, 0.6, 0.6)
    panel.countText = countText
    
    local noResults = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    noResults:SetPoint("CENTER", panel, "CENTER", 0, 0)
    noResults:SetText("No settings found.\nTry different keywords.")
    noResults:SetTextColor(0.5, 0.5, 0.5)
    noResults:Hide()
    panel.noResults = noResults
    
    local scroll = CreateFrame("ScrollFrame", nil, panel, "ScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -45)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)
    DF.GUI.StyleScrollBar(scroll)

    local scrollChild = CreateFrame("Frame", nil, scroll)
    scrollChild:SetSize(scroll:GetWidth(), 1)
    scroll:SetScrollChild(scrollChild)
    
    panel.scroll = scroll
    panel.scrollChild = scrollChild
    panel.resultWidgets = {}
    
    self.ResultsPanel = panel
    return panel
end

-- ============================================================
-- SHOW/HIDE RESULTS
-- ============================================================
function Search:ShowResults(query)
    if not self.ResultsPanel then return end
    
    local results = self:Find(query)
    local panel = self.ResultsPanel
    local scrollChild = panel.scrollChild
    
    for _, widget in ipairs(panel.resultWidgets) do
        widget:Hide()
        widget:SetParent(nil)
    end
    panel.resultWidgets = {}
    
    local c = GetThemeColor()
    panel.header:SetTextColor(c.r, c.g, c.b)
    
    if #results == 0 then
        panel.noResults:Show()
        panel.countText:SetText("")
        panel.scroll:Hide()
    else
        panel.noResults:Hide()
        panel.countText:SetText("(" .. #results .. " found)")
        panel.scroll:Show()
        
        local yOffset = 0
        for i, entry in ipairs(results) do
            local widget = self:CreateResultWidget(scrollChild, entry, i)
            widget:SetPoint("TOPLEFT", 5, -yOffset)
            widget:Show()
            table.insert(panel.resultWidgets, widget)
            yOffset = yOffset + (widget.calculatedHeight or 75) + 5
        end
        
        scrollChild:SetHeight(yOffset + 20)
    end
    
    panel:Show()
    
    if DF.GUI and DF.GUI.Pages then
        for _, page in pairs(DF.GUI.Pages) do
            page:Hide()
        end
    end
end

function Search:HideResults()
    if self.ResultsPanel then
        self.ResultsPanel:Hide()
        -- Reset the no results text in case it was changed to combat message
        if self.ResultsPanel.noResults then
            self.ResultsPanel.noResults:SetText("No results found")
        end
    end
    
    if DF.GUI and DF.GUI.CurrentPageName and DF.GUI.Pages then
        local currentPage = DF.GUI.Pages[DF.GUI.CurrentPageName]
        if currentPage then
            currentPage:Show()
        end
    end
end

function Search:ShowCombatMessage()
    if not self.ResultsPanel then return end
    
    local panel = self.ResultsPanel
    
    -- Clear existing results
    for _, widget in ipairs(panel.resultWidgets) do
        widget:Hide()
        widget:SetParent(nil)
    end
    panel.resultWidgets = {}
    
    -- Show combat message instead of "No results"
    panel.noResults:SetText("Search unavailable during combat")
    panel.noResults:Show()
    panel.countText:SetText("")
    panel.scroll:Hide()
    
    -- Hide current page and show results panel
    if DF.GUI and DF.GUI.CurrentPageName and DF.GUI.Pages then
        local currentPage = DF.GUI.Pages[DF.GUI.CurrentPageName]
        if currentPage then
            currentPage:Hide()
        end
    end
    panel:Show()
end

function Search:ResetNoResultsText()
    if self.ResultsPanel and self.ResultsPanel.noResults then
        self.ResultsPanel.noResults:SetText("No results found")
    end
end

-- ============================================================
-- REGISTRATION HELPERS
-- Now store all widget metadata
-- ============================================================
function Search:RegisterCheckbox(label, dbKey, keywords, customGetSet)
    return self:Register({
        label = label,
        dbKey = dbKey,
        searchKey = customGetSet and ("custom_" .. label:gsub("%s+", "_"):lower()) or nil,
        widgetType = "checkbox",
        keywords = keywords,
        isCustom = customGetSet or false,
    })
end

function Search:RegisterSlider(label, dbKey, minVal, maxVal, step, keywords)
    return self:Register({
        label = label,
        dbKey = dbKey,
        widgetType = "slider",
        minVal = minVal,
        maxVal = maxVal,
        step = step,
        keywords = keywords,
    })
end

function Search:RegisterDropdown(label, dbKey, values, keywords)
    return self:Register({
        label = label,
        dbKey = dbKey,
        widgetType = "dropdown",
        values = values,
        keywords = keywords,
    })
end

function Search:RegisterColorPicker(label, dbKey, hasAlpha, keywords)
    return self:Register({
        label = label,
        dbKey = dbKey,
        widgetType = "colorpicker",
        hasAlpha = hasAlpha,
        keywords = keywords,
    })
end