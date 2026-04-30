local mod	= DBM:NewMod("JandiceBarov", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10503)
mod:SetEncounterID(mod:IsClassic() and 2804 or 452)
mod:SetZone(289)

mod:RegisterCombat("combat")
