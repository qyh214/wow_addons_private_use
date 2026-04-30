local addonName, DF = ...

DF.GUI = DF.GUI or {}

-- ============================================================
-- DF FONT OBJECT SYSTEM
-- ------------------------------------------------------------
-- Creates a DF-prefixed font object for every Blizzard GameFont*
-- template the addon's settings UI relies on. At load these are
-- exact copies of their Blizzard equivalents so the panel looks
-- identical. GUI:ApplySettingsFont() rewrites them using the
-- multi-alphabet family system in Config.lua, so a single user
-- setting re-skins the entire settings panel AND every FontString
-- inheriting from a DFFont automatically gains the roman/korean/
-- chinese/russian fallback family — fixing Cyrillic squares for
-- every widget that uses DFFont*.
-- ============================================================

-- Cache globals
local CreateFont = CreateFont
local _G = _G

local DEFAULT_FONT_SIZE = 10

-- The Blizzard templates the settings UI uses (see the font audit).
-- Order does not matter; this is just the source-of-truth list.
local TEMPLATES = {
    "GameFontHighlightSmall",        -- small white body text (most common)
    "GameFontHighlight",             -- white body text
    "GameFontNormal",                -- yellow header text
    "GameFontNormalSmall",           -- small yellow button text
    "GameFontNormalLarge",           -- large yellow title text
    "GameFontNormalHuge",            -- one-off oversized header
    "GameFontHighlightSmallOutline", -- small white with outline
    "GameFontDisableSmall",          -- greyed-out small hint text
    "GameFontDisable",               -- greyed-out normal hint text
}

-- Registry of DFFont objects (DFFont<suffix> = font object)
DF.DFFontObjects = DF.DFFontObjects or {}

-- Create one DFFont<Suffix> object per template, copying the
-- Blizzard template as-is. The per-template colour/size/outline
-- is preserved; only the font file can be swapped later.
local function CreateDFFontObjects()
    for _, templateName in ipairs(TEMPLATES) do
        local suffix = templateName:gsub("^Game", "")   -- "FontHighlightSmall" etc.
        local dfName = "DF" .. suffix                   -- "DFFontHighlightSmall"

        if not _G[dfName] then
            local blizzFont = _G[templateName]
            if blizzFont then
                local dfFont = CreateFont(dfName)
                dfFont:CopyFontObject(blizzFont)
                DF.DFFontObjects[dfName] = dfFont
            end
        else
            DF.DFFontObjects[dfName] = _G[dfName]
        end
    end
end

CreateDFFontObjects()

-- ============================================================
-- APPLY / REFRESH
-- Apply the user's chosen settings font to all DFFont objects,
-- and force visible settings FontStrings to re-render.
-- ============================================================

-- Apply the user's chosen settings font + outline to every DF
-- font object. Called once at load (after DB is ready) and on
-- any subsequent change via GUI:RefreshSettingsFont().
--
-- Implementation: for each DFFont object, read its current size
-- (from the Blizzard copy), then use CreateFontFamily via the
-- existing DF:SafeSetFont path so multi-alphabet fallbacks work.
-- We call SetFont directly on the DFFont object using the
-- resolved family path so inheritance propagates to all
-- FontStrings that use it.
function DF.GUI:ApplySettingsFont()
    if not DF.db then return end

    local fontName = DF.db.settingsFont or "Friz Quadrata TT"
    local outline  = DF.db.settingsFontOutline or ""
    if outline == "NONE" then outline = "" end

    local fontPath = DF:GetFontPath(fontName)
    -- Fallback to Blizzard's locale-aware font if LSM lookup fails
    if not fontPath then
        fontPath = "Fonts\\FRIZQT__.TTF"
    end

    for _, templateName in ipairs(TEMPLATES) do
        local suffix = templateName:gsub("^Game", "")
        local dfName = "DF" .. suffix
        local dfFont = DF.DFFontObjects[dfName]
        if dfFont then
            -- Preserve the template's existing size (different templates
            -- have different sizes — Small vs Normal vs Large).
            local _, size = dfFont:GetFont()
            size = size or DEFAULT_FONT_SIZE
            -- The user's outline choice is absolute: "None" means no outline
            -- on every DFFont, including templates that originally had an
            -- outline (e.g. GameFontHighlightSmallOutline). Users expect
            -- the dropdown to directly control the outline state.
            pcall(function()
                dfFont:SetFont(fontPath, size, outline)
            end)
        end
    end
end

