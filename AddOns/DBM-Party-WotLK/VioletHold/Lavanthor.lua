local mod	= DBM:NewMod(630, "DBM-Party-WotLK", 12, 283)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(29312)
mod:SetEncounterID(2662)

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
