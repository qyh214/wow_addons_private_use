local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.CreateAndCopyLink()

  local Patterns = {
                     -- X://Y url
                    "^(%a[%w+.-]+://%S+)", "%f[%S](%a[%w+.-]+://%S+)",
                     -- www.X.Y url
                    "^(www%.[-%w_%%]+%.(%a%a+))", "%f[%S](www%.[-%w_%%]+%.(%a%a+))",
                     -- "W X"@Y.Z email (this is seriously a valid email)
                    '^(%"[^%"]+%"@[%w_.-%%]+%.(%a%a+))', '%f[%S](%"[^%"]+%"@[%w_.-%%]+%.(%a%a+))',
                     -- X@Y.Z email
                    "(%S+@[%w_.-%%]+%.(%a%a+))",
                     -- X.Y.Z/WWWWW url with path
                    "^([%w_.-%%]+[%w_-%%]%.(%a%a+)/%S+)", "%f[%S]([%w_.-%%]+[%w_-%%]%.(%a%a+)/%S+)",
                    -- X.Y.Z url
                    "^([-%w_%%]+%.[-%w_%%]+%.(%a%a+))", "%f[%S]([-%w_%%]+%.[-%w_%%]+%.(%a%a+))", "^([-%w_%%]+%.(%a%a+))", "%f[%S]([-%w_%%]+%.(%a%a+))",
                    }

  local CountryCode = {
                      "ONION", "AC", "AD", "AE", "AERO", "AF", "AG", "AI", "AL", "AM", "AN", "AO", "AQ", "AR", "ARPA", "AS", "ASIA", "AT", "AU", "AW", "AX", "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH",
                      "BI", "BIZ", "BJ", "BM", "BN", "BO", "BR", "BS", "BT", "BV", "BW", "BY", "BZ", "CA", "CAT", "CC", "CD", "CF", "CG", "CH", "CI", "CK", "CL", "CM", "CN", "CO", "COM", "COOP", "CR", 
                      "CU", "CV", "CX", "CY", "CZ", "DE", "DJ", "DK", "DM", "DO", "DZ", "EC", "EDU", "EE", "EG", "ER", "ES", "ET", "EU", "FI", "FJ", "FK", "FM", "FO", "FR", "GA", "GB", "GD", "GE", "GF",
                      "GG", "GH", "GI", "GL", "GM", "GN", "GOV", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY", "HK", "HM", "HN", "HR", "HT", "HU", "ID", "IE", "IL", "IM", "IN", "INFO", "INT", "IO", 
                      "IQ", "IR", "IS", "IT", "JE", "JM", "JO", "JOBS", "JP", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW", "KY", "KZ", "LA", "LB", "LC", "LI", "LK", "LR", "LS", "LT", "LU", "LV",
                      "LY", "MA", "MC", "MD", "ME", "MG", "MH", "MIL", "MK", "ML", "MM", "MN", "MO", "MOBI", "MP", "MQ", "MR", "MS", "MT", "MU", "MUSEUM", "MV", "MW", "MX", "MY", "MZ", "NA", "NAME", "NC",
                      "NE", "NET", "NF", "NG", "NI", "NL", "NO", "NP", "NR", "NU", "NZ", "OM", "ORG", "PA", "PE", "PF", "PG", "PH", "PK", "PL", "PM", "PN", "PR", "PRO", "PS", "PT", "PW", "PY", "QA", "RE",
                      "RO", "RS", "RU", "RW", "SA", "SB", "SC", "SD", "SE", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "ST", "SU", "SV", "SY", "SZ", "TC", "TD", "TEL", "TF", "TG", "TH",
                      "TJ", "TK", "TL", "TM", "TN", "TO", "TP", "TR", "TRAVEL", "TT", "TV", "TW", "TZ", "UA", "UG", "UK", "UM", "US", "UY", "UZ", "VA", "VC", "VE", "VG", "VI", "VN", "VU", "WF", "WS", "YE",
                      "YT", "YU", "ZA", "ZM", "ZW"
                      }

  local CHAT_TYPES = {
                      "SYSTEM", "SAY", "PARTY","RAID", "RAID_LEADER", "GUILD", "OFFICER", "YELL", "WHISPER", "WHISPER_INFORM", "BN_WHISPER", "REPLY", "EMOTE", "TEXT_EMOTE", "CHANNEL", "AFK", "DND",
                      "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "CHANNEL1", "CHANNEL2", "CHANNEL3", "CHANNEL4", "CHANNEL5", "CHANNEL6", "CHANNEL7", "CHANNEL8", "CHANNEL9",
                      "CHANNEL10" 
                      }