-- ============================================================
-- INLINE FONT TRACKER
-- For settings-UI widgets that need explicit size/outline control
-- (e.g. custom-sized button text, small status labels) the addon
-- historically called fontString:SetFont("Fonts\\FRIZQT__.TTF",
-- size, outline) directly. That bypasses any template inheritance,
-- so the Settings Font dropdown cannot affect them. SetSettingsFont
-- replaces those calls: it applies the user's current settings font
-- with the given size/outline, AND registers the FontString so
-- RefreshSettingsFont can re-apply the new font later.
-- ============================================================

-- List of {fontString, size, outline} tuples to re-apply on refresh.
-- Entries with a garbage-collected FontString become nil and are
-- skipped naturally.
DF.GUI._settingsFontStrings = DF.GUI._settingsFontStrings or {}

-- Apply the user's settings font to a FontString with the given
-- size and outline, then register it for future refreshes.
--
-- `outline` semantics: if nil, the user's Settings Font Outline
-- choice wins (so the widget follows whatever the user picked).
-- If explicit (e.g. "OUTLINE"), it is respected as the minimum
-- outline — useful for widgets like drag-hint text that need an
-- outline regardless of user preference.
function DF.GUI:SetSettingsFont(fontString, size, outline)
    if not fontString then return end

    size = size or DEFAULT_FONT_SIZE
    local explicitOutline = outline  -- nil means "follow user"

    local fontName = (DF.db and DF.db.settingsFont) or "Friz Quadrata TT"
    local userOutline = (DF.db and DF.db.settingsFontOutline) or ""
    if userOutline == "NONE" then userOutline = "" end

    local flagsToUse = explicitOutline or userOutline

    -- SafeSetFont uses CreateFontFamily + SetTextScale which is only
    -- available on FontString objects. EditBoxes inherit from FontInstance
    -- (GetFont/SetFont work) but lack SetTextScale, so for them we use a
    -- direct SetFont via the resolved path — no multi-alphabet family, but
    -- also no crash. EditBox text is almost always user-typed ASCII anyway.
    local isFontString = fontString.GetObjectType and fontString:GetObjectType() == "FontString"

    if isFontString and DF.SafeSetFont then
        DF:SafeSetFont(fontString, fontName, size, flagsToUse)
    else
        local fontPath = DF.GetFontPath and DF:GetFontPath(fontName) or "Fonts\\FRIZQT__.TTF"
        pcall(function() fontString:SetFont(fontPath, size, flagsToUse) end)
    end

    -- Register for future refreshes (only once per fontString)
    local registry = self._settingsFontStrings
    for _, entry in ipairs(registry) do
        if entry.fs == fontString then
            entry.size = size
            entry.outline = explicitOutline
            return
        end
    end
    registry[#registry + 1] = { fs = fontString, size = size, outline = explicitOutline }
end

-- ============================================================
-- REFRESH
-- Called by the settings font/outline dropdown callbacks.
-- Re-applies the user's font to every registered FontString (the
-- inline-SetFont widgets) and nudges every FontString across every
-- settings page so template-inherited widgets re-render immediately.
-- ============================================================
function DF.GUI:RefreshSettingsFont()
    self:ApplySettingsFont()

    -- Re-apply settings font to every registered inline-SetFont FontString
    local registry = self._settingsFontStrings
    if registry then
        for i = #registry, 1, -1 do
            local entry = registry[i]
            local fs = entry and entry.fs
            if fs and fs.GetObjectType then
                -- Re-apply with the same explicit outline semantics
                self:SetSettingsFont(fs, entry.size, entry.outline)
            else
                -- FontString was garbage-collected; drop the entry
                table.remove(registry, i)
            end
        end
    end

    -- Force FontStrings to re-evaluate their inherited font.
    -- Setting the same text back forces a layout pass.
    if self.Pages then
        for _, page in pairs(self.Pages) do
            if page.child then
                local function nudge(frame)
                    if not frame then return end
                    local objType = frame.GetObjectType and frame:GetObjectType()
                    if objType == "FontString" then
                        local t = frame:GetText()
                        if t and t ~= "" then
                            frame:SetText("")
                            frame:SetText(t)
                        end
                        return  -- FontStrings are leaf nodes; no children or sub-regions
                    end
                    -- Only Frames have GetChildren / GetRegions
                    if frame.GetChildren then
                        for _, child in ipairs({frame:GetChildren()}) do
                            nudge(child)
                        end
                    end
                    if frame.GetRegions then
                        for _, region in ipairs({frame:GetRegions()}) do
                            nudge(region)
                        end
                    end
                end
                nudge(page.child)
            end
        end
    end
end
