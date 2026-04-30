local addonName, DF = ...

-- Expose as global for other files and external access
DandersFrames = DF

-- ============================================================
-- SHARED MEDIA SUPPORT
-- ============================================================

-- Helper function to get LibSharedMedia (fetched fresh each time to handle late-loading)
-- Cache the SharedMedia reference like MPlusTimer does
local LSM_Cached = nil
local function GetLSM()
    if not LSM_Cached then
        LSM_Cached = LibStub and LibStub("LibSharedMedia-3.0", true)
    end
    return LSM_Cached
end

-- Register our custom fonts and textures with SharedMedia
local function RegisterCustomMedia()
    local LSM = GetLSM()
    if not LSM then return end
    
    -- Register custom fonts (langmask covers all locales so fonts work on all clients)
    local ALL_LOCALES = LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW
    LSM:Register(LSM.MediaType.FONT, "DF Expressway", "Interface\\AddOns\\DandersFrames\\Fonts\\Expressway.ttf", ALL_LOCALES)
    LSM:Register(LSM.MediaType.FONT, "DF Roboto SemiBold", "Interface\\AddOns\\DandersFrames\\Fonts\\Roboto-SemiBold.ttf", ALL_LOCALES)
    LSM:Register(LSM.MediaType.FONT, "DF Roboto Bold", "Interface\\AddOns\\DandersFrames\\Fonts\\Roboto-Bold.ttf", ALL_LOCALES)
    
    -- Register custom statusbar textures
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Flat", "Interface\\Buttons\\WHITE8x8")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Gradient H", "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Gradient V", "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Gradient H Rev", "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H_Rev")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Gradient V Rev", "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V_Rev")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes Soft", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes Soft Wide", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft_Wide")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes Sparse", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Sparse")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes Medium", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Medium")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes Dense", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Stripes Very Dense", "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Very_Dense")
    
    -- Health bar textures
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Smooth", "Interface\\AddOns\\DandersFrames\\Media\\DF_Smooth")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Glossy", "Interface\\AddOns\\DandersFrames\\Media\\DF_Glossy")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Matte", "Interface\\AddOns\\DandersFrames\\Media\\DF_Matte")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Glass", "Interface\\AddOns\\DandersFrames\\Media\\DF_Glass")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Soft", "Interface\\AddOns\\DandersFrames\\Media\\DF_Soft")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Beveled", "Interface\\AddOns\\DandersFrames\\Media\\DF_Beveled")
    LSM:Register(LSM.MediaType.STATUSBAR, "DF Minimalist", "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist")
    
    -- Register callback to clear font cache when new fonts are added
    LSM:RegisterCallback("LibSharedMedia_Registered", function(_, mediaType)
        if mediaType == LSM.MediaType.FONT then
            if DF.ClearFontCache then
                DF:ClearFontCache()
            end
        end
    end)
end

-- Try to register now, and also schedule for later in case LSM loads after us
RegisterCustomMedia()

-- Also try after ADDON_LOADED in case SharedMedia addons load later
local registrationFrame = CreateFrame("Frame")
registrationFrame:RegisterEvent("ADDON_LOADED")
registrationFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    -- Try to register our media whenever any addon loads (in case it's SharedMedia)
    RegisterCustomMedia()
    -- Once LSM is available, we're done - stop listening
    local LSM = GetLSM()
    if LSM then
        self:UnregisterAllEvents()
    end
end)

-- Store reference for other modules (use getter function)
DF.GetLSM = GetLSM

-- ============================================================
-- FONTS & TEXTURES (SharedMedia integration)
-- ============================================================

-- Fallback fonts if SharedMedia not available
DF.SharedFonts = {
    ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata TT",
    ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
    ["Fonts\\skurri.ttf"] = "Skurri",
    ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
    ["Interface\\AddOns\\DandersFrames\\Fonts\\Expressway.ttf"] = "DF Expressway",
    ["Interface\\AddOns\\DandersFrames\\Fonts\\Roboto-SemiBold.ttf"] = "DF Roboto SemiBold",
    ["Interface\\AddOns\\DandersFrames\\Fonts\\Roboto-Bold.ttf"] = "DF Roboto Bold",
}

-- Fallback textures if SharedMedia not available
DF.SharedTextures = {
    ["Solid"] = "Solid (No Texture)",  -- Special option for solid color backgrounds
    ["Interface\\TargetingFrame\\UI-StatusBar"] = "Blizzard",
    ["Interface\\Buttons\\WHITE8x8"] = "Flat",
    ["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H"] = "DF Gradient H",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V"] = "DF Gradient V",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes"] = "DF Stripes",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft"] = "DF Stripes Soft",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft_Wide"] = "DF Stripes Soft Wide",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Sparse"] = "DF Stripes Sparse",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Medium"] = "DF Stripes Medium",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense"] = "DF Stripes Dense",
    ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Very_Dense"] = "DF Stripes Very Dense",
}

-- Fonts to exclude (known problematic fonts)
-- Font validation removed - show all SharedMedia fonts like MPlusTimer does

function DF:GetFontList()
    -- Returns a table of fontName -> fontName for dropdown compatibility
    -- We now store font NAMES in the database, not paths
    -- Show all fonts like MPlusTimer does - no filtering
    local list = {}
    local LSM = GetLSM()
    
    if LSM then
        -- Use SharedMedia fonts - use lowercase "font" like MPlusTimer
        local fonts = LSM:List("font")
        for _, name in ipairs(fonts) do
            list[name] = name
        end
    else
        -- Fallback to built-in font names
        for path, name in pairs(DF.SharedFonts) do
            list[name] = name
        end
    end
    
    return list
end

-- Fetch actual font path from SharedMedia by name (like MPlusTimer does)
function DF:GetFontPath(fontName)
    if not fontName then return "Fonts\\FRIZQT__.TTF" end
    
    -- If fontName looks like a path already (legacy support), return it
    if fontName:find("\\") or fontName:find("/") then
        return fontName
    end
    
    -- Use SharedMedia to get path - exactly like MPlusTimer does
    local LSM = GetLSM()
    if LSM then
        return LSM:Fetch("font", fontName)
    end
    
    -- Fallback
    return "Fonts\\FRIZQT__.TTF"
end

-- Get font display name from stored value (handles both names and legacy paths)
function DF:GetFontNameFromPath(fontValue)
    if not fontValue then return nil end
    
    local list = DF:GetFontList()
    
    -- If it's already a font name in our list, return it directly
    if list[fontValue] then
        return fontValue
    end
    
    -- Legacy path support: if it looks like a path, try to find the font name
    if fontValue:find("\\") or fontValue:find("/") then
        local LSM = GetLSM()
        if LSM then
            local fonts = LSM:List("font")
            for _, name in ipairs(fonts) do
                local registeredPath = LSM:Fetch("font", name)
                if registeredPath then
                    -- Compare paths (case-insensitive, slash-normalized)
                    local normRegistered = registeredPath:lower():gsub("/", "\\")
                    local normInput = fontValue:lower():gsub("/", "\\")
                    if normRegistered == normInput then
                        return name
                    end
                    -- Also try comparing just filenames
                    local regFilename = registeredPath:match("([^/\\]+)$")
                    local inputFilename = fontValue:match("([^/\\]+)$")
                    if regFilename and inputFilename and regFilename:lower() == inputFilename:lower() then
                        return name
                    end
                end
            end
        end
        
        -- Return filename without extension as fallback
        local filename = fontValue:match("([^/\\]+)$")
        if filename then
            return filename:gsub("%.[tT][tT][fF]$", ""):gsub("%.[oO][tT][fF]$", "")
        end
    end
    
    return fontValue
end

-- ============================================================
-- FONT FAMILY SYSTEM (Multi-alphabet support like Platynator)
-- ============================================================

-- Cache for created font families
local fontFamilies = {}

-- Clear font cache (kept for compatibility)
function DF:ClearFontCache()
    -- Clear font families when new fonts are registered
    wipe(fontFamilies)
end

-- Alphabets supported by WoW font families
local alphabets = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"}

-- Determine user's alphabet based on locale
local locale = GetLocale()
local userAlphabet = "roman"
if locale == "koKR" then
    userAlphabet = "korean"
elseif locale == "zhCN" then
    userAlphabet = "simplifiedchinese"
elseif locale == "zhTW" then
    userAlphabet = "traditionalchinese"
elseif locale == "ruRU" then
    userAlphabet = "russian"
end

-- Font alphabet support map
-- Fonts not listed here are assumed to support only "roman"
-- Blizzard fonts and fonts with full Unicode support should include all alphabets
local fontAlphabetSupport = {
    -- Blizzard fonts - only list alphabets they actually contain glyphs for.
    -- For unlisted alphabets (e.g. Korean, Chinese), GetFontFamilyMembers will
    -- fall back to the proper locale-specific font from GameFontNormal.
    ["Fonts\\FRIZQT__.TTF"] = {"roman", "russian"},
    ["Fonts\\ARIALN.TTF"] = {"roman", "russian"},
    ["Fonts\\MORPHEUS.TTF"] = {"roman"},
    ["Fonts\\SKURRI.TTF"] = {"roman"},
    
    -- Our custom fonts
    ["Interface\\AddOns\\DandersFrames\\Fonts\\Expressway.ttf"] = {"roman"},  -- Latin only
    ["Interface\\AddOns\\DandersFrames\\Fonts\\Roboto-SemiBold.ttf"] = {"roman", "russian"},  -- Latin + Cyrillic
    ["Interface\\AddOns\\DandersFrames\\Fonts\\Roboto-Bold.ttf"] = {"roman", "russian"},  -- Latin + Cyrillic
}

-- Allow registering font alphabet support (for SharedMedia fonts from other addons)
-- Usage: DF:RegisterFontAlphabetSupport("Interface\\AddOns\\MyAddon\\Fonts\\MyFont.ttf", {"roman", "russian"})
function DF:RegisterFontAlphabetSupport(fontPath, supportedAlphabets)
    if not fontPath or not supportedAlphabets then return end
    local normalizedPath = fontPath:lower():gsub("/", "\\")
    fontAlphabetSupport[normalizedPath] = supportedAlphabets
    -- Clear font cache so new families are created with updated support
    wipe(fontFamilies)
end

-- Check if a font supports a given alphabet
local function FontSupportsAlphabet(fontPath, alphabet)
    if not fontPath or not alphabet then return false end
    
    -- Normalize path for comparison (case insensitive, handle both slash types)
    local normalizedPath = fontPath:lower():gsub("/", "\\")
    
    -- Check our known fonts
    for knownPath, supportedAlphabets in pairs(fontAlphabetSupport) do
        if normalizedPath == knownPath:lower() then
            for _, supported in ipairs(supportedAlphabets) do
                if supported == alphabet then
                    return true
                end
            end
            return false
        end
    end
    
    -- Unknown fonts: assume they only support roman alphabet
    -- This is safer - better to fall back to Blizzard than show boxes
    return alphabet == "roman"
end

