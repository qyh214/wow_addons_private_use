---@diagnostic disable
-- Preydator: ruRU (Russian) localization
-- Note: This locale requires Cyrillic character input from a Russian speaker.
-- Difficulty Localization credit goes to @reysonk on github
if GetLocale() ~= "ruRU" then return end
local L = _G.PreydatorL

-- L["No Sign in These Fields"]   = ""
-- L["AMBUSH"]                    = ""
-- L["Scent in the Wind"]         = ""
-- L["Blood in the Shadows"]      = ""
-- L["Echoes of the Kill"]        = ""
-- L["Feast of the Fang"]         = ""

-- Difficulty names — used to identify difficulty from adventure-map pin descriptions.
-- AI-TRANSLATED: These values have not been verified against live WoW ruRU client text.
-- A native speaker should confirm these match what the game actually shows in pin descriptions.
L["Normal"]    = "обычная"
L["Hard"]      = "высокая"
L["Nightmare"] = "кошмарная"
L["N/H/Ni"]    = "о/в/к"
