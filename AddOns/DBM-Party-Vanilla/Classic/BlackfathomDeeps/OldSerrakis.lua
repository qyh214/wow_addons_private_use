local mod	= DBM:NewMod("OldSerrakis", "DBM-Party-Vanilla", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(4830)
mod:SetEncounterID(2765)
mod:SetZone(48)

mod:RegisterCombat("combat")
