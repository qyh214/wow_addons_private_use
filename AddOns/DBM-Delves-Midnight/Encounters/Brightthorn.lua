local mod	= DBM:NewMod("Brightthorn", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3364)
mod:SetZone()

mod:RegisterCombat("combat")
