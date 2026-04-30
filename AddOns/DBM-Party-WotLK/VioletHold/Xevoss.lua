local mod	= DBM:NewMod(629, "DBM-Party-WotLK", 12, 283)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(29266)
mod:SetEncounterID(2661)

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
