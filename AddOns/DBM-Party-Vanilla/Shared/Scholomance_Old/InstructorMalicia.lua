local mod	= DBM:NewMod("InstructorMalicia", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10505)
mod:SetEncounterID(mod:IsClassic() and 2803 or 457)
mod:SetZone(289)

mod:RegisterCombat("combat")
