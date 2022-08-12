local mod	= DBM:NewMod(568, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("20200912133955")
mod:SetCreatureID(16809)
mod:SetEncounterID(1937)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
