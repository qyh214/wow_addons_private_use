---@diagnostic disable
-- Preydator: deDE (German) localization
if GetLocale() ~= "deDE" then return end
local L = _G.PreydatorL

-- Translate each string. Remove the comment markers and fill in the value.
-- The below are AI translations if anyon can proof them I could do translations this way.
-- Untranslated strings automatically fall back to English.

-- L["No Sign in These Fields"]   = "Keine Spuren in diesen Feldern"
-- L["AMBUSH"]                    = "Hinterhalt"
-- L["Scent in the Wind"]         = "Duft im Wind"
-- L["Blood in the Shadows"]      = "Blut im Schatten"
-- L["Echoes of the Kill"]        = "Echos des Todes"
-- L["Feast of the Fang"]         = "Fest des Fangzahns"

-- Difficulty names — used to identify difficulty from adventure-map pin descriptions.
-- These must match the substrings that appear in the WoW DE-client pin text.
-- deDE confirmed by user report (gz2k2, GitHub issue #10).
L["Normal"]    = "Normal"
L["Hard"]      = "Schwer"
L["Nightmare"] = "Alptraum"
