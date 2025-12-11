local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local frameWidths = 700 -- outer windows widths
local frameHeights = 500 -- outer window heights
local edge = 19 -- = 0.5cm left and right
local LEFT, RIGHT = 12, 12 -- distance textframe to outer frame

function ns.ShowLoginChangelogWindow()
  if (MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown()) 
    or (MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown()) 
    then
    return
  end

  C_Timer.After(0.01, function()
    local LoginChangeLogFrame = CreateFrame("Frame", "MapNotesChangelogFrame", UIParent, "BasicFrameTemplateWithInset")
    LoginChangeLogFrame:SetSize(frameWidths, frameHeights)
    local textwindowWidths = frameWidths - (LEFT + RIGHT)
    LoginChangeLogFrame:SetPoint("CENTER")
    LoginChangeLogFrame:SetMovable(true)
    LoginChangeLogFrame:EnableMouse(true)
    LoginChangeLogFrame:RegisterForDrag("LeftButton")
    LoginChangeLogFrame:SetScript("OnDragStart", LoginChangeLogFrame.StartMoving)
    LoginChangeLogFrame:SetScript("OnDragStop", LoginChangeLogFrame.StopMovingOrSizing)
    LoginChangeLogFrame:SetFrameStrata("DIALOG")
    LoginChangeLogFrame:SetToplevel(true)
    LoginChangeLogFrame:SetClampedToScreen(true)

    LoginChangeLogFrame.title = LoginChangeLogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    LoginChangeLogFrame.title:SetPoint("TOP", 0, -3)
    LoginChangeLogFrame.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

    LoginChangeLogFrame.fixedVersionText = LoginChangeLogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    LoginChangeLogFrame.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
    LoginChangeLogFrame.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.CurrentAddonVersion)
        
    LoginChangeLogFrame.scrollFrame = CreateFrame("ScrollFrame", nil, LoginChangeLogFrame, "UIPanelScrollFrameTemplate")
    LoginChangeLogFrame.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    LoginChangeLogFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)

    local content = CreateFrame("Frame", nil, LoginChangeLogFrame.scrollFrame) -- EditBox with padding inside frame
    content:SetSize(textwindowWidths, 1)

    LoginChangeLogFrame.editBox = CreateFrame("EditBox", nil, content)
    LoginChangeLogFrame.editBox:SetMultiLine(true)
    LoginChangeLogFrame.editBox:SetFontObject(GameFontHighlight)
    LoginChangeLogFrame.editBox:SetPoint("TOPLEFT", edge, 0)
    LoginChangeLogFrame.editBox:SetPoint("RIGHT", content, "RIGHT", -edge, 0)
    LoginChangeLogFrame.editBox:SetAutoFocus(false)

    local changelogText = ns.BuildAllChangelogText()
    LoginChangeLogFrame.editBox:SetText(changelogText)
    LoginChangeLogFrame.editBox:SetScript("OnEscapePressed", function() end)
    LoginChangeLogFrame.editBox:SetScript("OnEnterPressed", function() end)
    LoginChangeLogFrame.editBox:EnableMouse(false)
    LoginChangeLogFrame.editBox:SetCursorPosition(0)
    LoginChangeLogFrame.editBox:ClearFocus()
    LoginChangeLogFrame.editBox:SetScript("OnEditFocusGained", function(self)
        self:ClearFocus()
    end)
    LoginChangeLogFrame.scrollFrame:SetScrollChild(content)
    LoginChangeLogFrame.checkbox = CreateFrame("CheckButton", nil, LoginChangeLogFrame, "ChatConfigCheckButtonTemplate")
    LoginChangeLogFrame.checkbox:SetPoint("BOTTOMLEFT", 10, 10)
    LoginChangeLogFrame.checkbox.Text:SetText("|cffff0000" .. L["Do not show again until next version"])
    LoginChangeLogFrame.closeButton = CreateFrame("Button", nil, LoginChangeLogFrame, "GameMenuButtonTemplate")
    LoginChangeLogFrame.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
    LoginChangeLogFrame.closeButton:SetSize(100, 25)
    LoginChangeLogFrame.closeButton:SetText(CLOSE)

    LoginChangeLogFrame.closeButton:SetScript("OnClick", function()
      if LoginChangeLogFrame.checkbox:GetChecked() then
        HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.CurrentAddonVersion
        print(ns.COLORED_ADDON_NAME .. " " .. (ns.CHANGE_LOG_CONFIRMED[ns.locale] or ns.CHANGE_LOG_CONFIRMED.enUS))
      end
      LoginChangeLogFrame:Hide()
    end)

    LoginChangeLogFrame:SetScript("OnHide", function()
      if LoginChangeLogFrame.checkbox:GetChecked() then
        HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.CurrentAddonVersion
      end
    end)

  end)

  table.insert(UISpecialFrames, "MapNotesChangelogFrame")
end

