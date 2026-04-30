local mod	= DBM:NewMod("KamDeepfury", "DBM-Party-Vanilla", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(1666)
mod:SetZone(34)

mod:RegisterCombat("combat")