-- Base font size used for font families (we'll scale from this)
local BASE_FONT_SIZE = 12

-- Hidden frame used for font preloading/validation
-- Needed early because GetOrCreateFontFamily uses it
local fontValidationFrame = CreateFrame("Frame")
fontValidationFrame:Hide()
local fontValidationString = fontValidationFrame:CreateFontString(nil, "OVERLAY")

-- Preload/validate a font to ensure WoW has it loaded
local function PreloadFont(fontPath)
    if not fontPath then return end
    -- Attempt to set the font - this forces WoW to load the font file
    pcall(function()
        fontValidationString:SetFont(fontPath, 12, "")
    end)
end

-- Build font family members for CreateFontFamily
-- Uses custom font for supported alphabets, Blizzard fallbacks for others
local function GetFontFamilyMembers(customFontPath, outline)
    local members = {}
    local coreFont = GameFontNormal
    
    -- Check if GetFontObjectForAlphabet exists (WoW 11.x+)
    if not coreFont or not coreFont.GetFontObjectForAlphabet then
        return nil
    end
    
    for _, alphabet in ipairs(alphabets) do
        local forAlphabet = coreFont:GetFontObjectForAlphabet(alphabet)
        if not forAlphabet then
            return nil  -- API not fully available
        end
        local blizzFile, _, _ = forAlphabet:GetFont()
        if not blizzFile then
            return nil  -- Can't get font info
        end
        
        -- Check if custom font supports this alphabet
        if FontSupportsAlphabet(customFontPath, alphabet) then
            -- Use custom font for this alphabet
            table.insert(members, {
                alphabet = alphabet,
                file = customFontPath,
                height = BASE_FONT_SIZE,
                flags = outline,
            })
        else
            -- Use Blizzard's default font for unsupported alphabets
            table.insert(members, {
                alphabet = alphabet,
                file = blizzFile,
                height = BASE_FONT_SIZE,
                flags = outline,
            })
        end
    end
    
    return members
end

-- Create or get a cached font family (keyed by font + outline + shadow)
local fontFamilyCounter = 0
local function GetOrCreateFontFamily(fontPath, outline, useShadow)
    -- Check if CreateFontFamily API is available (WoW 11.x+)
    if not CreateFontFamily then
        return nil
    end
    
    -- Create unique key for this font configuration (include shadow state)
    local key = (fontPath or "default"):lower() .. "|" .. (outline or "") .. "|" .. (useShadow and "shadow" or "noshadow")
    
    if fontFamilies[key] then
        return fontFamilies[key]
    end
    
    -- Get font family members
    local members = GetFontFamilyMembers(fontPath, outline or "")
    if not members then
        return nil  -- API not available or failed
    end
    
    -- Preload all fonts in the family to ensure they're available
    -- This is important for fonts that haven't been used yet
    for _, member in ipairs(members) do
        if member.file and fontValidationString then
            pcall(function()
                fontValidationString:SetFont(member.file, 12, "")
            end)
        end
    end
    
    -- Generate unique global name
    fontFamilyCounter = fontFamilyCounter + 1
    local globalName = "DFFont" .. fontFamilyCounter
    
    -- Create font family with multi-alphabet support
    local success, fontFamily = pcall(CreateFontFamily, globalName, members)
    
    if success and fontFamily then
        fontFamily:SetTextColor(1, 1, 1)
        
        -- Apply shadow to all alphabet font objects if needed (like Platynator does)
        if useShadow then
            -- Get shadow settings from current db (party or raid mode)
            local db
            if DF.GetDB then
                db = DF:GetDB()
            elseif DF.db then
                local mode = (DF.GUI and DF.GUI.SelectedMode) or "party"
                db = DF.db[mode]
            end
            local shadowX = db and db.fontShadowOffsetX or 1
            local shadowY = db and db.fontShadowOffsetY or -1
            local shadowColor = db and db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
            for _, alphabet in ipairs(alphabets) do
                local fontObj = fontFamily:GetFontObjectForAlphabet(alphabet)
                if fontObj then
                    fontObj:SetShadowOffset(shadowX, shadowY)
                    fontObj:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
                end
            end
        end
        
        fontFamilies[key] = globalName
        return globalName
    end
    
    return nil
end

function DF:GetTextureList(includeSolid)
    local list = {}
    local LSM = GetLSM()
    
    -- Add Solid option for backgrounds if requested
    if includeSolid then
        list["Solid"] = "Solid (No Texture)"
    end
    
    if LSM then
        -- Use SharedMedia statusbar textures
        local textures = LSM:List(LSM.MediaType.STATUSBAR)
        for _, name in ipairs(textures) do
            local path = LSM:Fetch(LSM.MediaType.STATUSBAR, name)
            if path then
                list[path] = name
            end
        end
    else
        -- Fallback to built-in textures
        for k, v in pairs(DF.SharedTextures) do
            if k ~= "Solid" or includeSolid then  -- Only include Solid if requested
                list[k] = v
            end
        end
    end
    
    return list
end

-- Get texture display name from path (with fuzzy matching for SharedMedia compatibility)
function DF:GetTextureNameFromPath(texturePath)
    if not texturePath then return nil end
    
    -- Special case for Solid
    if texturePath == "Solid" then
        return "Solid (No Texture)"
    end
    
    -- First try direct lookup in current texture list
    local list = DF:GetTextureList()
    if list[texturePath] then
        return list[texturePath]
    end
    
    -- Try with normalized path (replace forward slashes with backslashes)
    local normalizedPath = texturePath:gsub("/", "\\")
    if list[normalizedPath] then
        return list[normalizedPath]
    end
    
    -- Try reverse - backslashes to forward slashes
    normalizedPath = texturePath:gsub("\\", "/")
    if list[normalizedPath] then
        return list[normalizedPath]
    end
    
    -- Try case-insensitive search
    local lowerPath = texturePath:lower()
    for path, name in pairs(list) do
        if path:lower() == lowerPath then
            return name
        end
    end
    
    -- Try matching without "Interface\" or "Interface/" prefix
    local strippedPath = texturePath:gsub("^[Ii]nterface[/\\]", ""):lower()
    for path, name in pairs(list) do
        local strippedListPath = path:gsub("^[Ii]nterface[/\\]", ""):lower()
        if strippedPath == strippedListPath then
            return name
        end
    end
    
    -- Last resort: Ask SharedMedia directly
    local LSM = GetLSM()
    if LSM then
        local textures = LSM:List(LSM.MediaType.STATUSBAR)
        for _, name in ipairs(textures) do
            local registeredPath = LSM:Fetch(LSM.MediaType.STATUSBAR, name)
            if registeredPath then
                local normRegistered = registeredPath:lower():gsub("/", "\\")
                local normInput = texturePath:lower():gsub("/", "\\")
                if normRegistered == normInput then
                    return name
                end
                -- Also try comparing just filenames
                local regFilename = registeredPath:match("([^/\\]+)$")
                local inputFilename = texturePath:match("([^/\\]+)$")
                if regFilename and inputFilename and regFilename:lower() == inputFilename:lower() then
                    return name
                end
            end
        end
    end
    
    -- If still no match, return just the filename portion as a cleaner display
    local filename = texturePath:match("([^/\\]+)$")
    if filename then
        return filename
    end
    
    return nil
end

-- ============================================================
-- SHARED MEDIA: SOUNDS
-- ============================================================

function DF:GetSoundList()
    -- Returns a table of soundName -> soundName for dropdown compatibility
    -- Excludes entries whose LSM fetch returns a non-string (e.g. "None" returns integer 1)
    local list = {}
    local LSM = GetLSM()
    if LSM then
        local sounds = LSM:List(LSM.MediaType.SOUND)
        for _, name in ipairs(sounds) do
            if type(LSM:Fetch(LSM.MediaType.SOUND, name)) == "string" then
                list[name] = name
            end
        end
    end
    return list
end

function DF:GetSoundPath(soundName)
    if not soundName then return nil end
    -- If it looks like a path already, return it
    if soundName:find("\\") or soundName:find("/") then
        return soundName
    end
    local LSM = GetLSM()
    if LSM then
        local path = LSM:Fetch(LSM.MediaType.SOUND, soundName)
        if type(path) == "string" and path ~= "" then
            return path
        end
        return nil
    end
    return nil
end

-- Get font path by name (for SharedMedia compatibility)
function DF:GetFont(name)
    local LSM = GetLSM()
    if LSM then
        return LSM:Fetch("font", name) or name
    end
    -- Check if name is already a path
    if DF.SharedFonts[name] then
        return name
    end
    -- Try to find path by display name
    for path, displayName in pairs(DF.SharedFonts) do
        if displayName == name then
            return path
        end
    end
    return name
end

-- Default fallback font
local FALLBACK_FONT = "Fonts\\FRIZQT__.TTF"

-- Safely set a font on a fontstring with fallback
-- Uses font families for multi-alphabet support (Cyrillic, CJK, etc.) when available
-- Returns true if successful, false if had to use fallback
function DF:SafeSetFont(fontString, fontNameOrPath, fontSize, outline)
    if not fontString then return false end
    
    fontSize = fontSize or 10
    outline = outline or ""
    
    -- Normalize "NONE" to empty string (NONE is not a valid WoW font flag)
    if outline == "NONE" then outline = "" end
    
    -- Handle shadow as a special case
    local useShadow = (outline == "SHADOW")
    local actualOutline = useShadow and "" or outline
    
    local LSM = GetLSM()
    local fontPath
    
    -- If it looks like a path, use it directly (legacy support)
    if fontNameOrPath and (fontNameOrPath:find("\\") or fontNameOrPath:find("/")) then
        fontPath = fontNameOrPath
    elseif LSM and fontNameOrPath then
        -- Get path from SharedMedia
        fontPath = LSM:Fetch("font", fontNameOrPath)
    end
    
    -- Use fallback if no font path
    if not fontPath then
        fontPath = FALLBACK_FONT
    end
    
    -- Preload the font to ensure it's available
    PreloadFont(fontPath)
    
    -- Try to use font family for multi-alphabet support (WoW 11.x+)
    local fontFamilyName = GetOrCreateFontFamily(fontPath, actualOutline, useShadow)

    if fontFamilyName and _G[fontFamilyName] then
        -- Validate the font family object is usable before calling SetFontObject.
        -- During early login, CreateFontFamily can succeed but the internal C++ font
        -- data may not be initialized yet, causing an ACCESS_VIOLATION crash when
        -- SetFontObject tries to read it.  Wrap in pcall to fall through to the
        -- direct SetFont() path if the object is broken.
        local ok = pcall(function()
            fontString:SetFontObject(GameFontNormal)
            fontString:SetFontObject(_G[fontFamilyName])
        end)
        if not ok then
            -- Evict the broken cache entry so it gets recreated later
            local key = (fontPath or "default"):lower() .. "|" .. (actualOutline or "") .. "|" .. (useShadow and "shadow" or "noshadow")
            fontFamilies[key] = nil
        else
            -- Use SetTextScale to achieve desired size (font family uses BASE_FONT_SIZE)
            local scale = fontSize / BASE_FONT_SIZE
            fontString:SetTextScale(scale)

            -- Force WoW to re-render the text with new font properties
            -- This is needed because switching between font families with different outline flags
            -- may not immediately update the rendered text without a text refresh
            -- Note: Some fontStrings have "secret" text that cannot be read or compared,
            -- so we wrap this in pcall to handle those cases safely
            pcall(function()
                local text = fontString:GetText()
                if text and text ~= "" then
                    fontString:SetText("")
                    fontString:SetText(text)
                end
            end)

            -- Apply shadow directly to fontString (font family shadow is on the font object,
            -- but we need to apply to each fontString for proper settings)
            if useShadow then
                local db
                if DF.GetDB then
                    db = DF:GetDB()
                elseif DF.db then
                    local mode = (DF.GUI and DF.GUI.SelectedMode) or "party"
                    db = DF.db[mode]
                end
                local shadowX = db and db.fontShadowOffsetX or 1
                local shadowY = db and db.fontShadowOffsetY or -1
                local shadowColor = db and db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
                fontString:SetShadowOffset(shadowX, shadowY)
                fontString:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
            else
                fontString:SetShadowOffset(0, 0)
            end

            return true
        end
    end
    
    -- Fallback: Direct SetFont (no multi-alphabet support, or older WoW version)
    local success = fontString:SetFont(fontPath, fontSize, actualOutline)
    
    -- Reset text scale in case it was set before by font family code
    if fontString.SetTextScale then
        fontString:SetTextScale(1)
    end
    
    if not success then
        -- Ultimate fallback
        fontString:SetFont(FALLBACK_FONT, fontSize, actualOutline)
    end
    
    -- Apply or clear shadow
    if useShadow then
        -- Get shadow settings from current db (party or raid mode)
        local db
        if DF.GetDB then
            db = DF:GetDB()
        elseif DF.db then
            local mode = (DF.GUI and DF.GUI.SelectedMode) or "party"
            db = DF.db[mode]
        end
        local shadowX = db and db.fontShadowOffsetX or 1
        local shadowY = db and db.fontShadowOffsetY or -1
        local shadowColor = db and db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
        fontString:SetShadowOffset(shadowX, shadowY)
        fontString:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
    else
        fontString:SetShadowOffset(0, 0)
    end
    
    return success
end

-- Get texture path by name (for SharedMedia compatibility)
function DF:GetTexture(name)
    -- Special case for Solid - shouldn't reach here but safeguard
    if name == "Solid" then
        return nil
    end
    
    local LSM = GetLSM()
    if LSM then
        return LSM:Fetch(LSM.MediaType.STATUSBAR, name) or name
    end
    -- Check if name is already a path
    if DF.SharedTextures[name] then
        return name
    end
    -- Try to find path by display name
    for path, displayName in pairs(DF.SharedTextures) do
        if displayName == name then
            return path
        end
    end
    return name
end

-- ============================================================
-- GLOBAL (account-wide) DEFAULTS
-- Not per-profile. Lives at DandersFramesDB_v2.global.
-- ============================================================

DF.GlobalDefaults = {
    notifyOutdated = true,
}

-- ============================================================
-- DEFAULT SETTINGS (exported from profile v2.9.8)
-- ============================================================

DF.PartyDefaults = {
    -- Internal migration flags
    _blizzDispelIndicator = 1,
    _blizzOnlyDispellable = false,
    _defensiveBarMigrated = true,
    _defensiveIconMigrated = true,

    -- Global Font Shadow Settings (applies when outline is SHADOW)
    fontShadowOffsetX = 1,
    fontShadowOffsetY = -1,
    fontShadowColor = {r = 0, g = 0, b = 0, a = 1},

    -- Absorb Bar
    absorbBarAnchor = "TOPRIGHT",
    absorbBarAttachedClampMode = 1,
    absorbBarBackgroundColor = {r = 0, g = 0, b = 0, a = 1},
    absorbBarBlendMode = "BLEND",
    absorbBarBorderColor = {r = 1, g = 0, b = 0.29803922772408, a = 1},
    absorbBarBorderEnabled = true,
    absorbBarBorderSize = 4,
    absorbBarColor = {r = 0, g = 0.83529418706894, b = 1, a = 0.80208319425583},
    absorbBarFrameLevel = 11,
    absorbBarHeight = 7,
    absorbBarMode = "ATTACHED_OVERFLOW",
    absorbBarOrientation = "HORIZONTAL",
    absorbBarOverlayReverse = false,
    absorbBarOvershieldAlpha = 0.8,
    absorbBarOvershieldColor = nil,
    absorbBarOvershieldReverse = false,
    absorbBarOvershieldStyle = "SPARK",
    absorbBarReverse = false,
    absorbBarShowOvershield = false,
    absorbBarStrata = "MEDIUM",
    absorbBarTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense",
    absorbBarWidth = 46,
    absorbBarX = 0,
    absorbBarY = 0,
    showAbsorbBar = true,

    -- AFK Icon
    afkIconAlpha = 0.8,
    afkIconAnchor = "BOTTOM",
    afkIconEnabled = true,
    afkIconFrameLevel = 0,
    afkIconHideInCombat = true,
    afkIconScale = 1,
    afkIconShowText = true,
    afkIconShowTimer = true,
    afkIconText = "AFK",
    afkIconTextColor = {r = 1, g = 0.7725490927696228, b = 0.5411764979362488, a = 1},
    afkIconX = 0,
    afkIconY = 2,

    -- Aggro Highlight
    aggroColorHighThreat = {r = 1, g = 1, b = 0.47},
    aggroColorHighestThreat = {r = 1, g = 0.6, b = 0},
    aggroColorTanking = {r = 1, g = 0, b = 0},
    aggroHighlightAlpha = 0.7500000596046448,
    aggroHighlightInset = -2,
    aggroHighlightMode = "GLOW",
    aggroHighlightThickness = 1,
    aggroOnlyTanking = false,
    aggroUseCustomColors = false,

    -- Anchor/Position
    anchorPoint = "CENTER",
    anchorX = 0,
    anchorY = -325,

    -- Background
    backgroundClassAlpha = 1,
    backgroundColor = {r = 0.5137255191802979, g = 0.5137255191802979, b = 0.5137255191802979, a = 0.7531240582466125},
    backgroundColorMode = "CUSTOM",
    backgroundMode = "BACKGROUND",
    backgroundTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist",
    missingHealthClassAlpha = 0.8,
    missingHealthColor = {r = 0.5, g = 0, b = 0, a = 0.8},
    missingHealthColorHigh = {r = 0.05098039656877518, g = 1, b = 0, a = 1},
    missingHealthColorHighUseClass = false,
    missingHealthColorHighWeight = 1,
    missingHealthColorLow = {r = 1, g = 0, b = 0, a = 1},
    missingHealthColorLowUseClass = false,
    missingHealthColorLowWeight = 2,
    missingHealthColorMedium = {r = 1, g = 1, b = 0, a = 1},
    missingHealthColorMediumUseClass = false,
    missingHealthColorMediumWeight = 2,
    missingHealthColorMode = "CUSTOM",
    missingHealthGradientAlpha = 0.8,
    missingHealthTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist",

    -- Border
    borderColor = {r = 0, g = 0, b = 0, a = 1},
    borderSize = 1,
    showFrameBorder = true,

    -- Boss Debuffs
    bossDebuffHighlight = true,
    bossDebuffScale = 1.2,
    bossDebuffsAnchor = "TOPLEFT",
    bossDebuffsBorderScale = 1,
    bossDebuffsEnabled = true,
    bossDebuffsFrameLevel = 35,
    bossDebuffsStrata = "HIGH",
    bossDebuffsGrowth = "RIGHT",
    bossDebuffsHideTooltip = false,
    bossDebuffsIconSize = 20,
    bossDebuffsMax = 4,
    bossDebuffsOffsetX = 3,
    bossDebuffsOffsetY = -13,
    bossDebuffsShowCountdown = true,
    bossDebuffsShowNumbers = true,
    bossDebuffsSpacing = 5,
    bossDebuffsTextScale = 1.0,

    -- Container overlay (native dispel overlay for private auras)
    -- Enable state + dispel-type are driven by dispelOverlaySource and
    -- dispelOverlayDispelType (unified across both overlay systems).
    bossDebuffsContainerOverlayGradientDir = 0,
    bossDebuffsContainerOverlayAlpha = 1.0,
    bossDebuffsContainerOverlayFrameLevel = 6,
    bossDebuffsContainerOverlayStrata = "MEDIUM",
    bossDebuffsContainerOverlaySizeAdjust = 0,

    -- Buff settings
    buffAlpha = 1,
    buffAnchor = "BOTTOMRIGHT",
    buffBorderEnabled = false,
    buffBorderInset = 1,
    buffBorderThickness = 1,
    buffClickThrough = true,
    buffClickThroughInCombatOnly = false,
    buffClickThroughKeybinds = true,
    buffCountdownFont = "Friz Quadrata TT",
    buffCountdownOutline = "OUTLINE",
    buffCountdownScale = 1,
    buffCountdownX = 0,
    buffCountdownY = 0,
    buffDeduplicateDefensives = true,
    buffDisableMouse = false,
    buffDurationAnchor = "CENTER",
    buffDurationColorByTime = true,
    buffDurationHideAboveEnabled = false,
    buffDurationHideAboveThreshold = 10,
    buffDurationFont = "DF Roboto SemiBold",
    buffDurationOutline = "SHADOW",
    buffDurationScale = 1.2000000476837,
    buffDurationX = -2,
    buffDurationY = 2,
    buffExpiringBorderColor = {r = 1, g = 0.50196081399918, b = 0, a = 1},
    buffExpiringBorderColorByTime = false,
    buffExpiringBorderEnabled = true,
    buffExpiringBorderInset = 1,
    buffExpiringBorderPulsate = true,
    buffExpiringBorderThickness = 2,
    buffExpiringEnabled = true,
    buffExpiringThreshold = 30,
    buffExpiringThresholdMode = "PERCENT",
    buffExpiringTintColor = {r = 1, g = 0, b = 0.12156863510609, a = 0.46354159712791},
    buffExpiringTintEnabled = false,
    buffFilterCancelable = false,
    buffFilterMode = "BLIZZARD",
    buffFilterPlayer = true,
    buffFilterRaid = false,

    -- Aura Source Mode
    auraSourceMode = "DIRECT",                -- "BLIZZARD" or "DIRECT"

    -- Direct Mode: Buff Filters
    directBuffShowAll = false,                -- Show all buffs (ignores sub-filters)
    directBuffOnlyMine = true,               -- Restrict all buff filters to player-cast only
    directBuffFilterRaid = false,             -- RAID filter
    directBuffFilterRaidInCombat = true,      -- RAID_IN_COMBAT filter
    directBuffFilterCancelable = false,       -- CANCELABLE filter
    directBuffFilterNotCancelable = false,    -- NOT_CANCELABLE filter
    directBuffFilterImportant = true,         -- IMPORTANT filter (12.0.1)
    directBuffFilterBigDefensive = true,      -- BIG_DEFENSIVE filter (12.0.1)
    directBuffFilterExternalDefensive = true, -- EXTERNAL_DEFENSIVE filter (12.0.0)
    directBuffSortOrder = "TIME",             -- "DEFAULT" / "TIME" / "NAME"

    -- Direct Mode: Debuff Filters
    directDebuffShowAll = true,               -- Show all debuffs (ignores sub-filters)
    directDebuffFilterRaid = true,            -- RAID filter
    directDebuffFilterRaidInCombat = true,    -- RAID_IN_COMBAT filter
    directDebuffFilterCrowdControl = true,    -- CROWD_CONTROL filter
    directDebuffFilterImportant = true,       -- IMPORTANT filter (12.0.1)
    directDebuffDispellableMode = "PLAYER",  -- "PLAYER" (RAID_PLAYER_DISPELLABLE) or "ALL" (dispelName ~= nil)
    directDebuffSortOrder = "TIME",           -- "DEFAULT" / "TIME" / "NAME"

    buffGrowth = "LEFT_UP",
    buffHideSwipe = false,
    buffMax = 5,
    buffOffsetX = -1,
    buffOffsetY = 3,
    buffPaddingX = -2,
    buffPaddingY = -2,
    buffScale = 1,
    buffShowCountdown = false,
    buffShowDuration = true,
    buffSize = 24,
    buffStackAnchor = "BOTTOMRIGHT",
    buffStackFont = "DF Roboto SemiBold",
    buffStackMinimum = 2,
    buffStackOutline = "SHADOW",
    buffStackScale = 1,
    buffStackX = 0,
    buffStackY = 0,
    buffWrap = 3,
    buffWrapOffsetX = 0,
    buffWrapOffsetY = 0,
    showBuffs = true,

    -- Center Status Icon
    centerStatusIconAnchor = "CENTER",
    centerStatusIconEnabled = true,
    centerStatusIconFrameLevel = 0,
    centerStatusIconHide = false,
    centerStatusIconScale = 1,
    centerStatusIconX = 0,
    centerStatusIconY = 0,

    -- Class Color
    classColorAlpha = 1,
    colorPickerGlobalOverride = false,
    colorPickerOverride = true,

    -- Dead/Fade Settings
    deadBackgroundAlpha = 0.3,
    deadBackgroundColor = {r = 0.2, g = 0.2, b = 0.2, a = 1},
    deadFadeEnabled = false,
    deadHealthBarAlpha = 0.3,
    deadHealthTextAlpha = 0.3,
    deadNameAlpha = 0.5,
    deadUseCustomBgColor = false,
    fadeDeadAuras = 1,
    fadeDeadBackground = 1,
    fadeDeadBackgroundColor = {r = 1, g = 0, b = 0, a = 1},
    fadeDeadFrames = true,
    fadeDeadHealthBar = 1,
    fadeDeadIcons = 1,
    fadeDeadName = 1,
    fadeDeadPowerBar = 0,
    fadeDeadStatusText = 1,
    fadeDeadUseCustomColor = false,

    -- Health threshold fading (fade when health above threshold)
    healthFadeEnabled = false,
    healthFadeAlpha = 0.5,
    healthFadeThreshold = 100,
    hfCancelOnDispel = true,

    -- Debuff settings
    debuffAlpha = 1,
    debuffAnchor = "BOTTOMLEFT",
    debuffBorderColorBleed = {r = 1, g = 0, b = 0},
    debuffBorderColorByType = true,
    debuffBorderColorCurse = {r = 0.6, g = 0, b = 1},
    debuffBorderColorDisease = {r = 0.6, g = 0.4, b = 0},
    debuffBorderColorMagic = {r = 0.2, g = 0.6, b = 1},
    debuffBorderColorNone = {r = 0, g = 0, b = 0, a = 1},
    debuffBorderColorPoison = {r = 0, g = 0.6, b = 0},
    debuffBorderEnabled = true,
    debuffBorderInset = 1,
    debuffBorderThickness = 2,
    debuffClickThrough = true,
    debuffClickThroughInCombatOnly = false,
    debuffClickThroughKeybinds = true,
    debuffCountdownFont = "Friz Quadrata TT",
    debuffCountdownOutline = "OUTLINE",
    debuffCountdownScale = 1,
    debuffCountdownX = 0,
    debuffCountdownY = 0,
    debuffDisableMouse = false,
    debuffDurationAnchor = "CENTER",
    debuffDurationColorByTime = false,
    debuffDurationHideAboveEnabled = false,
    debuffDurationHideAboveThreshold = 10,
    debuffDurationFont = "DF Roboto SemiBold",
    debuffDurationOutline = "SHADOW",
    debuffDurationScale = 1,
    debuffDurationX = 0,
    debuffDurationY = 0,
    debuffExpiringBorderColor = {r = 1, g = 0.27843138575554, b = 0, a = 1},
    debuffExpiringBorderColorByTime = false,
    debuffExpiringBorderEnabled = true,
    debuffExpiringBorderInset = 1,
    debuffExpiringBorderPulsate = true,
    debuffExpiringBorderThickness = 2,
    debuffExpiringEnabled = false,
    debuffExpiringThreshold = 90,
    debuffExpiringThresholdMode = "PERCENT",
    debuffExpiringTintColor = {r = 1, g = 0.30196079611778, b = 0.30196079611778, a = 0.81119740009308},
    debuffExpiringTintEnabled = true,
    debuffFilterMode = "BLIZZARD",
    debuffGrowth = "RIGHT_UP",
    debuffHideSwipe = false,
    debuffMax = 5,
    debuffOffsetX = 1,
    debuffOffsetY = 4,
    debuffPaddingX = 2,
    debuffPaddingY = 2,
    debuffScale = 1,
    debuffShowAll = false,
    debuffShowCountdown = false,
    debuffShowDuration = false,
    debuffSize = 18,
    debuffStackAnchor = "BOTTOMRIGHT",
    debuffStackFont = "DF Roboto SemiBold",
    debuffStackMinimum = 2,
    debuffStackOutline = "SHADOW",
    debuffStackScale = 1,
    debuffStackX = 0,
    debuffStackY = 0,
    debuffWrap = 3,
    debuffWrapOffsetX = 0,
    debuffWrapOffsetY = 0,
    showDebuffs = true,

    -- Defensive Bar
    defensiveBarAnchor = "CENTER",
    defensiveBarBorderColor = {r = 0, g = 0.8, b = 0, a = 1},
    defensiveBarBorderSize = 2,
    defensiveBarEnabled = true,
    defensiveBarFrameLevel = 0,
    defensiveBarGrowth = "RIGHT_DOWN",
    defensiveBarIconSize = 24,
    defensiveBarMax = 4,
    defensiveBarScale = 1.5,
    defensiveBarShowDuration = true,
    defensiveBarSpacing = 2,
    defensiveBarWrap = 5,
    defensiveBarX = 0,
    defensiveBarY = 0,

    -- Defensive Icon
    defensiveIconAnchor = "CENTER",
    defensiveIconBorderColor = {r = 0, g = 0.8, b = 0, a = 1},
    defensiveIconBorderSize = 2,
    defensiveIconClickThrough = true,
    defensiveIconClickThroughInCombatOnly = true,
    defensiveIconClickThroughKeybinds = true,
    defensiveIconDisableMouse = false,
    defensiveIconDurationColor = {r = 1, g = 1, b = 1},
    defensiveIconDurationColorByTime = false,
    defensiveIconDurationFont = "DF Roboto SemiBold",
    defensiveIconDurationOutline = "SHADOW",
    defensiveIconDurationScale = 1.0499999523163,
    defensiveIconDurationX = 0,
    defensiveIconDurationY = 0,
    defensiveIconEnabled = true,
    defensiveIconFrameLevel = 0,
    defensiveIconHideSwipe = false,
    defensiveIconScale = 1,
    defensiveIconShowBorder = true,
    defensiveIconShowDuration = true,
    defensiveIconShowSwipe = true,
    defensiveIconSize = 30,
    defensiveIconX = 0,
    defensiveIconY = 0,

    -- Dispel Overlay
    dispelAnimate = false,
    dispelAnimateSpeed = 0.5,
    dispelBleedColor = {r = 1, g = 0, b = 0},
    dispelBorderAlpha = 1,
    dispelBorderInset = 0,
    dispelBorderSize = 2,
    dispelBorderStyle = "OUTER",
    dispelCurseColor = {r = 0.6, g = 0, b = 1},
    dispelDiseaseColor = {r = 0.6, g = 0.4, b = 0},
    dispelFrameLevel = 10,
    dispelGradientAlpha = 1,
    dispelGradientBlendMode = "BLEND",
    dispelGradientDarkenAlpha = 0.40000000596046,
    dispelGradientDarkenEnabled = false,
    dispelGradientIntensity = 2.600000143051148,
    dispelGradientOnCurrentHealth = true,
    dispelGradientSize = 0.5,
    dispelGradientStyle = "TOP",
    dispelIconAlpha = 1,
    dispelIconOffsetX = 0,
    dispelIconOffsetY = 0,
    dispelIconPosition = "TOPRIGHT",
    dispelIconSize = 20,
    dispelMagicColor = {r = 0.2, g = 0.6, b = 1},
    dispelOnlyPlayerTypes = false,
    dispelOverlayMode = "PLAYER_DISPELLABLE",
    dispelPoisonColor = {r = 0, g = 0.6, b = 0},
    dispelShowBleed = false,
    dispelShowBorder = true,
    dispelShowCurse = true,
    dispelShowDisease = true,
    dispelShowEnrage = true,
    dispelShowGradient = true,
    dispelShowIcon = true,
    dispelShowMagic = true,
    dispelShowPoison = true,
    dispelNameText = false,
    dispellableHighlight = true,

    -- Dispel overlay source selector (Phase 1 UI uses bridge to old toggles)
    -- Values: "off" | "dandersframes" | "blizzard" | "both"
    dispelOverlaySource = "both",
    -- Unified "Show Overlay For" shared across all sources.
    -- Values: 1 = Dispellable By Me, 2 = All Dispellable (Blizzard convention)
    dispelOverlayDispelType = 2,

    -- External Defensive
    externalDefAnchor = "CENTER",
    externalDefBorderColor = {r = 0, g = 0.8, b = 0, a = 1},
    externalDefBorderSize = 2,
    externalDefEnabled = true,
    externalDefFrameLevel = 0,
    externalDefScale = 1.5,
    externalDefShowDuration = true,
    externalDefStrata = "DEFAULT",
    externalDefX = 0,
    externalDefY = 0,

    -- Frame Dimensions & Layout
    frameHeight = 64,
    framePadding = 0,
    frameSpacing = 2,
    frameScale = 1.0,
    frameWidth = 125,
    gridSize = 25,
    growDirection = "HORIZONTAL",
    growthAnchor = "CENTER",
    locked = true,
    permanentMover = false,
    permanentMoverActionLeft = "OPEN_SETTINGS",
    permanentMoverActionRight = "SWITCH_PROFILE",
    permanentMoverActionShiftLeft = "TOGGLE_TEST",
    permanentMoverActionShiftRight = "SWITCH_CC_PROFILE",
    permanentMoverAnchor = "RIGHT",
    permanentMoverAttachTo = "CONTAINER",
    permanentMoverColor = {r = 0.45, g = 0.45, b = 0.95},
    permanentMoverCombatColor = {r = 0.8, g = 0.15, b = 0.15},
    permanentMoverHeight = 60,
    permanentMoverHideInCombat = false,
    permanentMoverOffsetX = 20,
    permanentMoverOffsetY = 0,
    permanentMoverPullTimerDuration = 10,
    permanentMoverShowOnHover = false,
    permanentMoverWidth = 15,
    pixelPerfect = true,
    snapToGrid = true,
    hideDragOverlay = false,

    -- Group Labels
    groupLabelColor = {r = 1, g = 1, b = 1, a = 1},
    groupLabelEnabled = true,
    groupLabelFont = "DF Roboto SemiBold",
    groupLabelFontSize = 12,
    groupLabelFormat = "SHORT",
    groupLabelOffsetX = 0,
    groupLabelOffsetY = 5,
    groupLabelOutline = "SHADOW",
    groupLabelPosition = "START",
    groupLabelShadow = false,

    -- GUI State
    guiHeight = 693.33349609375,
    guiScale = 1,
    guiWidth = 816.6666259765625,

    -- Heal Absorb Bar
    healAbsorbBarAnchor = "BOTTOM",
    healAbsorbBarAttachedClampMode = 1,
    healAbsorbBarBackgroundColor = {r = 0, g = 0, b = 0, a = 0.4570315182209},
    healAbsorbBarBlendMode = "BLEND",
    healAbsorbBarBorderColor = {r = 0, g = 0, b = 0, a = 1},
    healAbsorbBarBorderEnabled = false,
    healAbsorbBarBorderSize = 1,
    healAbsorbBarColor = {r = 1, g = 0.25098040699959, b = 0.25098040699959, a = 0.77604186534882},
    healAbsorbBarHeight = 6,
    healAbsorbBarMode = "OVERLAY",
    healAbsorbBarOrientation = "HORIZONTAL",
    healAbsorbBarOverlayReverse = false,
    healAbsorbBarOvershieldAlpha = 0.8,
    healAbsorbBarOvershieldColor = nil,
    healAbsorbBarOvershieldReverse = false,
    healAbsorbBarOvershieldStyle = "SPARK",
    healAbsorbBarReverse = false,
    healAbsorbBarShowOvershield = false,
    healAbsorbBarTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense",
    healAbsorbBarWidth = 50,
    healAbsorbBarX = 0,
    healAbsorbBarY = -10,

    -- Heal Prediction
    healPredictionAllColor = {r = 0, g = 0.7, b = 0.4, a = 0.7},
    healPredictionAnchor = "CENTER",
    healPredictionBackgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
    healPredictionBlendMode = "BLEND",
    healPredictionClampMode = 1,
    healPredictionEnabled = true,
    healPredictionFrameLevel = 12,
    healPredictionHeight = 6,
    healPredictionMode = "OVERLAY",
    healPredictionMyColor = {r = 0, g = 0.8, b = 0.2, a = 0.7},
    healPredictionOrientation = "HORIZONTAL",
    healPredictionOthersColor = {r = 0, g = 0.5, b = 0.8, a = 0.7},
    healPredictionOverflowPercent = 0,
    healPredictionOverlayReverse = false,
    healPredictionReverse = false,
    healPredictionShowMode = "MINE",
    healPredictionShowOverheal = false,
    healPredictionStrata = "SANDWICH",
    healPredictionTexture = "Interface\\Buttons\\WHITE8x8",
    healPredictionWidth = 50,
    healPredictionX = 0,
    healPredictionY = 0,

    -- Health Bar & Text
    healthColor = {r = 0.5607843399047852, g = 0.7490196228027344, b = 0.1843137294054031, a = 1},
    healthColorHigh = {r = 0.05098039656877518, g = 1, b = 0, a = 1},
    healthColorHighUseClass = false,
    healthColorHighWeight = 1,
    healthColorLow = {r = 1, g = 0, b = 0, a = 1},
    healthColorLowUseClass = false,
    healthColorLowWeight = 2,
    healthColorMedium = {r = 1, g = 1, b = 0, a = 1},
    healthColorMediumUseClass = false,
    healthColorMediumWeight = 2,
    healthColorMode = "CLASS",
    healthFont = "DF Roboto SemiBold",
    healthFontSize = 10,
    healthOrientation = "HORIZONTAL",
    healthTextAbbreviate = true,
    healthTextAnchor = "CENTER",
    healthTextColor = {r = 1, g = 1, b = 1, a = 1},
    healthTextFormat = "CURRENTMAX",
    healthTextHidePercent = false,
    healthTextOutline = "SHADOW",
    healthTextUseClassColor = false,
    healthTextX = 0,
    healthTextY = 4,
    healthTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist",
    showHealthText = false,

    -- Blizzard Frame Hiding
    hideBlizzardFrames = true,
    hideBlizzardPartyFrames = true,
    hideBlizzardRaidFrames = true,
    hideDefaultPlayerFrame = false,
    hidePlayerFrame = false,
    showBlizzardSideMenu = true,

    -- Hover Highlight
    hoverHighlightAlpha = 0.8,
    hoverHighlightColor = {r = 1, g = 1, b = 1, a = 1},
    hoverHighlightInset = 0,
    hoverHighlightMode = "CORNERS",
    hoverHighlightThickness = 2,

    -- Leader Icon
    leaderIconAlpha = 1,
    leaderIconAnchor = "TOPLEFT",
    leaderIconEnabled = true,
    leaderIconFrameLevel = 0,
    leaderIconHide = false,
    leaderIconHideInCombat = true,
    leaderIconScale = 1,
    leaderIconX = -2,
    leaderIconY = 2,

    -- Masque
    masqueBorderControl = false,

    -- Minimap
    minimapIcon = {
        hide = false,
        minimapPos = 207.168514387028,
    },
    showMinimapButton = true,

    -- Missing Buff
    missingBuffCheckAttackPower = true,
    missingBuffCheckBronze = true,
    missingBuffCheckIntellect = true,
    missingBuffCheckSkyfury = true,
    missingBuffCheckStamina = true,
    missingBuffCheckVersatility = true,
    missingBuffClassDetection = true,
    missingBuffHideFromBar = true,
    missingBuffIconAnchor = "CENTER",
    missingBuffIconBorderColor = {r = 1, g = 0, b = 0, a = 1},
    missingBuffIconBorderSize = 2,
    missingBuffIconDebug = false,
    missingBuffIconEnabled = false,
    missingBuffIconFrameLevel = 0,
    missingBuffIconScale = 1.2000000476837,
    missingBuffIconShowBorder = true,
    missingBuffIconSize = 24,
    missingBuffIconX = 0,
    missingBuffIconY = 0,

    -- My Buff Indicator (DEPRECATED — hidden from UI, force-disabled on load)
    myBuffIndicatorAnimate = false,
    myBuffIndicatorBorderAlpha = 0.8,
    myBuffIndicatorBorderInset = -1,
    myBuffIndicatorBorderSize = 3,
    myBuffIndicatorColor = {r = 0, g = 1, b = 0},
    myBuffIndicatorEnabled = false,
    myBuffIndicatorGradientAlpha = 0.4000000059604645,
    myBuffIndicatorGradientOnCurrentHealth = true,
    myBuffIndicatorGradientSize = 0.5,
    myBuffIndicatorGradientStyle = "EDGE",
    myBuffIndicatorShowBorder = false,
    myBuffIndicatorShowGradient = true,

    -- Name Text
    nameColorClass = false,
    nameFont = "DF Roboto SemiBold",
    nameFontSize = 11,
    nameTextAnchor = "TOP",
    nameTextColor = {r = 1, g = 1, b = 1, a = 1},
    nameTextLength = 13,
    nameTextOutline = "SHADOW",
    nameTextTruncateMode = "ELLIPSIS",
    nameTextUseClassColor = false,
    nameTextX = 0,
    nameTextY = -10,

    -- Out of Range
    oorAbsorbBarAlpha = 0.20000000298023,
    oorAurasAlpha = 0.20000000298023,
    oorBackgroundAlpha = 0.10000000149012,
    oorDefensiveIconAlpha = 0.5,
    oorDispelOverlayAlpha = 0.20000000298023,
    oorEnabled = false,
    oorHealthBarAlpha = 0.20000000298023,
    oorHealthTextAlpha = 0.25,
    oorIconsAlpha = 0.5,
    oorMissingBuffAlpha = 0.5,
    oorMissingHealthAlpha = 0.20000000298023,
    oorMyBuffIndicatorAlpha = 0,
    oorNameTextAlpha = 1,
    oorPowerBarAlpha = 0.20000000298023,
    oorTargetedSpellAlpha = 0.5,
    oorAuraDesignerAlpha = 0.20000000298023,

    -- Personal Targeted Spells (Nameplate)
    personalTargetedSpellAlpha = 1,
    personalTargetedSpellBorderColor = {r = 1, g = 0.3, b = 0},
    personalTargetedSpellBorderSize = 2,
    personalTargetedSpellDurationColor = {r = 1, g = 1, b = 1},
    personalTargetedSpellDurationFont = "DF Roboto SemiBold",
    personalTargetedSpellDurationOutline = "SHADOW",
    personalTargetedSpellDurationScale = 1.2,
    personalTargetedSpellDurationX = 0,
    personalTargetedSpellDurationY = 0,
    personalTargetedSpellEnabled = false,
    personalTargetedSpellGrowth = "RIGHT",
    personalTargetedSpellHighlightColor = {r = 1, g = 0.8, b = 0},
    personalTargetedSpellHighlightImportant = true,
    personalTargetedSpellHighlightInset = 0,
    personalTargetedSpellHighlightSize = 3,
    personalTargetedSpellHighlightStyle = "glow",
    personalTargetedSpellImportantOnly = false,
    personalTargetedSpellInArena = true,
    personalTargetedSpellInBattlegrounds = true,
    personalTargetedSpellInDungeons = true,
    personalTargetedSpellInOpenWorld = true,
    personalTargetedSpellInRaids = true,
    personalTargetedSpellInterruptedDuration = 0.5,
    personalTargetedSpellInterruptedShowX = true,
    personalTargetedSpellInterruptedTintAlpha = 0.5,
    personalTargetedSpellInterruptedTintColor = {r = 1, g = 0, b = 0},
    personalTargetedSpellInterruptedXColor = {r = 1, g = 0, b = 0},
    personalTargetedSpellInterruptedXSize = 20,
    personalTargetedSpellMaxIcons = 5,
    personalTargetedSpellScale = 1,
    personalTargetedSpellShowBorder = true,
    personalTargetedSpellShowDuration = true,
    personalTargetedSpellShowInterrupted = true,
    personalTargetedSpellShowSwipe = true,
    personalTargetedSpellSize = 40,
    personalTargetedSpellSpacing = 4,
    personalTargetedSpellX = 0,
    personalTargetedSpellY = -150,

    -- Pet Frames
    petAnchor = "BOTTOM",
    petBackgroundColor = {r = 0.9254902601242065, g = 0.9254902601242065, b = 0.9254902601242065, a = 0.800000011920929},
    petBorderColor = {r = 0, g = 0, b = 0, a = 1},
    petEnabled = false,
    petFrameHeight = 22,
    petFrameWidth = 130,
    petGroupAnchor = "BOTTOM",
    petGroupGrowth = "HORIZONTAL",
    petGroupLabel = "Pets",
    petGroupMode = "ATTACHED",
    petGroupOffsetX = 5,
    petGroupOffsetY = -10,
    petGroupShowLabel = true,
    petGroupSpacing = 2,
    petHealthAnchor = "RIGHT",
    petHealthBgColor = {r = 0.2, g = 0.2, b = 0.2, a = 0.8},
    petHealthColor = {r = 0, g = 0, b = 0, a = 1},
    petHealthColorMode = "CUSTOM",
    petHealthFont = "DF Roboto SemiBold",
    petHealthFontOutline = "SHADOW",
    petHealthFontSize = 7,
    petHealthTextColor = {r = 1, g = 1, b = 1},
    petHealthX = -2,
    petHealthY = 0,
    petMatchOwnerHeight = false,
    petMatchOwnerWidth = true,
    petNameAnchor = "CENTER",
    petNameColor = {r = 1, g = 1, b = 1},
    petNameFont = "DF Roboto SemiBold",
    petNameFontOutline = "SHADOW",
    petNameFontSize = 8,
    petNameMaxLength = 8,
    petNameX = 0,
    petNameY = 0,
    petOffsetX = 0,
    petOffsetY = -1,
    petShowBorder = false,
    petShowHealthText = true,
    petTexture = "Interface\\TargetingFrame\\UI-StatusBar",

    -- Phased Icon
    phasedIconAlpha = 1,
    phasedIconAnchor = "CENTER",
    phasedIconEnabled = true,
    phasedIconFrameLevel = 0,
    phasedIconHideInCombat = true,
    phasedIconScale = 1.5,
    phasedIconShowLFGEye = true,
    phasedIconShowText = false,
    phasedIconText = "Phased",
    phasedIconTextColor = {r = 0.5, g = 0.5, b = 1},
    phasedIconX = 0,
    phasedIconY = 0,

    -- Power Bar
    powerBarHeight = 4,
    showPowerBar = false,

    -- Raid Layout
    raidAnchorX = -6.666610717773438,
    raidAnchorY = -25,
    raidEnabled = true,
    raidFlatColumnAnchor = "START",
    raidFlatFrameAnchor = "START",
    raidFlatGrowthAnchor = "TOPLEFT",
    raidFlatHorizontalSpacing = 2,
    raidFlatPlayerAnchor = "CENTER",
    raidFlatReverseFillOrder = false,
    raidFlatVerticalSpacing = 2,
    raidGroupAnchor = "CENTER",
    raidGroupDisplayOrder = {1, 2, 3, 4, 5, 6, 7, 8},
    raidGroupOrder = "NORMAL",
    raidGroupRowGrowth = "START",
    raidGroupSpacing = -1,
    raidGroupVisible = {true, true, true, true, true, true, true, true},
    raidGroupsPerRow = 8,
    raidLocked = true,
    raidPlayerAnchor = "START",
    raidPlayersPerRow = 5,
    raidRoleIconAlpha = 1,
    raidRoleIconAnchor = "BOTTOMLEFT",
    raidRoleIconEnabled = false,
    raidRoleIconFrameLevel = 0,
    raidRoleIconHideInCombat = true,
    raidRoleIconScale = 1.400000095367432,
    raidRoleIconShowAssist = true,
    raidRoleIconShowTank = true,
    raidRoleIconShowText = true,
    raidRoleIconTextAssist = "MA",
    raidRoleIconTextColor = {r = 1, g = 1, b = 0},
    raidRoleIconTextTank = "MT",
    raidRoleIconX = 5,
    raidRoleIconY = 3,
    raidRowColSpacing = 30,
    raidTargetIconAlpha = 1,
    raidTargetIconAnchor = "TOP",
    raidTargetIconEnabled = true,
    raidTargetIconFrameLevel = 0,
    raidTargetIconHide = false,
    raidTargetIconHideInCombat = false,
    raidTargetIconScale = 1.1000000238419,
    raidTargetIconX = 36,
    raidTargetIconY = 5,
    raidTestFrameCount = 40,
    raidUseGroups = true,

    -- Range Check
    rangeAlpha = 0.5,
    rangeCheckEnabled = true,
    rangeCheckSpellID = 0,
    rangeFadeAlpha = 0.40000000596046,
    rangeUpdateInterval = 0.5,

    -- Ready Check Icon
    readyCheckIconAlpha = 1,
    readyCheckIconAnchor = "CENTER",
    readyCheckIconEnabled = true,
    readyCheckIconFrameLevel = 0,
    readyCheckIconHide = false,
    readyCheckIconHideInCombat = false,
    readyCheckIconPersist = 6,
    readyCheckIconScale = 1.6000000238419,
    readyCheckIconX = 0,
    readyCheckIconY = 0,

    -- Resource Bar
    resourceBarAnchor = "BOTTOM",
    resourceBarBackgroundColor = {r = 0, g = 0, b = 0, a = 0.80000001192093},
    resourceBarBackgroundEnabled = true,
    resourceBarBorderColor = {r = 0, g = 0, b = 0, a = 1},
    resourceBarBorderEnabled = false,
    resourceBarClassFilter = {
        DEATHKNIGHT = true,
        DEMONHUNTER = true,
        DRUID = true,
        EVOKER = true,
        HUNTER = true,
        MAGE = true,
        MONK = true,
        PALADIN = true,
        PRIEST = true,
        ROGUE = true,
        SHAMAN = true,
        WARLOCK = true,
        WARRIOR = true,
    },
    resourceBarClassColor = false,
    resourceBarEnabled = true,
    resourceBarFrameLevel = 20,
    resourceBarHeight = 4,
    resourceBarMatchWidth = true,
    resourceBarOrientation = "HORIZONTAL",
    resourceBarReverseFill = false,
    resourceBarShowDPS = false,
    resourceBarShowHealer = true,
    resourceBarShowInSoloMode = true,
    resourceBarShowTank = false,
    resourceBarSmooth = true,
    resourceBarWidth = 60,
    resourceBarX = 0,
    resourceBarY = 0,

    -- Class Power (Holy Power, Chi, Combo Points, etc. - player frame only)
    classPowerEnabled = false,
    classPowerHeight = 4,
    classPowerGap = 1,
    classPowerAnchor = "INSIDE_BOTTOM",
    classPowerX = 0,
    classPowerY = -1,
    classPowerIgnoreFade = true,
    classPowerUseCustomColor = false,
    classPowerColor = {r = 1, g = 0.82, b = 0, a = 1},
    classPowerBgColor = {r = 0.15, g = 0.15, b = 0.15, a = 0.4},
    classPowerShowTank = true,
    classPowerShowHealer = true,
    classPowerShowDamager = true,

    -- Rested Indicator
    restedIndicator = false,
    restedIndicatorAnchor = "TOPRIGHT",
    restedIndicatorGlow = false,
    restedIndicatorIcon = true,
    restedIndicatorOffsetX = -18,
    restedIndicatorOffsetY = -14,
    restedIndicatorSize = 20,

    -- Resurrection Icon
    resurrectionIconAlpha = 1,
    resurrectionIconAnchor = "CENTER",
    resurrectionIconEnabled = true,
    resurrectionIconFrameLevel = 0,
    resurrectionIconHideInCombat = false,
    resurrectionIconScale = 1.600000023841858,
    resurrectionIconShowText = false,
    resurrectionIconTextCasting = "Res...",
    resurrectionIconTextColor = {r = 0.2, g = 1, b = 0.2},
    resurrectionIconTextPending = "Res Ready",
    resurrectionIconX = 0,
    resurrectionIconY = 0,

    -- Role Icon
    roleIconAlpha = 1,
    roleIconAnchor = "TOPLEFT",
    roleIconFrameLevel = 0,
    roleIconHide = false,
    roleIconHideDPS = true,
    roleIconHideHealer = false,
    roleIconHideOnlyInCombat = true,
    roleIconHideTank = true,
    roleIconExternalDPS = "",
    roleIconExternalHealer = "",
    roleIconExternalTank = "",
    roleIconOnlyInCombat = false,
    roleIconScale = 1,
    roleIconShowDPS = true,
    roleIconShowHealer = true,
    roleIconShowTank = true,
    roleIconStyle = "CUSTOM",
    roleIconX = 2,
    roleIconY = -2,
    showRoleIcon = true,

    -- Selection Highlight
    selectionHighlightAlpha = 1,
    selectionHighlightColor = {r = 1, g = 1, b = 1, a = 1},
    selectionHighlightInset = 0,
    selectionHighlightMode = "SOLID",
    selectionHighlightThickness = 1,

    -- Smooth Bars & Solo Mode
    smoothBars = true,
    soloMode = true,

    -- Sorting
    sortAlphabetical = false,
    sortByClass = false,
    sortClassOrder = {
        "DEATHKNIGHT",
        "DEMONHUNTER",
        "DRUID",
        "EVOKER",
        "HUNTER",
        "MAGE",
        "MONK",
        "PALADIN",
        "PRIEST",
        "SHAMAN",
        "ROGUE",
        "WARLOCK",
        "WARRIOR",
    },
    sortEnabled = true,
    sortRoleOrder = {"TANK", "HEALER", "MELEE", "RANGED"},
    sortSelfPosition = "SORTED",
    sortSeparateMeleeRanged = false,
    useFrameSort = false,

    -- Status Icon & Text
    statusIconFont = "DF Roboto SemiBold",
    statusIconFontOutline = "SHADOW",
    statusIconFontSize = 11,
    statusTextAnchor = "CENTER",
    statusTextColor = {r = 1, g = 1, b = 1, a = 1},
    statusTextEnabled = true,
    statusTextFont = "DF Roboto SemiBold",
    statusTextFontSize = 14,
    statusTextOutline = "SHADOW",
    statusTextX = 0,
    statusTextY = 0,

    -- Summon Icon
    summonIconAlpha = 1,
    summonIconAnchor = "BOTTOM",
    summonIconEnabled = true,
    summonIconFrameLevel = 0,
    summonIconHideInCombat = false,
    summonIconScale = 1.5,
    summonIconShowText = true,
    summonIconTextAccepted = "Accepted",
    summonIconTextColor = {r = 0.6, g = 0.2, b = 1},
    summonIconTextDeclined = "Declined",
    summonIconTextPending = "Summon",
    summonIconX = 0,
    summonIconY = 9,

    -- Targeted Spells (on-frame)
    targetedSpellAlpha = 1,
    targetedSpellAnchor = "BOTTOM",
    targetedSpellBorderColor = {r = 1, g = 0.3, b = 0},
    targetedSpellBorderSize = 2,
    targetedSpellDisableMouse = false,
    targetedSpellDurationColor = {r = 1, g = 1, b = 1},
    targetedSpellDurationColorByTime = false,
    targetedSpellDurationFont = "DF Roboto SemiBold",
    targetedSpellDurationOutline = "SHADOW",
    targetedSpellDurationScale = 1,
    targetedSpellDurationX = 0,
    targetedSpellDurationY = 0,
    targetedSpellEnabled = true,
    targetedSpellFrameLevel = 0,
    targetedSpellGrowth = "CENTER_H",
    targetedSpellHideSwipe = false,
    targetedSpellHighlightColor = {r = 1, g = 0.8, b = 0},
    targetedSpellHighlightImportant = true,
    targetedSpellHighlightInset = 2,
    targetedSpellHighlightSize = 3,
    targetedSpellHighlightStyle = "glow",
    targetedSpellImportantOnly = false,
    targetedSpellInArena = true,
    targetedSpellInBattlegrounds = true,
    targetedSpellInDungeons = true,
    targetedSpellInOpenWorld = true,
    targetedSpellInRaids = true,
    targetedSpellInterruptedDuration = 0.5,
    targetedSpellInterruptedShowX = true,
    targetedSpellInterruptedTintAlpha = 0.5,
    targetedSpellInterruptedTintColor = {r = 1, g = 0, b = 0},
    targetedSpellInterruptedXColor = {r = 1, g = 0, b = 0},
    targetedSpellInterruptedXSize = 16,
    targetedSpellMaxIcons = 3,
    targetedSpellNameplateOffscreen = false,
    targetedSpellScale = 1,
    targetedSpellShowBorder = true,
    targetedSpellShowDuration = true,
    targetedSpellShowInterrupted = true,
    targetedSpellShowSwipe = true,
    targetedSpellSize = 24,
    targetedSpellSortByTime = true,
    targetedSpellSortNewestFirst = true,
    targetedSpellSpacing = 2,
    targetedSpellX = 0,
    targetedSpellY = -28,

    -- Targeted List (party-mode only)
    -- Stacked cast-bar display showing enemy casts targeting party members.
    -- User-facing name ("Targeted List") is intentionally decoupled from the
    -- internal `targetedList*` db prefix so the feature can be renamed later
    -- by editing locale strings only. Party-mode only by design.
    -- Position uses an absolute mover (targetedListX/Y), not an anchor point.
    targetedListBackgroundAlpha = 0.5,
    targetedListBorderColor = {r = 0.18, g = 0.18, b = 0.18, a = 1},
    targetedListEnabled = false,
    targetedListFadeOutDuration = 0.25,
    targetedListFont = "DF Roboto SemiBold",
    targetedListFontOutline = "SHADOW",
    targetedListFontSize = 11,
    targetedListSpellNameFontSize = 0,
    targetedListTargetNameFontSize = 0,
    targetedListGrowth = "DOWN",
    targetedListHeight = 22,
    targetedListHideOwnCasts = false,
    targetedListHideOutOfCombat = true,
    targetedListHighlightImportant = true,
    targetedListHighlightColor = {r = 1, g = 0.8, b = 0},
    targetedListIconPosition = "LEFT",
    targetedListImportantOnly = false,
    targetedListInArena = true,
    targetedListInBattlegrounds = true,
    targetedListInDungeons = true,
    targetedListInOpenWorld = true,
    targetedListInRaids = false,
    targetedListInterruptedFlashDuration = 2.0,
    targetedListInterruptibleColor = {r = 1, g = 0.494, b = 0.137, a = 1},
    targetedListMaxBars = 6,
    targetedListShowArrowPrefix = true,
    targetedListShowArrowSuffix = false,
    targetedListShowBorder = true,
    targetedListShowUntargeted = true,
    targetedListShowDuration = true,
    targetedListShowIcon = true,
    targetedListShowSpellName = true,
    targetedListShowTargetName = true,
    targetedListSortOrder = "OLDEST",
    targetedListSpacing = 6,
    targetedListStylePreset = "DEFAULT",
    targetedListTargetNameClassColor = true,
    targetedListTexture = "Interface\\Buttons\\WHITE8x8",
    targetedListUninterruptibleColor = {r = 0.8, g = 0.302, b = 0.302, a = 1},
    targetedListSelfTargetColorEnabled = true,
    targetedListSelfTargetColor = {r = 0.02, g = 0.776, b = 0.4, a = 0.2},
    targetedListWidth = 240,
    targetedListX = 0,
    targetedListY = -10,
    targetedListZoomIcon = true,
    -- Per-text-element anchor + offset. Anchor is a point name
    -- (LEFT / CENTER / RIGHT) applied within the bar's progress
    -- region. X / Y are pixel offsets from that anchor.
    targetedListSpellNameAnchor = "LEFT",
    targetedListSpellNameAlign = "LEFT",
    targetedListSpellNameWidth = 0,
    targetedListSpellNameX = 4,
    targetedListSpellNameY = 0,
    targetedListTargetNameAnchor = "RIGHT",
    targetedListTargetNameAlign = "RIGHT",
    targetedListTargetNameWidth = 0,
    targetedListTargetNameX = -4,
    targetedListTargetNameY = 0,
    targetedListDurationAnchor = "RIGHT",
    targetedListDurationAlign = "RIGHT",
    targetedListDurationFontSize = 17,
    targetedListDurationX = -6,
    targetedListDurationY = 0,
    targetedListInterruptTextAnchor = "CENTER",
    targetedListInterruptTextAlign = "CENTER",
    targetedListInterruptTextFontSize = 12,
    targetedListInterruptTextWidth = 0,
    targetedListInterruptTextX = 0,
    targetedListInterruptTextY = 0,

    -- Test Mode
    -- testShowTargetedList drives the Targeted List demo bars in party
    -- test mode. There is no raid-mode equivalent because the
    -- Targeted List itself is party-only.
    testShowTargetedList = false,
    testAnimateTargetedList = true,
    testAnimateHealth = false,
    testBossDebuffCount = 1,
    testBuffCount = 2,
    testDebuffCount = 2,
    testFrameCount = 5,
    testPreset = "STATIC",
    testShowAbsorbs = false,
    testShowAggro = false,
    testShowAuras = false,
    testShowBossDebuffs = false,
    testShowDispelGlow = false,
    testShowExternalDef = false,
    testShowHealPrediction = false,
    testShowIcons = true,
    testShowMissingBuff = false,
    testShowMyBuffIndicator = false,
    testShowOutOfRange = false,
    testShowPets = true,
    testShowSelection = false,
    testShowStatusIcons = false,
    testShowTargetedSpell = false,
    testShowClassPower = true,
    testShowAuraDesigner = false,

    -- Tooltip settings
    tooltipAuraAnchor = "DEFAULT",
    tooltipAuraDisableInCombat = false,
    tooltipAuraEnabled = true,
    tooltipAuraX = 0,
    tooltipAuraY = 0,
    tooltipBuffAnchor = "FRAME",
    tooltipBuffAnchorPos = "BOTTOMRIGHT",
    tooltipBuffDisableInCombat = true,
    tooltipBuffEnabled = true,
    tooltipBuffX = 0,
    tooltipBuffY = -10,
    tooltipDebuffAnchor = "FRAME",
    tooltipDebuffAnchorPos = "BOTTOMLEFT",
    tooltipDebuffDisableInCombat = false,
    tooltipDebuffEnabled = true,
    tooltipDebuffX = 0,
    tooltipDebuffY = -10,
    tooltipDefensiveAnchor = "CURSOR",
    tooltipDefensiveAnchorPos = "BOTTOMRIGHT",
    tooltipDefensiveDisableInCombat = false,
    tooltipDefensiveEnabled = true,
    tooltipResurrectionEnabled = false,
    tooltipDefensiveX = 0,
    tooltipDefensiveY = 0,
    tooltipBindingAnchor = "FRAME",
    tooltipBindingAnchorPos = "TOPRIGHT",
    tooltipBindingDisableInCombat = false,
    tooltipBindingEnabled = false,
    tooltipBindingX = 4,
    tooltipBindingY = 0,
    tooltipFrameAnchor = "DEFAULT",
    tooltipFrameAnchorPos = "BOTTOMRIGHT",
    tooltipFrameDisableInCombat = true,
    tooltipFrameEnabled = true,
    tooltipFrameX = 0,
    tooltipFrameY = 0,

    -- Secure Headers
    useSecureHeaders = true,

    -- Vehicle Icon
    vehicleIconAlpha = 1,
    vehicleIconAnchor = "BOTTOMRIGHT",
    vehicleIconEnabled = true,
    vehicleIconFrameLevel = 0,
    vehicleIconHideInCombat = false,
    vehicleIconScale = 1.5,
    vehicleIconShowText = true,
    vehicleIconText = "Vehicle",
    vehicleIconTextColor = {r = 0.4, g = 0.8, b = 1},
    vehicleIconX = -12,
    vehicleIconY = 1,

    -- Pinned Frames
    pinnedFrames = {
        sets = {
            [1] = {
                enabled = false,
                frameType = "player",
                testCount = 3,
                name = "Pinned 1",
                players = {},
                growDirection = "HORIZONTAL",
                unitsPerRow = 5,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = 200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
            [2] = {
                enabled = false,
                frameType = "player",
                testCount = 3,
                name = "Pinned 2",
                players = {},
                growDirection = "HORIZONTAL",
                unitsPerRow = 5,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = -200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
        },
    },

    -- Highlight Frames
    highlightFrames = {
        sets = {
            [1] = {
                enabled = false,
                name = "Highlight 1",
                players = {},
                growDirection = "VERTICAL",
                unitsPerRow = 2,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = 200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
            [2] = {
                enabled = false,
                name = "Highlight 2",
                players = {},
                growDirection = "HORIZONTAL",
                unitsPerRow = 5,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = -200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
        },
    },

    -- Aura Designer
    auraDesigner = {
        enabled = false,
        spec = "auto",
        previewScale = 1.0,
        soundEnabled = true,
        defaults = {
            iconSize = 24,
            iconScale = 1.0,
            showDuration = true,
            showStacks = true,
            durationFont = "Friz Quadrata TT",
            durationScale = 1.0,
            durationOutline = "OUTLINE",
            durationAnchor = "CENTER",
            durationX = 0,
            durationY = 0,
            stackFont = "Friz Quadrata TT",
            stackScale = 1.0,
            stackOutline = "OUTLINE",
            stackAnchor = "BOTTOMRIGHT",
            stackX = 0,
            stackY = 0,
            iconBorderEnabled = true,
            iconBorderThickness = 1,
            stackMinimum = 2,
            durationColorByTime = false,
            durationColor = {r = 1, g = 1, b = 1, a = 1},
            stackColor = {r = 1, g = 1, b = 1, a = 1},
            hideIcon = false,
            indicatorFrameLevel = 30,
            indicatorFrameStrata = "INHERIT",
        },
        auras = {},
        layoutGroups = {},
        nextLayoutGroupID = 1,
    },

}

DF.RaidDefaults = {
    -- Internal migration flags
    _blizzDispelIndicator = 1,
    _blizzOnlyDispellable = false,
    _defensiveBarMigrated = true,
    _defensiveIconMigrated = true,

    -- Global Font Shadow Settings (applies when outline is SHADOW)
    fontShadowOffsetX = 1,
    fontShadowOffsetY = -1,
    fontShadowColor = {r = 0, g = 0, b = 0, a = 1},

    -- Absorb Bar
    absorbBarAnchor = "TOPRIGHT",
    absorbBarAttachedClampMode = 1,
    absorbBarBackgroundColor = {r = 0, g = 0, b = 0, a = 1},
    absorbBarBlendMode = "BLEND",
    absorbBarBorderColor = {r = 1, g = 0, b = 0.29803922772408, a = 1},
    absorbBarBorderEnabled = true,
    absorbBarBorderSize = 4,
    absorbBarColor = {r = 0, g = 0.83529418706894, b = 1, a = 0.80208319425583},
    absorbBarFrameLevel = 11,
    absorbBarHeight = 7,
    absorbBarMode = "ATTACHED_OVERFLOW",
    absorbBarOrientation = "HORIZONTAL",
    absorbBarOverlayReverse = false,
    absorbBarOvershieldAlpha = 0.8,
    absorbBarOvershieldColor = nil,
    absorbBarOvershieldReverse = false,
    absorbBarOvershieldStyle = "SPARK",
    absorbBarReverse = false,
    absorbBarShowOvershield = false,
    absorbBarStrata = "MEDIUM",
    absorbBarTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense",
    absorbBarWidth = 46,
    absorbBarX = 0,
    absorbBarY = 0,
    showAbsorbBar = true,

    -- AFK Icon
    afkIconAlpha = 0.8,
    afkIconAnchor = "BOTTOM",
    afkIconEnabled = true,
    afkIconFrameLevel = 0,
    afkIconHideInCombat = true,
    afkIconScale = 1,
    afkIconShowText = true,
    afkIconShowTimer = true,
    afkIconText = "AFK",
    afkIconTextColor = {r = 1, g = 0.7725490927696228, b = 0.5411764979362488, a = 1},
    afkIconX = 0,
    afkIconY = 2,

    -- Aggro Highlight
    aggroColorHighThreat = {r = 1, g = 1, b = 0.47},
    aggroColorHighestThreat = {r = 1, g = 0.6, b = 0},
    aggroColorTanking = {r = 1, g = 0, b = 0},
    aggroHighlightAlpha = 0.7500000596046448,
    aggroHighlightInset = -2,
    aggroHighlightMode = "GLOW",
    aggroHighlightThickness = 1,
    aggroOnlyTanking = false,
    aggroUseCustomColors = false,

    -- Anchor/Position
    anchorPoint = "CENTER",
    anchorX = 0,
    anchorY = -325,

    -- Background
    backgroundClassAlpha = 1,
    backgroundColor = {r = 0.5137255191802979, g = 0.5137255191802979, b = 0.5137255191802979, a = 0.7531240582466125},
    backgroundColorMode = "CUSTOM",
    backgroundMode = "BACKGROUND",
    backgroundTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist",
    missingHealthClassAlpha = 0.8,
    missingHealthColor = {r = 0.5, g = 0, b = 0, a = 0.8},
    missingHealthColorHigh = {r = 0.05098039656877518, g = 1, b = 0, a = 1},
    missingHealthColorHighUseClass = false,
    missingHealthColorHighWeight = 1,
    missingHealthColorLow = {r = 1, g = 0, b = 0, a = 1},
    missingHealthColorLowUseClass = false,
    missingHealthColorLowWeight = 2,
    missingHealthColorMedium = {r = 1, g = 1, b = 0, a = 1},
    missingHealthColorMediumUseClass = false,
    missingHealthColorMediumWeight = 2,
    missingHealthColorMode = "CUSTOM",
    missingHealthGradientAlpha = 0.8,
    missingHealthTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist",

    -- Border
    borderColor = {r = 0, g = 0, b = 0, a = 1},
    borderSize = 1,
    showFrameBorder = true,

    -- Boss Debuffs
    bossDebuffHighlight = true,
    bossDebuffScale = 1.2,
    bossDebuffsAnchor = "TOPLEFT",
    bossDebuffsBorderScale = 1,
    bossDebuffsEnabled = true,
    bossDebuffsFrameLevel = 35,
    bossDebuffsStrata = "HIGH",
    bossDebuffsGrowth = "RIGHT",
    bossDebuffsHideTooltip = false,
    bossDebuffsIconSize = 20,
    bossDebuffsMax = 4,
    bossDebuffsOffsetX = 3,
    bossDebuffsOffsetY = -13,
    bossDebuffsShowCountdown = true,
    bossDebuffsShowNumbers = true,
    bossDebuffsSpacing = 5,
    bossDebuffsTextScale = 1.0,

    -- Container overlay (native dispel overlay for private auras)
    -- Enable state + dispel-type are driven by dispelOverlaySource and
    -- dispelOverlayDispelType (unified across both overlay systems).
    bossDebuffsContainerOverlayGradientDir = 0,
    bossDebuffsContainerOverlayAlpha = 1.0,
    bossDebuffsContainerOverlayFrameLevel = 6,
    bossDebuffsContainerOverlayStrata = "MEDIUM",
    bossDebuffsContainerOverlaySizeAdjust = 0,

    -- Buff settings
    buffAlpha = 1,
    buffAnchor = "BOTTOMRIGHT",
    buffBorderEnabled = false,
    buffBorderInset = 1,
    buffBorderThickness = 1,
    buffClickThrough = true,
    buffClickThroughInCombatOnly = false,
    buffClickThroughKeybinds = true,
    buffCountdownFont = "Friz Quadrata TT",
    buffCountdownOutline = "OUTLINE",
    buffCountdownScale = 1,
    buffCountdownX = 0,
    buffCountdownY = 0,
    buffDeduplicateDefensives = true,
    buffDisableMouse = false,
    buffDurationAnchor = "CENTER",
    buffDurationColorByTime = true,
    buffDurationHideAboveEnabled = false,
    buffDurationHideAboveThreshold = 10,
    buffDurationFont = "DF Roboto SemiBold",
    buffDurationOutline = "SHADOW",
    buffDurationScale = 1.2000000476837,
    buffDurationX = -2,
    buffDurationY = 2,
    buffExpiringBorderColor = {r = 1, g = 0.50196081399918, b = 0, a = 1},
    buffExpiringBorderColorByTime = false,
    buffExpiringBorderEnabled = true,
    buffExpiringBorderInset = 1,
    buffExpiringBorderPulsate = true,
    buffExpiringBorderThickness = 2,
    buffExpiringEnabled = true,
    buffExpiringThreshold = 30,
    buffExpiringThresholdMode = "PERCENT",
    buffExpiringTintColor = {r = 1, g = 0, b = 0.12156863510609, a = 0.46354159712791},
    buffExpiringTintEnabled = false,
    buffFilterCancelable = false,
    buffFilterMode = "BLIZZARD",
    buffFilterPlayer = true,
    buffFilterRaid = false,

    -- Aura Source Mode
    auraSourceMode = "DIRECT",                -- "BLIZZARD" or "DIRECT"

    -- Direct Mode: Buff Filters
    directBuffShowAll = false,                -- Show all buffs (ignores sub-filters)
    directBuffOnlyMine = true,               -- Restrict all buff filters to player-cast only
    directBuffFilterRaid = false,             -- RAID filter
    directBuffFilterRaidInCombat = true,      -- RAID_IN_COMBAT filter
    directBuffFilterCancelable = false,       -- CANCELABLE filter
    directBuffFilterNotCancelable = false,    -- NOT_CANCELABLE filter
    directBuffFilterImportant = true,         -- IMPORTANT filter (12.0.1)
    directBuffFilterBigDefensive = true,      -- BIG_DEFENSIVE filter (12.0.1)
    directBuffFilterExternalDefensive = true, -- EXTERNAL_DEFENSIVE filter (12.0.0)
    directBuffSortOrder = "TIME",             -- "DEFAULT" / "TIME" / "NAME"

    -- Direct Mode: Debuff Filters
    directDebuffShowAll = true,               -- Show all debuffs (ignores sub-filters)
    directDebuffFilterRaid = true,            -- RAID filter
    directDebuffFilterRaidInCombat = true,    -- RAID_IN_COMBAT filter
    directDebuffFilterCrowdControl = true,    -- CROWD_CONTROL filter
    directDebuffFilterImportant = true,       -- IMPORTANT filter (12.0.1)
    directDebuffDispellableMode = "PLAYER",  -- "PLAYER" (RAID_PLAYER_DISPELLABLE) or "ALL" (dispelName ~= nil)
    directDebuffSortOrder = "TIME",           -- "DEFAULT" / "TIME" / "NAME"

    buffGrowth = "LEFT_UP",
    buffHideSwipe = false,
    buffMax = 5,
    buffOffsetX = -1,
    buffOffsetY = 3,
    buffPaddingX = -2,
    buffPaddingY = -2,
    buffScale = 1,
    buffShowCountdown = false,
    buffShowDuration = true,
    buffSize = 24,
    buffStackAnchor = "BOTTOMRIGHT",
    buffStackFont = "DF Roboto SemiBold",
    buffStackMinimum = 2,
    buffStackOutline = "SHADOW",
    buffStackScale = 1,
    buffStackX = 0,
    buffStackY = 0,
    buffWrap = 3,
    buffWrapOffsetX = 0,
    buffWrapOffsetY = 0,
    showBuffs = true,

    -- Center Status Icon
    centerStatusIconAnchor = "CENTER",
    centerStatusIconEnabled = true,
    centerStatusIconFrameLevel = 0,
    centerStatusIconHide = false,
    centerStatusIconScale = 1,
    centerStatusIconX = 0,
    centerStatusIconY = 0,

    -- Class Color
    classColorAlpha = 1,
    colorPickerGlobalOverride = false,
    colorPickerOverride = true,

    -- Dead/Fade Settings
    deadBackgroundAlpha = 0.3,
    deadBackgroundColor = {r = 0.2, g = 0.2, b = 0.2, a = 1},
    deadFadeEnabled = false,
    deadHealthBarAlpha = 0.3,
    deadHealthTextAlpha = 0.3,
    deadNameAlpha = 0.5,
    deadUseCustomBgColor = false,
    fadeDeadAuras = 1,
    fadeDeadBackground = 1,
    fadeDeadBackgroundColor = {r = 1, g = 0, b = 0, a = 1},
    fadeDeadFrames = true,
    fadeDeadHealthBar = 1,
    fadeDeadIcons = 1,
    fadeDeadName = 1,
    fadeDeadPowerBar = 0,
    fadeDeadStatusText = 1,
    fadeDeadUseCustomColor = false,

    -- Health threshold fading (fade when health above threshold)
    healthFadeEnabled = false,
    healthFadeAlpha = 0.5,
    healthFadeThreshold = 100,
    hfCancelOnDispel = true,

    -- Debuff settings
    debuffAlpha = 1,
    debuffAnchor = "BOTTOMLEFT",
    debuffBorderColorBleed = {r = 1, g = 0, b = 0},
    debuffBorderColorByType = true,
    debuffBorderColorCurse = {r = 0.6, g = 0, b = 1},
    debuffBorderColorDisease = {r = 0.6, g = 0.4, b = 0},
    debuffBorderColorMagic = {r = 0.2, g = 0.6, b = 1},
    debuffBorderColorNone = {r = 0, g = 0, b = 0, a = 1},
    debuffBorderColorPoison = {r = 0, g = 0.6, b = 0},
    debuffBorderEnabled = true,
    debuffBorderInset = 1,
    debuffBorderThickness = 2,
    debuffClickThrough = true,
    debuffClickThroughInCombatOnly = false,
    debuffClickThroughKeybinds = true,
    debuffCountdownFont = "Friz Quadrata TT",
    debuffCountdownOutline = "OUTLINE",
    debuffCountdownScale = 1,
    debuffCountdownX = 0,
    debuffCountdownY = 0,
    debuffDisableMouse = false,
    debuffDurationColorByTime = false,
    debuffDurationHideAboveEnabled = false,
    debuffDurationHideAboveThreshold = 10,
    debuffDurationFont = "DF Roboto SemiBold",
    debuffDurationAnchor = "CENTER",
    debuffDurationOutline = "SHADOW",
    debuffDurationScale = 1,
    debuffDurationX = 0,
    debuffDurationY = 0,
    debuffExpiringBorderColor = {r = 1, g = 0.27843138575554, b = 0, a = 1},
    debuffExpiringBorderColorByTime = false,
    debuffExpiringBorderEnabled = true,
    debuffExpiringBorderInset = 1,
    debuffExpiringBorderPulsate = true,
    debuffExpiringBorderThickness = 2,
    debuffExpiringEnabled = false,
    debuffExpiringThreshold = 90,
    debuffExpiringThresholdMode = "PERCENT",
    debuffExpiringTintColor = {r = 1, g = 0.30196079611778, b = 0.30196079611778, a = 0.81119740009308},
    debuffExpiringTintEnabled = true,
    debuffFilterMode = "BLIZZARD",
    debuffGrowth = "RIGHT_UP",
    debuffHideSwipe = false,
    debuffMax = 5,
    debuffOffsetX = 1,
    debuffOffsetY = 4,
    debuffPaddingX = 2,
    debuffPaddingY = 2,
    debuffScale = 1,
    debuffShowAll = false,
    debuffShowCountdown = false,
    debuffShowDuration = false,
    debuffSize = 18,
    debuffStackAnchor = "BOTTOMRIGHT",
    debuffStackFont = "DF Roboto SemiBold",
    debuffStackMinimum = 2,
    debuffStackOutline = "SHADOW",
    debuffStackScale = 1,
    debuffStackX = 0,
    debuffStackY = 0,
    debuffWrap = 3,
    debuffWrapOffsetX = 0,
    debuffWrapOffsetY = 0,
    showDebuffs = true,

    -- Defensive Bar
    defensiveBarAnchor = "CENTER",
    defensiveBarBorderColor = {r = 0, g = 0.8, b = 0, a = 1},
    defensiveBarBorderSize = 2,
    defensiveBarEnabled = true,
    defensiveBarFrameLevel = 0,
    defensiveBarGrowth = "RIGHT_DOWN",
    defensiveBarIconSize = 24,
    defensiveBarMax = 3,
    defensiveBarScale = 1.0,
    defensiveBarShowDuration = true,
    defensiveBarSpacing = 2,
    defensiveBarWrap = 5,
    defensiveBarX = 0,
    defensiveBarY = 0,

    -- Defensive Icon
    defensiveIconAnchor = "CENTER",
    defensiveIconBorderColor = {r = 0, g = 0.8, b = 0, a = 1},
    defensiveIconBorderSize = 2,
    defensiveIconClickThrough = true,
    defensiveIconClickThroughInCombatOnly = true,
    defensiveIconClickThroughKeybinds = true,
    defensiveIconDisableMouse = false,
    defensiveIconDurationColor = {r = 1, g = 1, b = 1},
    defensiveIconDurationColorByTime = false,
    defensiveIconDurationFont = "DF Roboto SemiBold",
    defensiveIconDurationOutline = "SHADOW",
    defensiveIconDurationScale = 1.0499999523163,
    defensiveIconDurationX = 0,
    defensiveIconDurationY = 0,
    defensiveIconEnabled = true,
    defensiveIconFrameLevel = 0,
    defensiveIconHideSwipe = false,
    defensiveIconScale = 1,
    defensiveIconShowBorder = true,
    defensiveIconShowDuration = true,
    defensiveIconShowSwipe = true,
    defensiveIconSize = 20,
    defensiveIconX = 0,
    defensiveIconY = 0,

    -- Dispel Overlay
    dispelAnimate = false,
    dispelAnimateSpeed = 0.5,
    dispelBleedColor = {r = 1, g = 0, b = 0},
    dispelBorderAlpha = 1,
    dispelBorderInset = 0,
    dispelBorderSize = 2,
    dispelBorderStyle = "OUTER",
    dispelCurseColor = {r = 0.6, g = 0, b = 1},
    dispelDiseaseColor = {r = 0.6, g = 0.4, b = 0},
    dispelFrameLevel = 10,
    dispelGradientAlpha = 1,
    dispelGradientBlendMode = "BLEND",
    dispelGradientDarkenAlpha = 0.40000000596046,
    dispelGradientDarkenEnabled = false,
    dispelGradientIntensity = 2.600000143051148,
    dispelGradientOnCurrentHealth = true,
    dispelGradientSize = 0.5,
    dispelGradientStyle = "TOP",
    dispelIconAlpha = 1,
    dispelIconOffsetX = 0,
    dispelIconOffsetY = 0,
    dispelIconPosition = "TOPRIGHT",
    dispelIconSize = 20,
    dispelMagicColor = {r = 0.2, g = 0.6, b = 1},
    dispelOnlyPlayerTypes = false,
    dispelOverlayMode = "PLAYER_DISPELLABLE",
    dispelPoisonColor = {r = 0, g = 0.6, b = 0},
    dispelShowBleed = false,
    dispelShowBorder = true,
    dispelShowCurse = true,
    dispelShowDisease = true,
    dispelShowEnrage = true,
    dispelShowGradient = true,
    dispelShowIcon = true,
    dispelShowMagic = true,
    dispelShowPoison = true,
    dispelNameText = false,
    dispellableHighlight = true,

    -- Dispel overlay source selector (Phase 1 UI uses bridge to old toggles)
    -- Values: "off" | "dandersframes" | "blizzard" | "both"
    dispelOverlaySource = "both",
    -- Unified "Show Overlay For" shared across all sources.
    -- Values: 1 = Dispellable By Me, 2 = All Dispellable (Blizzard convention)
    dispelOverlayDispelType = 2,

    -- External Defensive
    externalDefAnchor = "CENTER",
    externalDefBorderColor = {r = 0, g = 0.8, b = 0, a = 1},
    externalDefBorderSize = 2,
    externalDefEnabled = true,
    externalDefFrameLevel = 0,
    externalDefScale = 1.5,
    externalDefShowDuration = true,
    externalDefStrata = "DEFAULT",
    externalDefX = 0,
    externalDefY = 0,

    -- Frame Dimensions & Layout
    frameHeight = 64,
    framePadding = 0,
    frameSpacing = 2,
    frameScale = 1.0,
    frameWidth = 125,
    gridSize = 25,
    growDirection = "HORIZONTAL",
    growthAnchor = "CENTER",
    locked = true,
    permanentMover = false,
    permanentMoverActionLeft = "OPEN_SETTINGS",
    permanentMoverActionRight = "SWITCH_PROFILE",
    permanentMoverActionShiftLeft = "TOGGLE_TEST",
    permanentMoverActionShiftRight = "SWITCH_CC_PROFILE",
    permanentMoverAnchor = "RIGHT",
    permanentMoverAttachTo = "CONTAINER",
    permanentMoverColor = {r = 0.45, g = 0.45, b = 0.95},
    permanentMoverCombatColor = {r = 0.8, g = 0.15, b = 0.15},
    permanentMoverHeight = 60,
    permanentMoverHideInCombat = false,
    permanentMoverOffsetX = 20,
    permanentMoverOffsetY = 0,
    permanentMoverPullTimerDuration = 10,
    permanentMoverShowOnHover = false,
    permanentMoverWidth = 15,
    pixelPerfect = true,
    snapToGrid = true,
    hideDragOverlay = false,

    -- Group Labels
    groupLabelColor = {r = 1, g = 1, b = 1, a = 1},
    groupLabelEnabled = true,
    groupLabelFont = "DF Roboto SemiBold",
    groupLabelFontSize = 12,
    groupLabelFormat = "SHORT",
    groupLabelOffsetX = 0,
    groupLabelOffsetY = 5,
    groupLabelOutline = "SHADOW",
    groupLabelPosition = "START",
    groupLabelShadow = false,

    -- GUI State
    guiHeight = 693.33349609375,
    guiScale = 1,
    guiWidth = 816.6666259765625,

    -- Heal Absorb Bar
    healAbsorbBarAnchor = "BOTTOM",
    healAbsorbBarAttachedClampMode = 1,
    healAbsorbBarBackgroundColor = {r = 0, g = 0, b = 0, a = 0.4570315182209},
    healAbsorbBarBlendMode = "BLEND",
    healAbsorbBarBorderColor = {r = 0, g = 0, b = 0, a = 1},
    healAbsorbBarBorderEnabled = false,
    healAbsorbBarBorderSize = 1,
    healAbsorbBarColor = {r = 1, g = 0.25098040699959, b = 0.25098040699959, a = 0.77604186534882},
    healAbsorbBarHeight = 6,
    healAbsorbBarMode = "OVERLAY",
    healAbsorbBarOrientation = "HORIZONTAL",
    healAbsorbBarOverlayReverse = false,
    healAbsorbBarOvershieldAlpha = 0.8,
    healAbsorbBarOvershieldColor = nil,
    healAbsorbBarOvershieldReverse = false,
    healAbsorbBarOvershieldStyle = "SPARK",
    healAbsorbBarReverse = false,
    healAbsorbBarShowOvershield = false,
    healAbsorbBarTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense",
    healAbsorbBarWidth = 50,
    healAbsorbBarX = 0,
    healAbsorbBarY = -10,

    -- Heal Prediction
    healPredictionAllColor = {r = 0, g = 0.7, b = 0.4, a = 0.7},
    healPredictionAnchor = "CENTER",
    healPredictionBackgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
    healPredictionBlendMode = "BLEND",
    healPredictionClampMode = 1,
    healPredictionEnabled = true,
    healPredictionFrameLevel = 12,
    healPredictionHeight = 6,
    healPredictionMode = "OVERLAY",
    healPredictionMyColor = {r = 0, g = 0.8, b = 0.2, a = 0.7},
    healPredictionOrientation = "HORIZONTAL",
    healPredictionOthersColor = {r = 0, g = 0.5, b = 0.8, a = 0.7},
    healPredictionOverflowPercent = 0,
    healPredictionOverlayReverse = false,
    healPredictionReverse = false,
    healPredictionShowMode = "MINE",
    healPredictionShowOverheal = false,
    healPredictionStrata = "SANDWICH",
    healPredictionTexture = "Interface\\Buttons\\WHITE8x8",
    healPredictionWidth = 50,
    healPredictionX = 0,
    healPredictionY = 0,

    -- Health Bar & Text
    healthColor = {r = 0.5607843399047852, g = 0.7490196228027344, b = 0.1843137294054031, a = 1},
    healthColorHigh = {r = 0.05098039656877518, g = 1, b = 0, a = 1},
    healthColorHighUseClass = false,
    healthColorHighWeight = 1,
    healthColorLow = {r = 1, g = 0, b = 0, a = 1},
    healthColorLowUseClass = false,
    healthColorLowWeight = 2,
    healthColorMedium = {r = 1, g = 1, b = 0, a = 1},
    healthColorMediumUseClass = false,
    healthColorMediumWeight = 2,
    healthColorMode = "CLASS",
    healthFont = "DF Roboto SemiBold",
    healthFontSize = 10,
    healthOrientation = "HORIZONTAL",
    healthTextAbbreviate = true,
    healthTextAnchor = "CENTER",
    healthTextColor = {r = 1, g = 1, b = 1, a = 1},
    healthTextFormat = "CURRENTMAX",
    healthTextHidePercent = false,
    healthTextOutline = "SHADOW",
    healthTextUseClassColor = false,
    healthTextX = 0,
    healthTextY = 4,
    healthTexture = "Interface\\AddOns\\DandersFrames\\Media\\DF_Minimalist",
    showHealthText = false,

    -- Blizzard Frame Hiding
    hideBlizzardFrames = true,
    hideBlizzardPartyFrames = true,
    hideBlizzardRaidFrames = true,
    hideDefaultPlayerFrame = false,
    hidePlayerFrame = false,
    showBlizzardSideMenu = true,

    -- Hover Highlight
    hoverHighlightAlpha = 0.8,
    hoverHighlightColor = {r = 1, g = 1, b = 1, a = 1},
    hoverHighlightInset = 0,
    hoverHighlightMode = "CORNERS",
    hoverHighlightThickness = 2,

    -- Leader Icon
    leaderIconAlpha = 1,
    leaderIconAnchor = "TOPLEFT",
    leaderIconEnabled = true,
    leaderIconFrameLevel = 0,
    leaderIconHide = false,
    leaderIconHideInCombat = true,
    leaderIconScale = 1,
    leaderIconX = -2,
    leaderIconY = 2,

    -- Masque
    masqueBorderControl = false,

    -- Minimap
    minimapIcon = {
        hide = false,
        minimapPos = 207.168514387028,
    },
    showMinimapButton = true,

    -- Missing Buff
    missingBuffCheckAttackPower = true,
    missingBuffCheckBronze = true,
    missingBuffCheckIntellect = true,
    missingBuffCheckSkyfury = true,
    missingBuffCheckStamina = true,
    missingBuffCheckVersatility = true,
    missingBuffClassDetection = true,
    missingBuffHideFromBar = true,
    missingBuffIconAnchor = "CENTER",
    missingBuffIconBorderColor = {r = 1, g = 0, b = 0, a = 1},
    missingBuffIconBorderSize = 2,
    missingBuffIconDebug = false,
    missingBuffIconEnabled = false,
    missingBuffIconFrameLevel = 0,
    missingBuffIconScale = 1.2000000476837,
    missingBuffIconShowBorder = true,
    missingBuffIconSize = 24,
    missingBuffIconX = 0,
    missingBuffIconY = 0,

    -- My Buff Indicator (DEPRECATED — hidden from UI, force-disabled on load)
    myBuffIndicatorAnimate = false,
    myBuffIndicatorBorderAlpha = 0.8,
    myBuffIndicatorBorderInset = -1,
    myBuffIndicatorBorderSize = 3,
    myBuffIndicatorColor = {r = 0, g = 1, b = 0},
    myBuffIndicatorEnabled = false,
    myBuffIndicatorGradientAlpha = 0.4000000059604645,
    myBuffIndicatorGradientOnCurrentHealth = true,
    myBuffIndicatorGradientSize = 0.5,
    myBuffIndicatorGradientStyle = "EDGE",
    myBuffIndicatorShowBorder = false,
    myBuffIndicatorShowGradient = true,

    -- Name Text
    nameColorClass = false,
    nameFont = "DF Roboto SemiBold",
    nameFontSize = 11,
    nameTextAnchor = "TOP",
    nameTextColor = {r = 1, g = 1, b = 1, a = 1},
    nameTextLength = 13,
    nameTextOutline = "SHADOW",
    nameTextTruncateMode = "ELLIPSIS",
    nameTextUseClassColor = false,
    nameTextX = 0,
    nameTextY = -10,

    -- Out of Range
    oorAbsorbBarAlpha = 0.20000000298023,
    oorAurasAlpha = 0.20000000298023,
    oorBackgroundAlpha = 0.10000000149012,
    oorDefensiveIconAlpha = 0.5,
    oorDispelOverlayAlpha = 0.20000000298023,
    oorEnabled = false,
    oorHealthBarAlpha = 0.20000000298023,
    oorHealthTextAlpha = 0.25,
    oorIconsAlpha = 0.5,
    oorMissingBuffAlpha = 0.5,
    oorMissingHealthAlpha = 0.20000000298023,
    oorMyBuffIndicatorAlpha = 0,
    oorNameTextAlpha = 1,
    oorPowerBarAlpha = 0.20000000298023,
    oorTargetedSpellAlpha = 0.5,
    oorAuraDesignerAlpha = 0.20000000298023,

    -- Personal Targeted Spells (Nameplate)
    personalTargetedSpellAlpha = 1,
    personalTargetedSpellBorderColor = {r = 1, g = 0.3, b = 0},
    personalTargetedSpellBorderSize = 2,
    personalTargetedSpellDurationColor = {r = 1, g = 1, b = 1},
    personalTargetedSpellDurationFont = "DF Roboto SemiBold",
    personalTargetedSpellDurationOutline = "SHADOW",
    personalTargetedSpellDurationScale = 1.2,
    personalTargetedSpellDurationX = 0,
    personalTargetedSpellDurationY = 0,
    personalTargetedSpellEnabled = false,
    personalTargetedSpellGrowth = "RIGHT",
    personalTargetedSpellHighlightColor = {r = 1, g = 0.8, b = 0},
    personalTargetedSpellHighlightImportant = true,
    personalTargetedSpellHighlightInset = 0,
    personalTargetedSpellHighlightSize = 3,
    personalTargetedSpellHighlightStyle = "glow",
    personalTargetedSpellImportantOnly = false,
    personalTargetedSpellInArena = true,
    personalTargetedSpellInBattlegrounds = true,
    personalTargetedSpellInDungeons = true,
    personalTargetedSpellInOpenWorld = true,
    personalTargetedSpellInRaids = true,
    personalTargetedSpellInterruptedDuration = 0.5,
    personalTargetedSpellInterruptedShowX = true,
    personalTargetedSpellInterruptedTintAlpha = 0.5,
    personalTargetedSpellInterruptedTintColor = {r = 1, g = 0, b = 0},
    personalTargetedSpellInterruptedXColor = {r = 1, g = 0, b = 0},
    personalTargetedSpellInterruptedXSize = 20,
    personalTargetedSpellMaxIcons = 5,
    personalTargetedSpellScale = 1,
    personalTargetedSpellShowBorder = true,
    personalTargetedSpellShowDuration = true,
    personalTargetedSpellShowInterrupted = true,
    personalTargetedSpellShowSwipe = true,
    personalTargetedSpellSize = 40,
    personalTargetedSpellSpacing = 4,
    personalTargetedSpellX = 0,
    personalTargetedSpellY = -150,

    -- Pet Frames
    petAnchor = "BOTTOM",
    petBackgroundColor = {r = 0.9254902601242065, g = 0.9254902601242065, b = 0.9254902601242065, a = 0.800000011920929},
    petBorderColor = {r = 0, g = 0, b = 0, a = 1},
    petEnabled = false,
    petFrameHeight = 22,
    petFrameWidth = 130,
    petGroupAnchor = "BOTTOM",
    petGroupGrowth = "HORIZONTAL",
    petGroupLabel = "Pets",
    petGroupMode = "ATTACHED",
    petGroupOffsetX = 5,
    petGroupOffsetY = -10,
    petGroupShowLabel = true,
    petGroupSpacing = 2,
    petHealthAnchor = "RIGHT",
    petHealthBgColor = {r = 0.2, g = 0.2, b = 0.2, a = 0.8},
    petHealthColor = {r = 0, g = 0, b = 0, a = 1},
    petHealthColorMode = "CUSTOM",
    petHealthFont = "DF Roboto SemiBold",
    petHealthFontOutline = "SHADOW",
    petHealthFontSize = 7,
    petHealthTextColor = {r = 1, g = 1, b = 1},
    petHealthX = -2,
    petHealthY = 0,
    petMatchOwnerHeight = false,
    petMatchOwnerWidth = true,
    petNameAnchor = "CENTER",
    petNameColor = {r = 1, g = 1, b = 1},
    petNameFont = "DF Roboto SemiBold",
    petNameFontOutline = "SHADOW",
    petNameFontSize = 8,
    petNameMaxLength = 8,
    petNameX = 0,
    petNameY = 0,
    petOffsetX = 0,
    petOffsetY = -1,
    petShowBorder = false,
    petShowHealthText = true,
    petTexture = "Interface\\TargetingFrame\\UI-StatusBar",

    -- Phased Icon
    phasedIconAlpha = 1,
    phasedIconAnchor = "CENTER",
    phasedIconEnabled = true,
    phasedIconFrameLevel = 0,
    phasedIconHideInCombat = true,
    phasedIconScale = 1.5,
    phasedIconShowLFGEye = true,
    phasedIconShowText = false,
    phasedIconText = "Phased",
    phasedIconTextColor = {r = 0.5, g = 0.5, b = 1},
    phasedIconX = 0,
    phasedIconY = 0,

    -- Power Bar
    powerBarHeight = 4,
    showPowerBar = false,

    -- Raid Layout
    raidAnchorX = -6.666610717773438,
    raidAnchorY = -25,
    raidEnabled = true,
    raidFlatColumnAnchor = "START",
    raidFlatFrameAnchor = "START",
    raidFlatGrowthAnchor = "TOPLEFT",
    raidFlatHorizontalSpacing = 2,
    raidFlatPlayerAnchor = "CENTER",
    raidFlatReverseFillOrder = false,
    raidFlatVerticalSpacing = 2,
    raidGroupAnchor = "CENTER",
    raidGroupDisplayOrder = {1, 2, 3, 4, 5, 6, 7, 8},
    raidGroupOrder = "NORMAL",
    raidGroupRowGrowth = "START",
    raidGroupSpacing = -1,
    raidGroupVisible = {true, true, true, true, true, true, true, true},
    raidGroupsPerRow = 8,
    raidLocked = true,
    raidPlayerAnchor = "START",
    raidPlayersPerRow = 5,
    raidRoleIconAlpha = 1,
    raidRoleIconAnchor = "BOTTOMLEFT",
    raidRoleIconEnabled = false,
    raidRoleIconFrameLevel = 0,
    raidRoleIconHideInCombat = true,
    raidRoleIconScale = 1.400000095367432,
    raidRoleIconShowAssist = true,
    raidRoleIconShowTank = true,
    raidRoleIconShowText = true,
    raidRoleIconTextAssist = "MA",
    raidRoleIconTextColor = {r = 1, g = 1, b = 0},
    raidRoleIconTextTank = "MT",
    raidRoleIconX = 5,
    raidRoleIconY = 3,
    raidRowColSpacing = 30,
    raidTargetIconAlpha = 1,
    raidTargetIconAnchor = "TOP",
    raidTargetIconEnabled = true,
    raidTargetIconFrameLevel = 0,
    raidTargetIconHide = false,
    raidTargetIconHideInCombat = false,
    raidTargetIconScale = 1.1000000238419,
    raidTargetIconX = 36,
    raidTargetIconY = 5,
    raidTestFrameCount = 40,
    raidUseGroups = true,

    -- Range Check
    rangeAlpha = 0.5,
    rangeCheckEnabled = true,
    rangeCheckSpellID = 0,
    rangeFadeAlpha = 0.40000000596046,
    rangeUpdateInterval = 0.5,

    -- Ready Check Icon
    readyCheckIconAlpha = 1,
    readyCheckIconAnchor = "CENTER",
    readyCheckIconEnabled = true,
    readyCheckIconFrameLevel = 0,
    readyCheckIconHide = false,
    readyCheckIconHideInCombat = false,
    readyCheckIconPersist = 6,
    readyCheckIconScale = 1.6000000238419,
    readyCheckIconX = 0,
    readyCheckIconY = 0,

    -- Resource Bar
    resourceBarAnchor = "BOTTOM",
    resourceBarBackgroundColor = {r = 0, g = 0, b = 0, a = 0.80000001192093},
    resourceBarBackgroundEnabled = true,
    resourceBarBorderColor = {r = 0, g = 0, b = 0, a = 1},
    resourceBarBorderEnabled = false,
    resourceBarClassFilter = {
        DEATHKNIGHT = true,
        DEMONHUNTER = true,
        DRUID = true,
        EVOKER = true,
        HUNTER = true,
        MAGE = true,
        MONK = true,
        PALADIN = true,
        PRIEST = true,
        ROGUE = true,
        SHAMAN = true,
        WARLOCK = true,
        WARRIOR = true,
    },
    resourceBarClassColor = false,
    resourceBarEnabled = true,
    resourceBarFrameLevel = 20,
    resourceBarHeight = 4,
    resourceBarMatchWidth = true,
    resourceBarOrientation = "HORIZONTAL",
    resourceBarReverseFill = false,
    resourceBarShowDPS = false,
    resourceBarShowHealer = true,
    resourceBarShowInSoloMode = true,
    resourceBarShowTank = false,
    resourceBarSmooth = true,
    resourceBarWidth = 60,
    resourceBarX = 0,
    resourceBarY = 0,

    -- Class Power (Holy Power, Chi, Combo Points, etc. - player frame only)
    classPowerEnabled = false,
    classPowerHeight = 4,
    classPowerGap = 1,
    classPowerAnchor = "INSIDE_BOTTOM",
    classPowerX = 0,
    classPowerY = -1,
    classPowerIgnoreFade = true,
    classPowerUseCustomColor = false,
    classPowerColor = {r = 1, g = 0.82, b = 0, a = 1},
    classPowerBgColor = {r = 0.15, g = 0.15, b = 0.15, a = 0.4},
    classPowerShowTank = true,
    classPowerShowHealer = true,
    classPowerShowDamager = true,

    -- Rested Indicator
    restedIndicator = false,
    restedIndicatorAnchor = "TOPRIGHT",
    restedIndicatorGlow = false,
    restedIndicatorIcon = true,
    restedIndicatorOffsetX = -18,
    restedIndicatorOffsetY = -14,
    restedIndicatorSize = 20,

    -- Resurrection Icon
    resurrectionIconAlpha = 1,
    resurrectionIconAnchor = "CENTER",
    resurrectionIconEnabled = true,
    resurrectionIconFrameLevel = 0,
    resurrectionIconHideInCombat = false,
    resurrectionIconScale = 1.600000023841858,
    resurrectionIconShowText = false,
    resurrectionIconTextCasting = "Res...",
    resurrectionIconTextColor = {r = 0.2, g = 1, b = 0.2},
    resurrectionIconTextPending = "Res Ready",
    resurrectionIconX = 0,
    resurrectionIconY = 0,

    -- Role Icon
    roleIconAlpha = 1,
    roleIconAnchor = "TOPLEFT",
    roleIconFrameLevel = 0,
    roleIconHide = false,
    roleIconHideDPS = true,
    roleIconHideHealer = false,
    roleIconHideOnlyInCombat = true,
    roleIconHideTank = true,
    roleIconExternalDPS = "",
    roleIconExternalHealer = "",
    roleIconExternalTank = "",
    roleIconOnlyInCombat = false,
    roleIconScale = 1,
    roleIconShowDPS = true,
    roleIconShowHealer = true,
    roleIconShowTank = true,
    roleIconStyle = "CUSTOM",
    roleIconX = 2,
    roleIconY = -2,
    showRoleIcon = true,

    -- Selection Highlight
    selectionHighlightAlpha = 1,
    selectionHighlightColor = {r = 1, g = 1, b = 1, a = 1},
    selectionHighlightInset = 0,
    selectionHighlightMode = "SOLID",
    selectionHighlightThickness = 1,

    -- Smooth Bars & Solo Mode
    smoothBars = true,
    soloMode = true,

    -- Sorting
    sortAlphabetical = false,
    sortByClass = false,
    sortClassOrder = {
        "DEATHKNIGHT",
        "DEMONHUNTER",
        "DRUID",
        "EVOKER",
        "HUNTER",
        "MAGE",
        "MONK",
        "PALADIN",
        "PRIEST",
        "SHAMAN",
        "ROGUE",
        "WARLOCK",
        "WARRIOR",
    },
    sortEnabled = true,
    sortRoleOrder = {"TANK", "HEALER", "MELEE", "RANGED"},
    sortSelfPosition = "SORTED",
    sortSeparateMeleeRanged = false,
    useFrameSort = false,

    -- Status Icon & Text
    statusIconFont = "DF Roboto SemiBold",
    statusIconFontOutline = "SHADOW",
    statusIconFontSize = 11,
    statusTextAnchor = "CENTER",
    statusTextColor = {r = 1, g = 1, b = 1, a = 1},
    statusTextEnabled = true,
    statusTextFont = "DF Roboto SemiBold",
    statusTextFontSize = 14,
    statusTextOutline = "SHADOW",
    statusTextX = 0,
    statusTextY = 0,

    -- Summon Icon
    summonIconAlpha = 1,
    summonIconAnchor = "BOTTOM",
    summonIconEnabled = true,
    summonIconFrameLevel = 0,
    summonIconHideInCombat = false,
    summonIconScale = 1.5,
    summonIconShowText = true,
    summonIconTextAccepted = "Accepted",
    summonIconTextColor = {r = 0.6, g = 0.2, b = 1},
    summonIconTextDeclined = "Declined",
    summonIconTextPending = "Summon",
    summonIconX = 0,
    summonIconY = 9,

    -- Targeted Spells (on-frame)
    targetedSpellAlpha = 1,
    targetedSpellAnchor = "BOTTOM",
    targetedSpellBorderColor = {r = 1, g = 0.3, b = 0},
    targetedSpellBorderSize = 2,
    targetedSpellDisableMouse = false,
    targetedSpellDurationColor = {r = 1, g = 1, b = 1},
    targetedSpellDurationColorByTime = false,
    targetedSpellDurationFont = "DF Roboto SemiBold",
    targetedSpellDurationOutline = "SHADOW",
    targetedSpellDurationScale = 1,
    targetedSpellDurationX = 0,
    targetedSpellDurationY = 0,
    targetedSpellEnabled = false,
    targetedSpellFrameLevel = 0,
    targetedSpellGrowth = "CENTER_H",
    targetedSpellHideSwipe = false,
    targetedSpellHighlightColor = {r = 1, g = 0.8, b = 0},
    targetedSpellHighlightImportant = true,
    targetedSpellHighlightInset = 2,
    targetedSpellHighlightSize = 3,
    targetedSpellHighlightStyle = "glow",
    targetedSpellImportantOnly = false,
    targetedSpellInArena = true,
    targetedSpellInBattlegrounds = true,
    targetedSpellInDungeons = true,
    targetedSpellInOpenWorld = true,
    targetedSpellInRaids = true,
    targetedSpellInterruptedDuration = 0.5,
    targetedSpellInterruptedShowX = true,
    targetedSpellInterruptedTintAlpha = 0.5,
    targetedSpellInterruptedTintColor = {r = 1, g = 0, b = 0},
    targetedSpellInterruptedXColor = {r = 1, g = 0, b = 0},
    targetedSpellInterruptedXSize = 16,
    targetedSpellMaxIcons = 3,
    targetedSpellNameplateOffscreen = false,
    targetedSpellScale = 1,
    targetedSpellShowBorder = true,
    targetedSpellShowDuration = true,
    targetedSpellShowInterrupted = true,
    targetedSpellShowSwipe = true,
    targetedSpellSize = 24,
    targetedSpellSortByTime = true,
    targetedSpellSortNewestFirst = true,
    targetedSpellSpacing = 2,
    targetedSpellX = 0,
    targetedSpellY = -28,

    -- Test Mode
    testAnimateHealth = false,
    testBossDebuffCount = 1,
    testBuffCount = 2,
    testDebuffCount = 2,
    testFrameCount = 5,
    testPreset = "STATIC",
    testShowAbsorbs = false,
    testShowAggro = false,
    testShowAuras = false,
    testShowBossDebuffs = false,
    testShowDispelGlow = false,
    testShowExternalDef = false,
    testShowHealPrediction = false,
    testShowIcons = true,
    testShowMissingBuff = false,
    testShowMyBuffIndicator = false,
    testShowOutOfRange = false,
    testShowPets = true,
    testShowSelection = false,
    testShowStatusIcons = false,
    testShowTargetedSpell = false,
    testShowClassPower = true,
    testShowAuraDesigner = false,

    -- Tooltip settings
    tooltipAuraAnchor = "DEFAULT",
    tooltipAuraDisableInCombat = false,
    tooltipAuraEnabled = true,
    tooltipAuraX = 0,
    tooltipAuraY = 0,
    tooltipBuffAnchor = "FRAME",
    tooltipBuffAnchorPos = "BOTTOMRIGHT",
    tooltipBuffDisableInCombat = true,
    tooltipBuffEnabled = true,
    tooltipBuffX = 0,
    tooltipBuffY = -10,
    tooltipDebuffAnchor = "FRAME",
    tooltipDebuffAnchorPos = "BOTTOMLEFT",
    tooltipDebuffDisableInCombat = false,
    tooltipDebuffEnabled = true,
    tooltipDebuffX = 0,
    tooltipDebuffY = -10,
    tooltipDefensiveAnchor = "CURSOR",
    tooltipDefensiveAnchorPos = "BOTTOMRIGHT",
    tooltipDefensiveDisableInCombat = false,
    tooltipDefensiveEnabled = true,
    tooltipResurrectionEnabled = false,
    tooltipDefensiveX = 0,
    tooltipDefensiveY = 0,
    tooltipBindingAnchor = "FRAME",
    tooltipBindingAnchorPos = "TOPRIGHT",
    tooltipBindingDisableInCombat = false,
    tooltipBindingEnabled = false,
    tooltipBindingX = 4,
    tooltipBindingY = 0,
    tooltipFrameAnchor = "DEFAULT",
    tooltipFrameAnchorPos = "BOTTOMRIGHT",
    tooltipFrameDisableInCombat = true,
    tooltipFrameEnabled = true,
    tooltipFrameX = 0,
    tooltipFrameY = 0,

    -- Secure Headers
    useSecureHeaders = true,

    -- Vehicle Icon
    vehicleIconAlpha = 1,
    vehicleIconAnchor = "BOTTOMRIGHT",
    vehicleIconEnabled = true,
    vehicleIconFrameLevel = 0,
    vehicleIconHideInCombat = false,
    vehicleIconScale = 1.5,
    vehicleIconShowText = true,
    vehicleIconText = "Vehicle",
    vehicleIconTextColor = {r = 0.4, g = 0.8, b = 1},
    vehicleIconX = -12,
    vehicleIconY = 1,

    -- Pinned Frames
    pinnedFrames = {
        sets = {
            [1] = {
                enabled = false,
                frameType = "player",
                testCount = 3,
                name = "Pinned 1",
                players = {},
                growDirection = "HORIZONTAL",
                unitsPerRow = 5,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = 200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
            [2] = {
                enabled = false,
                frameType = "player",
                testCount = 3,
                name = "Pinned 2",
                players = {},
                growDirection = "HORIZONTAL",
                unitsPerRow = 5,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = -200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
        },
    },

    -- Highlight Frames
    highlightFrames = {
        sets = {
            [1] = {
                enabled = false,
                name = "Highlight 1",
                players = {},
                growDirection = "VERTICAL",
                unitsPerRow = 2,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = 200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
            [2] = {
                enabled = false,
                name = "Highlight 2",
                players = {},
                growDirection = "HORIZONTAL",
                unitsPerRow = 5,
                horizontalSpacing = 2,
                verticalSpacing = 2,
                scale = 1.0,
                position = { point = "CENTER", x = 0, y = -200 },
                locked = false,
                showLabel = false,
                columnAnchor = "START",
                frameAnchor = "START",
                autoAddTanks = false,
                autoAddHealers = false,
                autoAddDPS = false,
                keepOfflinePlayers = false,
                manualPlayers = {},
            },
        },
    },

    -- Aura Designer
    auraDesigner = {
        enabled = false,
        spec = "auto",
        previewScale = 1.0,
        soundEnabled = true,
        defaults = {
            iconSize = 24,
            iconScale = 1.0,
            showDuration = true,
            showStacks = true,
            durationFont = "Friz Quadrata TT",
            durationScale = 1.0,
            durationOutline = "OUTLINE",
            durationAnchor = "CENTER",
            durationX = 0,
            durationY = 0,
            stackFont = "Friz Quadrata TT",
            stackScale = 1.0,
            stackOutline = "OUTLINE",
            stackAnchor = "BOTTOMRIGHT",
            stackX = 0,
            stackY = 0,
            iconBorderEnabled = true,
            iconBorderThickness = 1,
            stackMinimum = 2,
            durationColorByTime = false,
            durationColor = {r = 1, g = 1, b = 1, a = 1},
            stackColor = {r = 1, g = 1, b = 1, a = 1},
            hideIcon = false,
            indicatorFrameLevel = 30,
            indicatorFrameStrata = "INHERIT",
        },
        auras = {},
        layoutGroups = {},
        nextLayoutGroupID = 1,
    },

}

-- ============================================================
-- RAID AUTO PROFILES DEFAULTS
-- ============================================================
-- Auto profiles allow automatic switching of raid frame settings
-- based on content type (instanced, open world, mythic) and raid size

DF.RaidAutoProfilesDefaults = {
    enabled = false,  -- Master enable for auto profiles feature
    
    -- Instanced/PvP content (raids, dungeons, battlegrounds, arenas)
    -- Range: 1-40 players
    instanced = {
        profiles = {}  -- Array of profiles: {name, min, max, overrides = {}}
    },
    
    -- Open World content (world bosses, outdoor groups)
    -- Range: 1-40 players
    openWorld = {
        profiles = {}  -- Array of profiles: {name, min, max, overrides = {}}
    },
    
    -- Mythic raiding (difficulty ID 16)
    -- Fixed at 20 players, no range needed
    mythic = {
        profile = nil  -- Single profile: {name = "Mythic Setup", overrides = {}} or nil if not configured
    },
}

function DF:GetGlobalDB()
    DandersFramesDB_v2 = DandersFramesDB_v2 or {}
    DandersFramesDB_v2.global = DandersFramesDB_v2.global or {}
    for k, v in pairs(DF.GlobalDefaults) do
        if DandersFramesDB_v2.global[k] == nil then
            DandersFramesDB_v2.global[k] = v
        end
    end
    return DandersFramesDB_v2.global
end
