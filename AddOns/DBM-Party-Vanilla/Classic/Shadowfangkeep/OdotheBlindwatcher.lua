local mod	= DBM:NewMod("OdotheBlindwatcher", "DBM-Party-Vanilla", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(4279)
mod:SetZone(33)

mod:RegisterCombat("combat")