-- only Classic and Cataclysm
  local DefaultSetItemRef = SetItemRef
  function SetItemRef(link, ...)
    local type, value = link:match("(%a+):(.+)")
    if (type == "url") then
    local CaCLFrame = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox
    if not CaCLFrame then return end
    else
      return DefaultSetItemRef(link, ...)
    end
  end

  local CaCLFrame = CreateFrame("Frame", "CaCLFrame", UIParent, "DialogBoxFrame")
  CaCLFrame.text = CaCLFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  CaCLFrame.text:SetPoint("TOP", 0, -15)
  CaCLFrame.text:SetText("|cffff0000Map|r|cff00ccffNotes|r" .. "\n" .. L["Use CTRL + C to copy the link"] .. "\n" .. L["The window closes automatically after copying"])  
  CaCLFrame:SetSize(400, 130)
  CaCLFrame:SetPoint("TOP", 0, -300)
  CaCLFrame:SetBackdrop({
                        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                        edgeSize = 32,
                        insets = { left = 8, right = 8, top = 8, bottom = 8 } 
                        })
  CaCLFrame:SetBackdropBorderColor(00, 00, 00, 1);
  CaCLFrame:SetMovable(true)
  CaCLFrame:EnableMouse(true)
  CaCLFrame:RegisterForDrag("LeftButton")
  CaCLFrame:SetScript("OnDragStart", CaCLFrame.StartMoving)
  CaCLFrame:SetScript("OnDragStop", CaCLFrame.StopMovingOrSizing)
  CaCLFrame.editBox = CreateFrame("EditBox", nil, CaCLFrame, "InputBoxTemplate")
  CaCLFrame.editBox:SetSize(370, 30)
  CaCLFrame.editBox:SetPoint("CENTER", 0, -3)
  CaCLFrame.editBox:SetAutoFocus(true)
  CaCLFrame.editBox:SetFontObject(GameFontHighlight)
  CaCLFrame.editBox:SetScript("OnEscapePressed", function() CaCLFrame:Hide() end)
  CaCLFrame.editBox:SetScript("OnKeyUp", function(self, key) if (IsControlKeyDown() and key == "C") then CaCLFrame:Hide() end end)                

  local function formatURL(url)
    url = "|cff00ccff" .. "|Hurl:" .. url .. "|h" .. url .. "|h|r "
    return url
  end

  local function makeClickable(self, event, msg, ...)
    for k,p in pairs(Patterns or CountryCode) do
      if string.find(msg, p) then
        if ns.Addon.db.profile.CreateAndCopyLinks then
          msg = string.gsub(msg, p, formatURL("%1"))
        end
          return false, msg, ...
      end
    end
    return false, msg, ...
  end

  -- chat type filter
  for _, chatType in pairs(CHAT_TYPES) do
      ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. chatType, makeClickable)
  end

  -- message filter
  local function AddMessage(self, text, ...)
    if ns.questID then
      if ns.Addon.db.profile.CreateAndCopyLinks then
        text = text:gsub("https://www.wowhead.com/quest=" .. ns.questID, "|cff00ccff|Hurl:%1|h%1|h|r")
      end
    end
    if ns.achievementID then
      if ns.Addon.db.profile.CreateAndCopyLinks then
        text = text:gsub("https://www.wowhead.com/achievement=" .. ns.achievementID, "|cff00ccff|Hurl:%1|h%1|h|r")
      end
    end
    return self.DefaultAddMessage(self, text, ...)
  end

  -- printed links
  for print = 1, NUM_CHAT_WINDOWS do
    local chatframe = _G["ChatFrame".. print]
    chatframe.DefaultAddMessage = chatframe.AddMessage
    chatframe.AddMessage = AddMessage
  end

  -- Safe hook for ChatFrame_OnHyperlinkShow
  local function URLClicker_OnHyperlinkShow(self, link)
    if ns.Addon.db.profile.CreateAndCopyLinks then
      if string.sub(link, 1, 3) == "url" then
        local url = string.sub(link, 5)
        CaCLFrame:Show()
        CaCLFrame.editBox:SetText(url)
        CaCLFrame.editBox:HighlightText()
      end
    end
  end

  hooksecurefunc("ChatFrame_OnHyperlinkShow", URLClicker_OnHyperlinkShow)

end