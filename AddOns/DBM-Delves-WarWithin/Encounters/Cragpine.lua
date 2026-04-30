local mod	= DBM:NewMod("Cragpine", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3436)
mod:SetZone()

mod:RegisterCombat("combat")

--NOTE. Blizz probably didn't actually mean to create a new boss, but rather give cragpie another spawn, but since they did, we do too
