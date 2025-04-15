local W, F, L = unpack(select(2, ...))
local MH = W:NewModule("MDTHelper", "AceHook-3.0", "AceEvent-3.0")

local _G = _G

local pairs = pairs

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local currentPatchMaps = {
	[115] = true, -- Priory of the Sacred Flame (TWW S2)
	[116] = true, -- Cinderbrew Meadery (TWW S2)
	[117] = true, -- Darkflame Cleft (TWW S2)
	[118] = true, -- TheRookery (TWW S2)
	[119] = true, -- OperationFloodgate (TWW S2)
	[120] = true, -- The MOTHERLODE!! (TWW S2)
	[121] = true, -- Theater of Pain (TWW S2)
	[122] = true, -- MechagonWorkshop (TWW S2)
}

-- NPC Blacklist
local npcBlacklist = {
	[220003] = true, -- Hollows Resident (Eye of Queen) City of Threads
	[555555] = true, -- Unknown NPC
}

function MH:Translate()
	if not self.db or not self.db.enable or not self.db.translate then
		return
	end

	local MDT = _G.MDT

	if not MDT or not MDT.dungeonEnemies or not MDT.L then
		return
	end

	for mapID, NPCs in pairs(MDT.dungeonEnemies) do
		if mapID and currentPatchMaps[mapID] and NPCs then
			for _, NPC in pairs(NPCs) do
				if NPC.id and NPC.name and not npcBlacklist[NPC.id] then
					F.HandleNPCNameByID(NPC.id, function(name)
						MDT.L[NPC.name] = name
					end)
				end
			end
		end
	end
end

function MH:ProfileUpdate()
	self.db = W.db.mdtHelper

	if not self.db or not self.db.enable then
		return
	end

	if C_AddOns_IsAddOnLoaded("MythicDungeonTools") then
		self:Translate()
	else
		self:RegisterEvent("ADDON_LOADED", "Translate")
	end
end

MH.OnInitialize = MH.ProfileUpdate
