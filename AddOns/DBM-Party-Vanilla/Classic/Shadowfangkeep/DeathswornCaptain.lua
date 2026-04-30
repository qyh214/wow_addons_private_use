local mod	= DBM:NewMod("DeathswornCaptain", "DBM-Party-Vanilla", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(3872)
mod:SetZone(33)

mod:RegisterCombat("combat")
