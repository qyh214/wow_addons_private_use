local mod	= DBM:NewMod("UnderseaAbomination", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2895)
mod:SetZone()

mod:RegisterCombat("combat")