function ns.ShowMenuChangelogWindow()
  if (MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown()) 
    or (MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown()) 
    then
    return
  end

  local ChangeLogFrameMenu = CreateFrame("Frame", "MapNotesChangelogFrameMenu", UIParent, "BasicFrameTemplateWithInset")
  ChangeLogFrameMenu:SetSize(frameWidths, frameHeights)
  local textwindowWidths = frameWidths - (LEFT + RIGHT)
  ChangeLogFrameMenu:SetPoint("CENTER")
  ChangeLogFrameMenu:SetMovable(true)
  ChangeLogFrameMenu:EnableMouse(true)
  ChangeLogFrameMenu:RegisterForDrag("LeftButton")
  ChangeLogFrameMenu:SetScript("OnDragStart", ChangeLogFrameMenu.StartMoving)
  ChangeLogFrameMenu:SetScript("OnDragStop", ChangeLogFrameMenu.StopMovingOrSizing)
  ChangeLogFrameMenu:SetFrameStrata("DIALOG")
  ChangeLogFrameMenu:SetToplevel(true)
  ChangeLogFrameMenu:SetClampedToScreen(true)

  ChangeLogFrameMenu.title = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  ChangeLogFrameMenu.title:SetPoint("TOP", 0, -3)
  ChangeLogFrameMenu.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

  ChangeLogFrameMenu.fixedVersionText = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  ChangeLogFrameMenu.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
  ChangeLogFrameMenu.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.PreviousAddonVersion_1 .. " + " .. PREVIOUS)

  ChangeLogFrameMenu.scrollFrame = CreateFrame("ScrollFrame", nil, ChangeLogFrameMenu, "UIPanelScrollFrameTemplate")
  ChangeLogFrameMenu.scrollFrame:SetPoint("TOPLEFT", 10, -40)
  ChangeLogFrameMenu.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)

  local content = CreateFrame("Frame", nil, ChangeLogFrameMenu.scrollFrame)
  content:SetSize(textwindowWidths, 1)
  ChangeLogFrameMenu.editBox = CreateFrame("EditBox", nil, content)
  ChangeLogFrameMenu.editBox:SetMultiLine(true)
  ChangeLogFrameMenu.editBox:SetFontObject(GameFontHighlight)
  ChangeLogFrameMenu.editBox:SetPoint("TOPLEFT", edge, 0)
  ChangeLogFrameMenu.editBox:SetPoint("RIGHT", content, "RIGHT", -edge, 0)
  ChangeLogFrameMenu.editBox:SetAutoFocus(false)

  local changelogText = ns.BuildAllChangelogText()
  ChangeLogFrameMenu.editBox:SetText(changelogText)
  ChangeLogFrameMenu.editBox:SetScript("OnEscapePressed", function() end)
  ChangeLogFrameMenu.editBox:SetScript("OnEnterPressed", function() end)
  ChangeLogFrameMenu.editBox:EnableMouse(false)
  ChangeLogFrameMenu.editBox:SetCursorPosition(0)
  ChangeLogFrameMenu.editBox:ClearFocus()
  ChangeLogFrameMenu.editBox:SetScript("OnEditFocusGained", function(self)
      self:ClearFocus()
  end)

  ChangeLogFrameMenu.scrollFrame:SetScrollChild(content)

  ChangeLogFrameMenu.closeButton = CreateFrame("Button", nil, ChangeLogFrameMenu, "GameMenuButtonTemplate")
  ChangeLogFrameMenu.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
  ChangeLogFrameMenu.closeButton:SetSize(100, 25)
  ChangeLogFrameMenu.closeButton:SetText(CLOSE)

  ChangeLogFrameMenu.closeButton:SetScript("OnClick", function()
    ChangeLogFrameMenu:Hide()
    LibStub("AceConfigDialog-3.0"):Open("MapNotes")
  end)

  ChangeLogFrameMenu:SetScript("OnHide", function()
    LibStub("AceConfigDialog-3.0"):Open("MapNotes")
  end)

  table.insert(UISpecialFrames, "MapNotesChangelogFrameMenu")
end

local DBFrame = CreateFrame("Frame")
DBFrame:RegisterEvent("ADDON_LOADED")
DBFrame:SetScript("OnEvent", function(_, event, addonName)
  if addonName == "HandyNotes_MapNotes" then
    if not HandyNotes_MapNotesRetailChangelogDB then
      HandyNotes_MapNotesRetailChangelogDB = {}
    end

    if not HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion then
      HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.PreviousAddonVersion_1
    end

    if HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion ~= ns.CurrentAddonVersion then
      ns.ShowLoginChangelogWindow()
    end
  end
end)

local function MN_GetLocaleText(localeTable)
  if type(localeTable) ~= "table" then return "" end

  local text = localeTable[GetLocale()]
  if not text or text == "" then
    text = localeTable["enUS"] or ""
  end
  
  return text
end

local function MN_FormatVersionBlock(version, localeTable)
  local text = MN_GetLocaleText(localeTable)
  if not text or text == "" then return "" end
  return string.format("|cffffd700%s %s:|r\n\n%s", GAME_VERSION_LABEL, tostring(version or ""), text)
end

function ns.BuildAllChangelogText()
  if type(ns.LOCALE_CHANGELOGS) ~= "table" then return "" end
  local allVersionTexts = {}

  for _, entry in ipairs(ns.LOCALE_CHANGELOGS) do
    local t = entry.table or ns["LOCALE_CHANGELOG_" .. entry.version:gsub("%.", "_")]
    local versionText = MN_FormatVersionBlock(entry.version, t)
    if versionText ~= "" then
      table.insert(allVersionTexts, versionText)
    end
  end

  return table.concat(allVersionTexts, "\n\n\n")
end