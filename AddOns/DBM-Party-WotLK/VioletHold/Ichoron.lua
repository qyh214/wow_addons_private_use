local mod	= DBM:NewMod(628, "DBM-Party-WotLK", 12, 283)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(29313)
mod:SetEncounterID(2660)

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
