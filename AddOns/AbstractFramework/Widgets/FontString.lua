---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- font string
---------------------------------------------------------------------
---@class AF_FontString:FontString
local AF_FontStringMixin = {}

---@param color string|table
function AF_FontStringMixin:SetColor(color)
    AF.ColorFontString(self, color)
end

---@param text string
function AF_FontStringMixin:AppendText(text)
    local currentText = self:GetText()
    if currentText and currentText ~= "" then
        self:SetText(currentText .. text)
    else
        self:SetText(text)
    end
end

---@param parent Frame
---@param text string
---@param color string color name defined in Color.lua
---@param font? string font name/file, default "AF_FONT_NORMAL"
---@param layer? string font string layer, default "OVERLAY"
---@return AF_FontString fs
function AF.CreateFontString(parent, text, color, font, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    Mixin(fs, AF_FontStringMixin)

    if type(font) == "string" and font:find("%.ttf$") then
        AF.SetFont(fs, AF.GetFontProps(font))
    else
        fs:SetFontObject(font or "AF_FONT_NORMAL")
    end

    if color then AF.ColorFontString(fs, color) end
    fs:SetText(text)

    AF.AddToPixelUpdater_OnShow(fs)

    return fs
end

---------------------------------------------------------------------
-- GetStringSize
---------------------------------------------------------------------
local font_string

---@deprecated
---@param text string
---@param fontFile string
---@param fontSize number
---@param fontFlag string
---@param fontShadow boolean
---@return number width, number height
function AF.GetStringSize(text, fontFile, fontSize, fontFlag, fontShadow)
    if not font_string then
        font_string = AF.UIParent:CreateFontString(nil, "OVERLAY")
    end
    AF.SetFont(font_string, fontFile, fontSize, fontFlag, fontShadow)
    font_string:SetText(text)
    return font_string:GetStringWidth(), font_string:GetStringHeight()
end

---@deprecated
---@param fs FontString
---@return number width, number height
function AF.GetFontStringSize(fs)
    local text = fs:GetText()
    local fontFile, fontSize, fontFlag = fs:GetFont()
    return AF.GetStringSize(text, fontFile, fontSize, fontFlag)
end

---------------------------------------------------------------------
-- update text container size
---------------------------------------------------------------------
local ceil = math.ceil

local function ResizeToFitText(self, frame, fontString, hPadding, vPadding, callback)
    self.elapsed = 0

    hPadding = hPadding and hPadding * 2
    vPadding = vPadding and vPadding * 2

    self:SetScript("OnUpdate", function(self, elapsed)
        if hPadding then
            frame:SetWidth(ceil(fontString:GetStringWidth() + hPadding))
        end
        if vPadding then
            frame:SetHeight(ceil(fontString:GetStringHeight() + vPadding))
        end

        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= 0.5 or not frame:IsShown() then
            self:Hide()
            if callback then callback(frame:GetSize()) end
        end
    end)
    self:Show()
end

local pool = AF.CreateObjectPool(function(pool)
    local f = CreateFrame("Frame")
    f:Hide()
    f.ResizeToFitText = ResizeToFitText
    f:SetScript("OnHide", function()
        pool:Release(f)
    end)
    return f
end)

---@param frame Frame
---@param fontString FontString
---@param hPadding number? horizontal padding, if omitted, will not change width
---@param vPadding number? vertical padding, if omitted, will not change height
---@param callback function? called after resize is done
function AF.ResizeToFitText(frame, fontString, hPadding, vPadding, callback)
    pool:Acquire():ResizeToFitText(frame, fontString, hPadding, vPadding, callback)
end

---------------------------------------------------------------------
-- truncation
---------------------------------------------------------------------
local utf8len, utf8sub = string.utf8len, string.utf8sub

---@param fs FontString
---@param alignment string? "left" | "right" | nil
---@param width number? if not provided, will use parent's width - 2
---@param showEllipsis boolean? whether to show ellipsis "..."
---@param text string? if not provided, will use fs:GetText()
function AF.TruncateFontStringByWidth(fs, width, alignment, showEllipsis, text)
    text = text or fs:GetText()
    if AF.IsBlank(text) then
        fs:SetText("")
        return
    end

    alignment = alignment or "left"
    if not width then
        width = fs:GetParent():GetWidth() - 2
    end

    fs:SetText(text)
    fs:SetWordWrap(false)

    if fs:IsTruncated() or fs:GetWidth() > width then
        for i = 2, utf8len(text) do
            if showEllipsis then
                if strlower(alignment) == "right" then
                    fs:SetFormattedText("%s%s", "...", utf8sub(text, i))
                else
                    fs:SetFormattedText("%s%s", utf8sub(text, 1, -1 * i), "...")
                end
            else
                if strlower(alignment) == "right" then
                    fs:SetText(utf8sub(text, i))
                else
                    fs:SetText(utf8sub(text, 1, -1 * i))
                end
            end

            if not fs:IsTruncated() and fs:GetWidth() <= width then
                break
            end
        end
    end
end

---@param fs FontString
---@param enChars number number of English characters
---@param nonEnChars number number of non-English characters
---@param text string? if not provided, will use fs:GetText(). if text contains only English characters, it will be truncated by enChars, otherwise by nonEnChars.
function AF.TruncateFontStringByLength(fs, enChars, nonEnChars, text)
    text = text or fs:GetText()
    if AF.IsBlank(text) then
        fs:SetText("")
        return
    end
    fs:SetText(AF.TruncateStringByLength(text, enChars, nonEnChars))
end

---------------------------------------------------------------------
-- notification text
---------------------------------------------------------------------
local pool

local function ShowUp(fs, parent, hideDelay)
    parent._notificationString = fs
    fs.ag.out_a:SetStartDelay(hideDelay or 2)
    fs:Show()
    fs.ag:Play()
    fs.ag:SetScript("OnFinished", function()
        parent._notificationString = nil
        pool:Release(fs)
    end)
end

local function HideOut(fs, parent)
    parent._notificationString = nil
    pool:Release(fs)
    fs.ag:Stop()
end

local function creationFunc()
    -- NOTE: do not use AF.CreateFontString, since we don't need UpdatePixels() for it
    local fs = AF.UIParent:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
    fs:Hide()

    fs:SetWordWrap(true) -- multiline allowed

    local ag = fs:CreateAnimationGroup()
    fs.ag = ag

    -- in ---------------------------------------
    local in_a = ag:CreateAnimation("Alpha")
    ag.in_a = in_a
    in_a:SetOrder(1)
    in_a:SetFromAlpha(0)
    in_a:SetToAlpha(1)
    in_a:SetDuration(0.25)

    -- out -------------------------------------
    local out_a = ag:CreateAnimation("Alpha")
    ag.out_a = out_a
    out_a:SetOrder(2)
    out_a:SetFromAlpha(1)
    out_a:SetToAlpha(0)
    out_a:SetStartDelay(2)
    out_a:SetDuration(0.25)

    fs.ShowUp = ShowUp
    fs.HideOut = HideOut

    return fs
end

local function resetterFunc(_, f)
    f:Hide()
end

pool = CreateObjectPool(creationFunc, resetterFunc)

function AF.ShowNotificationText(text, color, width, hideDelay, point, relativeTo, relativePoint, offsetX, offsetY)
    assert(relativeTo, "parent can not be nil!")
    if relativeTo._notificationString then
        relativeTo._notificationString:HideOut(relativeTo)
    end

    local fs = pool:Acquire()
    fs:SetParent(relativeTo) --! IMPORTANT, if parent is nil, then game will crash (The memory could not be "read")
    fs:SetText(text)
    AF.ColorFontString(fs, color or "red")
    if width then fs:SetWidth(width) end

    -- alignment
    if strfind(point, "LEFT$") then
        fs:SetJustifyH("LEFT")
    elseif strfind(point, "RIGHT$") then
        fs:SetJustifyH("RIGHT")
    else
        fs:SetJustifyH("CENTER")
    end

    fs:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
    fs:ShowUp(relativeTo, hideDelay)
end

---------------------------------------------------------------------
-- scrolling text
---------------------------------------------------------------------
---@class AF_ScrollingText:ScrollFrame
local AF_ScrollingTextMixin = {}

---@param str string
---@param color? string color name defined in Color.lua
function AF_ScrollingTextMixin:SetText(str, color)
    self.text:SetText(color and AF.WrapTextInColor(str, color) or str)
    if self:IsVisible() then
        self:ShowUp()
    end
end

local function AF_ScrollingText_OnUpdate_Scroll(self, elapsed)
    -- NOTE: FPS significantly affects OnUpdate frequency
    -- 60FPS  -> 0.0166667 (1/60)
    -- 90FPS  -> 0.0111111 (1/90)
    -- 120FPS -> 0.0083333 (1/120)

    if self.paused then return end

    self.sTime = self.sTime + elapsed
    if self.eTime >= self.endDelay then
        self.fadeOutIn:Play()
    elseif self.sTime >= self.startDelay then
        if self.scroll >= self.scrollRange then -- scroll at max
            self.eTime = self.eTime + elapsed
        else
            self.elapsedTime = self.elapsedTime + elapsed
            if self.elapsedTime >= self.frequency then -- scroll
                self.elapsedTime = 0
                self.scroll = self.scroll + self.step
                self:SetHorizontalScroll(self.scroll)
            end
        end
    end
end

local function AF_ScrollingText_OnUpdate_Check(self)
    -- NOTE: self:GetWidth() is valid on next OnUpdate
    if self:GetWidth() ~= 0 then
        self:SetScript("OnUpdate", nil)

        if self.text:GetStringWidth() <= self:GetWidth() then
            self:SetScript("OnUpdate", nil)
        else
            self.scrollRange = self.text:GetStringWidth() - self:GetWidth()
            self:SetScript("OnUpdate", AF_ScrollingText_OnUpdate_Scroll)
        end
    end
end

---@private
function AF_ScrollingTextMixin:ShowUp(skipFadeIn)
    if not skipFadeIn then
        self.fadeIn:Play()
    end
    self:SetHorizontalScroll(0)
    self.scroll = 0
    self.sTime, self.eTime, self.elapsedTime = 0, 0, 0

    self:SetScript("OnUpdate", AF_ScrollingText_OnUpdate_Check)
end

function AF_ScrollingTextMixin:Pause()
    self.paused = true
end

function AF_ScrollingTextMixin:Resume()
    self.paused = nil
end

function AF_ScrollingTextMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    -- if self:IsVisible() then
    --     self:ShowUp()
    -- end
end

---@param parent Frame
---@param frequency? number default 0.01
---@param step? number default 1
---@param startDelay? number default 2
---@param endDelay? number default 2
---@return AF_ScrollingText scroller
function AF.CreateScrollingText(parent, frequency, step, startDelay, endDelay)
    local holder = CreateFrame("ScrollFrame", nil, parent)
    AF.SetHeight(holder, 20)

    -- vars -------------------------------------
    holder.frequency = frequency or 0.01
    holder.step = step or 1
    holder.startDelay = startDelay or 2
    holder.endDelay = endDelay or 2
    holder.scroll, holder.scrollRange = 0, 0
    holder.sTime, holder.eTime, holder.elapsedTime = 0, 0, 0
    ---------------------------------------------

    local content = CreateFrame("Frame", nil, holder)
    content:SetSize(20, 20)
    holder:SetScrollChild(content)

    local text = AF.CreateFontString(content)
    holder.text = text
    text:SetWordWrap(false)
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT")

    -- fade in ----------------------------------
    local fadeIn = text:CreateAnimationGroup()
    holder.fadeIn = fadeIn
    fadeIn._in = fadeIn:CreateAnimation("Alpha")
    fadeIn._in:SetFromAlpha(0)
    fadeIn._in:SetToAlpha(1)
    fadeIn._in:SetDuration(0.5)
    ---------------------------------------------

    -- fade out then in -------------------------
    local fadeOutIn = text:CreateAnimationGroup()
    holder.fadeOutIn = fadeOutIn

    fadeOutIn._out = fadeOutIn:CreateAnimation("Alpha")
    fadeOutIn._out:SetFromAlpha(1)
    fadeOutIn._out:SetToAlpha(0)
    fadeOutIn._out:SetDuration(0.5)
    fadeOutIn._out:SetOrder(1)

    fadeOutIn._in = fadeOutIn:CreateAnimation("Alpha")
    fadeOutIn._in:SetStartDelay(0.1) -- time for SetHorizontalScroll(0)
    fadeOutIn._in:SetFromAlpha(0)
    fadeOutIn._in:SetToAlpha(1)
    fadeOutIn._in:SetDuration(0.5)
    fadeOutIn._in:SetOrder(2)

    fadeOutIn._out:SetScript("OnFinished", function()
        holder:SetHorizontalScroll(0)
        holder.scroll = 0
    end)

    fadeOutIn:SetScript("OnFinished", function()
        holder.sTime, holder.eTime, holder.elapsedTime = 0, 0, 0
    end)
    ---------------------------------------------

    -- init holder
    Mixin(holder, AF_ScrollingTextMixin)
    holder:SetScript("OnShow", holder.ShowUp)

    AF.AddToPixelUpdater_OnShow(holder)

    return holder
end

---------------------------------------------------------------------
-- SetText with length
---------------------------------------------------------------------
---@param fs FontString
---@param text string
---@param length? number
---@param prefix? string|number
---@param suffix? string|number
function AF.SetText(fs, text, length, prefix, suffix)
    if length and length > 0 then
        if length <= 1 then
            local width = fs:GetParent():GetWidth() - 2
            for i = utf8len(text), 0, -1 do
                fs:SetText(utf8sub(text, 1, i))
                if fs:GetWidth() / width <= length then
                    break
                end
            end
        else
            fs:SetText(utf8sub(text, 1, length))
        end
    else
        fs:SetText(text)
    end

    if prefix then
        fs:SetText(prefix .. fs:GetText())
    end

    if suffix then
        fs:SetText(fs:GetText() .. suffix)
    end
end

---------------------------------------------------------------------
-- rainbow text
---------------------------------------------------------------------
local tconcat, tcreate = table.concat, table.create

local function UpdateRainbow(updater, elapsed)
    updater.elapsed = updater.elapsed + elapsed

    if updater.elapsed >= updater.interval then
        updater.elapsed = 0

        local fs = updater.fs
        local hue = updater.hue
        local step = updater.step
        local colors = updater.colors

        -- generate color for each character
        for i = 1, updater.charCount do
            local r, g, b = AF.ConvertHSBToRGB(hue, 1, 1)
            colors[i] = AF.ConvertRGBToHEX(r, g, b)
            hue = (hue + step) % 360
        end

        -- apply all colors at once
        fs:SetFormattedText(updater.formatString, unpack(colors))

        -- update hue position
        if updater.reverse then
            updater.hue = (updater.hue + updater.speed) % 360
        else
            updater.hue = (updater.hue - updater.speed + 360) % 360
        end
    end
end

---@param fs FontString
---@param interval number? update interval, default 0.05
---@param speed number? hue movement speed, default 3
---@param reverse boolean? reverse direction
function AF.RainbowText_Start(fs, interval, speed, reverse)
    -- save original text
    fs._text = fs:GetText()

    -- split text into characters
    local chars = {}
    local charCount = 0
    for char in fs._text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        charCount = charCount + 1
        chars[charCount] = char
    end

    -- generate format string, e.g.: "|cff%sA|r|cff%sB|r|cff%sC|r"
    local formatParts = {}
    for i = 1, charCount do
        formatParts[i] = "|cff%s" .. chars[i] .. "|r"
    end
    local formatString = tconcat(formatParts)

    -- create updater
    if not fs._rainbow_updater then
        fs._rainbow_updater = CreateFrame("Frame", nil, fs:GetParent())
        fs._rainbow_updater.fs = fs
        fs._rainbow_updater:Hide()
        fs._rainbow_updater:SetScript("OnUpdate", UpdateRainbow)
    end

    local updater = fs._rainbow_updater
    updater.interval = interval or 0.05
    updater.elapsed = 0
    updater.reverse = reverse
    updater.hue = 0
    updater.speed = speed or 3  -- hue degrees to move per update
    updater.step = charCount > 1 and (360 / charCount) or 360
    updater.charCount = charCount
    updater.formatString = formatString
    updater.colors = tcreate(charCount)
    updater:Show()
end

function AF.RainbowText_Stop(fs)
    if fs._rainbow_updater then
        fs._rainbow_updater:Hide()
        if fs._text then
            fs:SetText(fs._text)
            fs._text = nil
        end
    end
end

function AF.RainbowText_Pause(fs)
    if fs._rainbow_updater then
        fs._rainbow_updater:Hide()
    end
end

function AF.RainbowText_Resume(fs)
    if fs._rainbow_updater then
        fs._rainbow_updater:Show()
    end
end

---------------------------------------------------------------------
-- flow text
---------------------------------------------------------------------
local function UpdateFlow(updater, elapsed)
    updater.elapsed = updater.elapsed + elapsed
    if updater.elapsed >= updater.interval then
        updater.elapsed = 0

        local fs = updater.fs
        local charCount = updater.charCount
        if charCount <= 0 then return end

        -- update flow position using speed parameter
        updater.flowPos = (updater.flowPos + (updater.reverse and updater.speed or -updater.speed)) % 1

        -- calculate color for each character based on flow position
        for i = 1, charCount do
            -- calculate character position on color ring (0-1 range)
            -- use mult to adjust ring length, higher mult = longer color ring
            local charPos = ((i - 1) / (charCount * updater.mult) + updater.flowPos) % 1

            -- convert position to gradient position on color ring
            -- use sine function to create smooth color1->color2->color1 cycle
            local ratio = (math.sin(charPos * math.pi * 2 - math.pi/2) + 1) / 2

            -- interpolate between colors
            local r = AF.Lerp(updater.r1, updater.r2, ratio)
            local g = AF.Lerp(updater.g1, updater.g2, ratio)
            local b = AF.Lerp(updater.b1, updater.b2, ratio)

            updater.colors[i] = AF.ConvertRGBToHEX(r, g, b)
        end

        -- apply all colors at once
        fs:SetFormattedText(updater.formatString, unpack(updater.colors))
    end
end

---@param fs FontString
---@param color1 string first color name
---@param color2 string second color name
---@param mult number? color ring length multiplier, default 1, higher = longer ring
---@param interval number? update interval, default 0.05
---@param speed number? flow speed, default 0.03, lower = slower
---@param reverse boolean? reverse flow direction
function AF.FlowText_Start(fs, color1, color2, mult, interval, speed, reverse)
    fs._text = fs:GetText()

    -- split text into characters
    local chars = {}
    local charCount = 0
    for char in fs._text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        charCount = charCount + 1
        chars[charCount] = char
    end

    -- generate format string, e.g.: "|cff%sA|r|cff%sB|r|cff%sC|r"
    local formatParts = {}
    for i = 1, charCount do
        formatParts[i] = "|cff%s" .. chars[i] .. "|r"
    end
    local formatString = table.concat(formatParts)

    -- create updater
    if not fs._flow_updater then
        fs._flow_updater = CreateFrame("Frame", nil, fs:GetParent())
        fs._flow_updater.fs = fs
        fs._flow_updater:Hide()
        fs._flow_updater:SetScript("OnUpdate", UpdateFlow)
    end

    local updater = fs._flow_updater
    updater.interval = interval or 0.05
    updater.elapsed = 0
    updater.reverse = reverse
    updater.charCount = charCount
    updater.formatString = formatString
    updater.colors = tcreate and tcreate(charCount) or {}
    updater.r1, updater.g1, updater.b1 = AF.GetColorRGB(color1)
    updater.r2, updater.g2, updater.b2 = AF.GetColorRGB(color2)
    updater.flowPos = 0 -- flow position represented in 0-1 range
    updater.mult = mult or 1 -- color ring length multiplier
    updater.speed = speed or 0.03 -- flow movement speed per update

    updater:Show()
end

function AF.FlowText_Stop(fs)
    if fs._flow_updater then
        fs._flow_updater:Hide()
        if fs._text then
            fs:SetText(fs._text)
            fs._text = nil
        end
    end
end

function AF.FlowText_Pause(fs)
    if fs._flow_updater then
        fs._flow_updater:Hide()
    end
end

function AF.FlowText_Resume(fs)
    if fs._flow_updater then
        fs._flow_updater:Show()
    end
end