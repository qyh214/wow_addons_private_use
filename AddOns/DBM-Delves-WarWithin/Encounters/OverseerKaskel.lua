local mod	= DBM:NewMod("OverseerKaskel", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2990)
mod:SetZone()

mod:RegisterCombat("combat")
