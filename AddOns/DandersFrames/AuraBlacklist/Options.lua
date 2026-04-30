local addonName, DF = ...

-- ============================================================
-- AURA BLACKLIST - OPTIONS GUI
-- Single-list UI for blacklisting buffs and debuffs.
-- Called from Options/Options.lua via DF.BuildAuraBlacklistPage()
-- ============================================================

local pairs, ipairs = pairs, ipairs
local format = string.format
local tinsert = table.insert
local wipe = wipe
local CreateFrame = CreateFrame

local L = DF.L

-- ============================================================
-- MAIN PAGE BUILD
-- ============================================================

function DF.BuildAuraBlacklistPage(guiRef, pageRef, dbRef)
    -- Build frames once; subsequent calls just refresh widget data
    if pageRef._auraBlacklistBuilt then
        if pageRef._buffWidget then pageRef._buffWidget:Refresh() end
        if pageRef._debuffWidget then pageRef._debuffWidget:Refresh() end
        if pageRef._updateDropdownText then pageRef._updateDropdownText() end
        return
    end
    pageRef._auraBlacklistBuilt = true

    local GUI = guiRef
    local page = pageRef
    local parent = page.child

    -- ========== THEME ==========
    local function GetThemeColor()
        return GUI.GetThemeColor and GUI.GetThemeColor() or {r = 0.90, g = 0.55, b = 0.15}
    end

    -- ========== STATE ==========
    local selectedClass = "AUTO"

    -- Reusable frame pools
    local buffItemPool = {}
    local debuffItemPool = {}

    -- ========== BLACKLIST ACCESS ==========
    local function GetBlacklist()
        return DF.db and DF.db.auraBlacklist or { buffs = {}, debuffs = {} }
    end

    -- ========== DETECT PLAYER CLASS ==========
    local function GetPlayerClass()
        local _, classToken = UnitClass("player")
        return classToken
    end

    -- ========== RESOLVE SELECTED CLASS ==========
    local function ResolveClass()
        if selectedClass == "AUTO" then
            return GetPlayerClass()
        end
        return selectedClass
    end

    -- ========== GET ALL BUFFS FOR CLASS ==========
    local function GetAllBuffs()
        local class = ResolveClass()
        local spells = DF.AuraBlacklist and DF.AuraBlacklist.BuffSpells and DF.AuraBlacklist.BuffSpells[class]
        if not spells then return {} end
        return spells
    end

    -- ========== GET ALL DEBUFFS ==========
    local function GetAllDebuffs()
        local spells = DF.AuraBlacklist and DF.AuraBlacklist.DebuffSpells
        if not spells then return {} end
        return spells
    end

    -- ========== NOTIFY AURA SYSTEM ==========
    local function NotifyBlacklistChanged()
        -- Refresh all visible frames to re-filter auras
        if DF.RefreshAllVisibleFrames then
            DF:RefreshAllVisibleFrames()
        end
    end

    -- ========== MINI CHECKBOX HELPER ==========
    local function CreateMiniCheckbox(parentFrame, label, checked, onChange)
        local tc = GetThemeColor()
        local cb = CreateFrame("Button", nil, parentFrame)
        cb:SetSize(12, 12)

        -- Dark inset background
        local bg = cb:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.06, 0.06, 0.06, 1)

        -- Subtle border
        local border = cb:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(0.30, 0.30, 0.30, 1)

        -- Theme-colored fill when checked
        local fill = cb:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMRIGHT", -2, 2)
        fill:SetColorTexture(tc.r, tc.g, tc.b, 0.9)
        fill:SetShown(checked)

        -- Label text
        local text = cb:CreateFontString(nil, "OVERLAY")
        GUI:SetSettingsFont(text, 8, "")
        text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        text:SetText(label)
        text:SetTextColor(0.55, 0.55, 0.55)

        cb:SetScript("OnClick", function()
            local newState = not fill:IsShown()
            fill:SetShown(newState)
            onChange(newState)
        end)
        cb:SetScript("OnEnter", function()
            border:SetColorTexture(tc.r * 0.6, tc.g * 0.6, tc.b * 0.6, 1)
            text:SetTextColor(0.80, 0.80, 0.80)
        end)
        cb:SetScript("OnLeave", function()
            border:SetColorTexture(0.30, 0.30, 0.30, 1)
            text:SetTextColor(0.55, 0.55, 0.55)
        end)

        cb._check = fill
        return cb
    end

    -- ========== SPELL ROW (unified list item) ==========
    local function CreateSpellRow(scrollContent, spell, index, rowHeight, blacklistKey, refreshFn)
        local tc = GetThemeColor()
        local bl = GetBlacklist()
        local entry = bl[blacklistKey] and bl[blacklistKey][spell.spellId]
        local isBlacklisted = entry ~= nil

        local row = CreateFrame("Button", nil, scrollContent, "BackdropTemplate")
        row:SetHeight(rowHeight - 1)
        row:SetPoint("TOPLEFT", 0, -((index - 1) * rowHeight))
        row:SetPoint("TOPRIGHT", 0, -((index - 1) * rowHeight))
        row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
        row:EnableMouse(true)

        -- Background color based on state
        if isBlacklisted then
            row:SetBackdropColor(0.14, 0.14, 0.14, 0.95)
        else
            row:SetBackdropColor(0.08, 0.08, 0.08, 0.6)
        end

        -- Left accent bar (theme-colored, only for blacklisted)
        local accent = row:CreateTexture(nil, "ARTWORK")
        accent:SetSize(3, rowHeight - 5)
        accent:SetPoint("LEFT", 2, 0)
        accent:SetColorTexture(tc.r, tc.g, tc.b, 1)
        accent:SetShown(isBlacklisted)

        -- Spell icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(18, 18)
        icon:SetPoint("LEFT", 10, 0)
        icon:SetTexture(spell.icon or 134400)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        if not isBlacklisted then
            icon:SetAlpha(0.5)
        end

        -- Spell name
        local nameText = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        nameText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        nameText:SetPoint("RIGHT", -160, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetText(spell.display)
        if isBlacklisted then
            nameText:SetTextColor(0.90, 0.90, 0.90)
        else
            nameText:SetTextColor(0.55, 0.55, 0.55)
        end

        -- Warning icon for spells with known limitations
        if spell.spellId == 474754 then  -- Symbiotic Relationship
            local warnIcon = CreateFrame("Button", nil, row)
            warnIcon:SetSize(18, 18)
            warnIcon:SetPoint("LEFT", nameText, "RIGHT", 4, 0)
            local warnTex = warnIcon:CreateTexture(nil, "OVERLAY")
            warnTex:SetAllPoints()
            warnTex:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\warning")
            warnIcon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Symbiotic Relationship"], 1, 0.82, 0)
                GameTooltip:AddLine(L["Only the aura on the caster can be blacklisted. The aura on the target cannot be blacklisted due to Blizzard limitations."], 1, 1, 1, true)
                GameTooltip:Show()
            end)
            warnIcon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end

        -- Checkboxes (always visible — checked state reflects blacklist)
        local combatChecked = isBlacklisted and type(entry) == "table" and entry.combat or false
        local oocChecked = isBlacklisted and type(entry) == "table" and entry.ooc or false

        local combatCB = CreateMiniCheckbox(row, L["Combat"], combatChecked, function(newState)
            local blNow = GetBlacklist()
            local e = blNow[blacklistKey] and blNow[blacklistKey][spell.spellId]
            if newState and not e then
                -- Checking combat on a non-blacklisted spell — add it
                blNow[blacklistKey][spell.spellId] = { combat = true, ooc = false }
                NotifyBlacklistChanged()
                refreshFn()
                return
            end
            if type(e) == "table" then
                e.combat = newState
                if not e.combat and not e.ooc then
                    blNow[blacklistKey][spell.spellId] = nil
                end
            end
            NotifyBlacklistChanged()
            refreshFn()
        end)
        combatCB:SetPoint("RIGHT", row, "RIGHT", -104, 0)

        local oocCB = CreateMiniCheckbox(row, L["OOC"], oocChecked, function(newState)
            local blNow = GetBlacklist()
            local e = blNow[blacklistKey] and blNow[blacklistKey][spell.spellId]
            if newState and not e then
                -- Checking OOC on a non-blacklisted spell — add it
                blNow[blacklistKey][spell.spellId] = { combat = false, ooc = true }
                NotifyBlacklistChanged()
                refreshFn()
                return
            end
            if type(e) == "table" then
                e.ooc = newState
                if not e.combat and not e.ooc then
                    blNow[blacklistKey][spell.spellId] = nil
                end
            end
            NotifyBlacklistChanged()
            refreshFn()
        end)
        oocCB:SetPoint("RIGHT", row, "RIGHT", -44, 0)

        -- Click row to toggle blacklist (toggle both on/off)
        row:SetScript("OnClick", function()
            local blNow = GetBlacklist()
            if blNow[blacklistKey][spell.spellId] then
                blNow[blacklistKey][spell.spellId] = nil
            else
                blNow[blacklistKey][spell.spellId] = { combat = true, ooc = true }
            end
            NotifyBlacklistChanged()
            refreshFn()
        end)

        -- Hover effect + tooltip
        row:SetScript("OnEnter", function(self)
            if isBlacklisted then
                self:SetBackdropColor(0.18, 0.18, 0.18, 0.95)
            else
                self:SetBackdropColor(0.12, 0.12, 0.12, 0.8)
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spell.spellId)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function(self)
            if isBlacklisted then
                self:SetBackdropColor(0.14, 0.14, 0.14, 0.95)
            else
                self:SetBackdropColor(0.08, 0.08, 0.08, 0.6)
            end
            GameTooltip:Hide()
        end)

        return row
    end

    -- ========== SPELL LIST WIDGET ==========
    local function CreateSpellListWidget(yAnchorFrame, yOffset, headerText, getSpellsFn, blacklistKey, itemPool)
        local ROW_HEIGHT = 28
        local LIST_WIDTH = 480
        local LIST_HEIGHT = 220

        local container = CreateFrame("Frame", nil, parent)
        container:SetSize(LIST_WIDTH, LIST_HEIGHT + 30)
        container:SetPoint("TOPLEFT", yAnchorFrame, "BOTTOMLEFT", 0, yOffset)

        -- Header
        local tc = GetThemeColor()
        local header = container:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        header:SetPoint("TOPLEFT", 0, 0)
        header:SetText(headerText)
        header:SetTextColor(tc.r, tc.g, tc.b)

        -- Blacklisted count (right-aligned next to header)
        local countText = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        countText:SetPoint("LEFT", header, "RIGHT", 10, 0)
        countText:SetTextColor(0.5, 0.5, 0.5)

        -- List background
        local listBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
        listBg:SetPoint("TOPLEFT", 0, -18)
        listBg:SetSize(LIST_WIDTH, LIST_HEIGHT)
        listBg:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        listBg:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
        listBg:SetBackdropBorderColor(0.20, 0.20, 0.20, 1)

        -- Scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, listBg, "ScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 4, -4)
        scrollFrame:SetPoint("BOTTOMRIGHT", -24, 4)
        DF.GUI.StyleScrollBar(scrollFrame)

        local scrollContent = CreateFrame("Frame", nil, scrollFrame)
        scrollContent:SetSize(LIST_WIDTH - 28, 1)
        scrollFrame:SetScrollChild(scrollContent)

        -- Empty hint
        local emptyText = listBg:CreateFontString(nil, "OVERLAY", "DFFontDisableSmall")
        emptyText:SetPoint("CENTER", listBg, "CENTER", 0, 0)
        emptyText:SetText(L["No spells available for this class"])

        -- Refresh
        local function Refresh()
            -- Clear old items
            for _, item in ipairs(itemPool) do
                item:ClearAllPoints()
                item:Hide()
            end
            wipe(itemPool)

            local spells = getSpellsFn()
            emptyText:SetShown(#spells == 0)

            -- Count blacklisted
            local bl = GetBlacklist()
            local blCount = 0
            for _, spell in ipairs(spells) do
                if bl[blacklistKey][spell.spellId] then
                    blCount = blCount + 1
                end
            end
            if blCount > 0 then
                countText:SetText(format(L["%d blacklisted"], blCount))
            else
                countText:SetText("")
            end

            scrollContent:SetHeight(math.max(1, #spells * ROW_HEIGHT))

            for i, spell in ipairs(spells) do
                local row = CreateSpellRow(scrollContent, spell, i, ROW_HEIGHT, blacklistKey, Refresh)
                tinsert(itemPool, row)
            end
        end

        container.Refresh = Refresh
        Refresh()

        return container
    end

    -- ========== CURATED LIST NOTICE ==========
    local noticeBanner = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    noticeBanner:SetPoint("TOPLEFT", 10, -10)
    noticeBanner:SetPoint("RIGHT", -10, 0)
    noticeBanner:SetHeight(44)
    if not noticeBanner.SetBackdrop then Mixin(noticeBanner, BackdropTemplateMixin) end
    noticeBanner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    noticeBanner:SetBackdropColor(0.25, 0.22, 0.10, 1)
    noticeBanner:SetBackdropBorderColor(0.6, 0.55, 0.2, 0.6)

    local noticeIcon = noticeBanner:CreateTexture(nil, "OVERLAY")
    noticeIcon:SetPoint("LEFT", 10, 0)
    noticeIcon:SetSize(20, 20)
    noticeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\warning")

    local noticeText = noticeBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    noticeText:SetPoint("LEFT", noticeIcon, "RIGHT", 8, 0)
    noticeText:SetPoint("RIGHT", noticeBanner, "RIGHT", -10, 0)
    noticeText:SetJustifyH("LEFT")
    noticeText:SetText(L["This is a curated list selected by Blizzard. Additional spells cannot be added as these are the only spells Blizzard has allowed. If more are permitted in the future, they will be added to this list."])
    noticeText:SetTextColor(1, 0.82, 0)

    -- ========== DESCRIPTION ==========
    local desc = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    desc:SetPoint("TOPLEFT", noticeBanner, "BOTTOMLEFT", 0, -8)
    desc:SetPoint("RIGHT", -10, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText(L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."])
    desc:SetTextColor(0.6, 0.6, 0.6)

    -- ========== CLASS DROPDOWN ==========
    local dropdownContainer = CreateFrame("Frame", nil, parent)
    dropdownContainer:SetSize(280, 55)
    dropdownContainer:SetPoint("TOPLEFT", 10, -80)

    local classLabel = dropdownContainer:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    classLabel:SetPoint("TOPLEFT", 0, 0)
    classLabel:SetText(L["Class"])
    classLabel:SetTextColor(0.7, 0.7, 0.7)

    -- Build dropdown items
    local classOptions = {}
    tinsert(classOptions, { value = "AUTO", text = L["Auto (detect class)"] })
    if DF.AuraBlacklist and DF.AuraBlacklist.ClassOrder then
        for _, classToken in ipairs(DF.AuraBlacklist.ClassOrder) do
            local className = DF.AuraBlacklist.ClassNames and DF.AuraBlacklist.ClassNames[classToken] or classToken
            tinsert(classOptions, { value = classToken, text = className })
        end
    end

    local dropdownBtn = CreateFrame("Button", nil, dropdownContainer, "BackdropTemplate")
    dropdownBtn:SetSize(200, 24)
    dropdownBtn:SetPoint("TOPLEFT", 0, -16)
    dropdownBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dropdownBtn:SetBackdropColor(0.12, 0.12, 0.12, 0.95)
    dropdownBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local dropdownText = dropdownBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    dropdownText:SetPoint("LEFT", 8, 0)
    dropdownText:SetPoint("RIGHT", -20, 0)
    dropdownText:SetJustifyH("LEFT")

    local dropdownArrow = dropdownBtn:CreateTexture(nil, "OVERLAY")
    dropdownArrow:SetSize(10, 10)
    dropdownArrow:SetPoint("RIGHT", -6, 0)
    dropdownArrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
    dropdownArrow:SetTexCoord(0, 1, 1, 0)

    -- Update dropdown display text
    local function UpdateDropdownText()
        for _, opt in ipairs(classOptions) do
            if opt.value == selectedClass then
                local displayText = opt.text
                if selectedClass == "AUTO" then
                    local playerClass = GetPlayerClass()
                    local playerClassName = DF.AuraBlacklist and DF.AuraBlacklist.ClassNames and DF.AuraBlacklist.ClassNames[playerClass] or playerClass
                    displayText = format(L["Auto (%s)"], playerClassName or L["Unknown"])
                end
                dropdownText:SetText(displayText)
                return
            end
        end
        dropdownText:SetText(L["Select Class"])
    end

    -- Dropdown menu (parented to UIParent so it renders above everything)
    local dropdownMenu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    dropdownMenu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dropdownMenu:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
    dropdownMenu:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    dropdownMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    dropdownMenu:SetPoint("TOPLEFT", dropdownBtn, "BOTTOMLEFT", 0, -2)
    dropdownMenu:SetSize(200, #classOptions * 22 + 4)
    dropdownMenu:Hide()

    -- Click-outside overlay to close dropdown (#441)
    local dropdownOverlay = CreateFrame("Button", nil, UIParent)
    dropdownOverlay:SetAllPoints(UIParent)
    dropdownOverlay:SetFrameStrata("FULLSCREEN")
    dropdownOverlay:Hide()
    dropdownOverlay:SetScript("OnClick", function()
        dropdownMenu:Hide()
        dropdownOverlay:Hide()
    end)

    for i, opt in ipairs(classOptions) do
        local optBtn = CreateFrame("Button", nil, dropdownMenu)
        optBtn:SetSize(196, 20)
        optBtn:SetPoint("TOPLEFT", 2, -2 - (i - 1) * 22)

        local optBg = optBtn:CreateTexture(nil, "BACKGROUND")
        optBg:SetAllPoints()
        optBg:SetColorTexture(0, 0, 0, 0)
        optBtn._bg = optBg

        local optText = optBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        optText:SetPoint("LEFT", 8, 0)
        optText:SetText(opt.text)

        optBtn:SetScript("OnEnter", function()
            optBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        end)
        optBtn:SetScript("OnLeave", function()
            optBg:SetColorTexture(0, 0, 0, 0)
        end)
        optBtn:SetScript("OnClick", function()
            selectedClass = opt.value
            UpdateDropdownText()
            dropdownMenu:Hide()
            dropdownOverlay:Hide()
            if page._buffWidget then page._buffWidget:Refresh() end
        end)
    end

    dropdownBtn:SetScript("OnClick", function()
        if dropdownMenu:IsShown() then
            dropdownMenu:Hide()
            dropdownOverlay:Hide()
        else
            dropdownMenu:Show()
            dropdownOverlay:Show()
        end
    end)
    dropdownBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    end)
    dropdownBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    end)

    UpdateDropdownText()
    page._updateDropdownText = UpdateDropdownText

    -- ========== BUFF BLACKLIST WIDGET ==========
    local buffWidget = CreateSpellListWidget(
        dropdownContainer, -10, L["BUFF BLACKLIST"],
        GetAllBuffs, "buffs", buffItemPool
    )
    page._buffWidget = buffWidget

    -- ========== DEBUFF BLACKLIST WIDGET ==========
    local debuffWidget = CreateSpellListWidget(
        buffWidget, -20, L["DEBUFF BLACKLIST"],
        GetAllDebuffs, "debuffs", debuffItemPool
    )
    page._debuffWidget = debuffWidget
end
