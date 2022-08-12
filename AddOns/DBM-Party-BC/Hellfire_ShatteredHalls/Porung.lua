local mod	= DBM:NewMod(728, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("20200912133955")
mod:SetCreatureID(20923)
mod:SetEncounterID(1935)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
