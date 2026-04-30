-- By D4KiR
local _, SpecBisTooltip = ...
local C_Seasons = getglobal("C_Seasons")
function SpecBisTooltip:AddToSOD(class, specid, tab)
	if tab then
		for i, v in pairs(tab) do
			if SpecBisTooltip:GetBisTable()["CLASSIC"][class][specid][i] == nil then
				SpecBisTooltip:GetBisTable()["CLASSIC"][class][specid][i] = v
			end
		end
	end
end

if C_Seasons and C_Seasons.GetActiveSeason and C_Seasons.GetActiveSeason() == 2 then
	SpecBisTooltip:AddOldSodPhases()
end

local sortBfs = {}
sortBfs["BISO"] = 1
sortBfs["BISMR"] = 2
sortBfs["BISM"] = 3
sortBfs["BISR"] = 4
sortBfs["BIS,PVE,P6"] = 10
sortBfs["BIS,PVE,P5"] = 11
sortBfs["BIS,PVE,P4"] = 12
sortBfs["BIS,PVE,P3"] = 13
sortBfs["BIS,PVE,P2"] = 14
sortBfs["BIS,PVE,P1"] = 15
sortBfs["PREBIS,PVE,P6"] = 20
sortBfs["PREBIS,PVE,P5"] = 21
sortBfs["PREBIS,PVE,P4"] = 22
sortBfs["PREBIS,PVE,P3"] = 23
sortBfs["PREBIS,PVE,P2"] = 24
sortBfs["PREBIS,PVE,P1"] = 25
sortBfs["BIS,PREPATCH"] = 26
sortBfs["BIS,PVE,SODP8"] = 30
sortBfs["PREBIS,PVE,SODP8"] = 31
sortBfs["BIS,PVE,SODP7"] = 32
sortBfs["PREBIS,PVE,SODP7"] = 33
sortBfs["BIS,PVE,SODP6"] = 34
sortBfs["PREBIS,PVE,SODP6"] = 35
sortBfs["BIS,PVE,SODP5"] = 36
sortBfs["PREBIS,PVE,SODP5"] = 37
sortBfs["BIS,PVE,SODP4"] = 38
sortBfs["PREBIS,PVE,SODP4"] = 39
sortBfs["BIS,PVE,SODP3"] = 40
sortBfs["PREBIS,PVE,SODP3"] = 41
sortBfs["BIS,PVE,SODP2"] = 42
sortBfs["PREBIS,PVE,SODP2"] = 43
sortBfs["BIS,PVE,SODP1"] = 44
sortBfs["PREBIS,PVE,SODP1"] = 45
sortBfs["PREBIS,PVE"] = 46
sortBfs["S+"] = 60
sortBfs["S"] = 61
sortBfs["S-"] = 62
sortBfs["A+"] = 63
sortBfs["A"] = 64
sortBfs["A-"] = 65
sortBfs["B+"] = 66
sortBfs["B"] = 67
sortBfs["B-"] = 68
sortBfs["C+"] = 69
sortBfs["C"] = 70
sortBfs["C-"] = 71
sortBfs["D"] = 72
sortBfs["E"] = 73
sortBfs["F"] = 74
sortBfs["No"] = 75
sortBfs["?"] = 76
sortBfs["?????"] = 99
local bfs = {}
function SpecBisTooltip:InitBFSContent(pool, content)
	bfs[content] = {}
	if SpecBisTooltip:GetBisTable()[pool] then
		for className, classTab in pairs(SpecBisTooltip:GetBisTable()[pool]) do
			for specId, specTab in pairs(classTab) do
				if specTab[content] then
					for itemId, itemTab in pairs(specTab[content]) do
						if itemId > 100 then
							bfs[content][itemId] = bfs[content][itemId] or {}
							local found = false
							for i, v in pairs(bfs[content][itemId]) do
								if v[1] == className and v[2] == specId then
									found = true
								end
							end

							if not found then
								table.insert(bfs[content][itemId], {className, specId, itemTab})
							end
						else
							for itemId2, itemTab2 in pairs(specTab[content][itemId]) do
								bfs[content][itemId2] = bfs[content][itemId2] or {}
								local found = false
								for i, v in pairs(bfs[content][itemId2]) do
									if v[1] == className and v[2] == specId then
										found = true
									end
								end

								if not found then
									table.insert(bfs[content][itemId2], {className, specId, itemTab2})
								end
							end
						end
					end
				end
			end
		end
	end
end

function SpecBisTooltip:InitBFS()
	local pool = SpecBisTooltip:GetWoWBuild()
	if pool ~= "RETAIL" then
		if SpecBisTooltip:GetBisTable()[pool] then
			for className, classTab in pairs(SpecBisTooltip:GetBisTable()[pool]) do
				for specId, specTab in pairs(classTab) do
					for itemId, itemTyp in pairs(specTab) do
						bfs[itemId] = bfs[itemId] or {}
						table.insert(bfs[itemId], {className, specId, itemTyp})
					end
				end
			end
		end

		for i, bf in pairs(bfs) do
			table.sort(
				bf,
				function(a, b)
					if a == nil then
						SpecBisTooltip:MSG("[InitBFS] a is nil")

						return false
					end

					if b == nil then
						SpecBisTooltip:MSG("[InitBFS] b is nil")

						return false
					end

					if sortBfs[a[3][1]] == nil then
						SpecBisTooltip:MSG("MISSING SORTING KEY", a[3][1])

						return true
					end

					if sortBfs[b[3][1]] == nil then
						SpecBisTooltip:MSG("MISSING SORTING KEY", b[3][1])

						return false
					end

					if sortBfs[a[3][1]] == sortBfs[b[3][1]] then return a[1] < b[1] end

					return sortBfs[a[3][1]] < sortBfs[b[3][1]]
				end
			)
		end
	else
		SpecBisTooltip:InitBFSContent(pool, "BISO")
		SpecBisTooltip:InitBFSContent(pool, "BISR")
		SpecBisTooltip:InitBFSContent(pool, "BISM")
		SpecBisTooltip:InitBFSContent(pool, "TRINKETS")
	end
end

SpecBisTooltip:InitBFS()
function SpecBisTooltip:GetBFS(itemId)
	return bfs[itemId]
end

function SpecBisTooltip:GetBFSRetail(itemId, content)
	if bfs[content] and bfs[content][itemId] then return bfs[content][itemId] end

	return nil
end

local bfi = {}
local missingSpec = false
function SpecBisTooltip:GetBisSource(invType, class, specId, content, num, guide)
	guide = guide or false
	local n = num or 1
	if invType == nil then return nil, nil, nil end
	if specId == nil then
		local level = UnitLevel("player")
		if level >= 10 and not missingSpec then
			missingSpec = true
			SpecBisTooltip:MSG("[GetBisSource] Missing SpecId (Talents not set?)")
		end

		return nil, nil, nil
	end

	if specId == 0 or specId > 4 then
		SpecBisTooltip:MSG("[GetBisSource] NO SPEC DETECTED", specId)

		return
	end

	if bfi[class] == nil then
		bfi[class] = {}
	end

	if bfi[class][specId] == nil then
		bfi[class][specId] = {}
		local pool = SpecBisTooltip:GetWoWBuild()
		if SpecBisTooltip:GetBisTable()[pool] == nil then
			SpecBisTooltip:MSG("Missing POOL!", pool)

			return
		end

		if SpecBisTooltip:GetBisTable()[pool][class] == nil then
			SpecBisTooltip:MSG("Missing Class!", class)

			return
		end

		if SpecBisTooltip:GetBisTable()[pool][class][specId] == nil then
			SpecBisTooltip:MSG("Missing specId!", specId)

			return
		end

		for itemId, tab in pairs(SpecBisTooltip:GetBisTable()[pool][class][specId]) do
			local slot = tab[3]
			if pool == "CLASSIC" or pool == "TBC" or pool == "CATA" then
				if slot then
					if C_Seasons and C_Seasons.GetActiveSeason and C_Seasons.GetActiveSeason() == 2 then
						bfi[class][specId][slot] = bfi[class][specId][slot] or {}
						table.insert(bfi[class][specId][slot], itemId)
					else
						bfi[class][specId][slot] = bfi[class][specId][slot] or {}
						table.insert(bfi[class][specId][slot], itemId)
					end
				end
			else
				slot = tab[2]
				if type(itemId) == "string" then
					if itemId == content then
						local heroSpecID = SpecBisTooltip:GetHeroSpecId()
						if heroSpecID and SpecBisTooltip:GetBisTable()[pool][class][specId][content][heroSpecID] then
							for itemId2, tab2 in pairs(SpecBisTooltip:GetBisTable()[pool][class][specId][content][heroSpecID]) do
								slot = tab2[2]
								if slot then
									bfi[class][specId][slot] = bfi[class][specId][slot] or {}
									table.insert(bfi[class][specId][slot], itemId2)
								end
							end
						else
							for itemId2, tab2 in pairs(SpecBisTooltip:GetBisTable()[pool][class][specId][content]) do
								slot = tab2[2]
								if slot then
									bfi[class][specId][slot] = bfi[class][specId][slot] or {}
									table.insert(bfi[class][specId][slot], itemId2)
								end
							end
						end
					end
				elseif slot then
					bfi[class][specId][slot] = bfi[class][specId][slot] or {}
					table.insert(bfi[class][specId][slot], itemId)
				end
			end
		end
	end

	local custom = false
	if bfi[class][specId][invType] then
		local itemId = bfi[class][specId][invType][n]
		if not guide and SBTTABPC then
			if n and SBTTABPC[invType .. n] then
				itemId = SBTTABPC[invType .. n]
				custom = true
			elseif SBTTABPC[invType] then
				itemId = SBTTABPC[invType]
				custom = true
			end
		end

		if SpecBisTooltip:GetWoWBuild() == "RETAIL" then
			if content == nil then
				local _, sourceUrl = SpecBisTooltip:GetSpecItemTypRetail(itemId, specId, "BISO", invType)
				if sourceUrl == nil then
					_, sourceUrl = SpecBisTooltip:GetSpecItemTypRetail(itemId, specId, "BISR", invType)
					if sourceUrl == nil then
						_, sourceUrl = SpecBisTooltip:GetSpecItemTypRetail(itemId, specId, "BISM", invType)
					end
				end

				local sourceTyp, sourceName, sourceLocation = SpecBisTooltip:GetSource(sourceUrl)

				return sourceTyp, sourceName, sourceLocation, itemId, custom
			else
				local _, sourceUrl = SpecBisTooltip:GetSpecItemTypRetail(itemId, specId, content, invType)
				if sourceUrl then
					local sourceTyp, sourceName, sourceLocation = SpecBisTooltip:GetSource(sourceUrl)

					return sourceTyp, sourceName, sourceLocation, itemId, custom
				else
					return nil, nil, nil, itemId, custom
				end
			end
		else
			local _, sourceUrl = SpecBisTooltip:GetSpecItemTyp(itemId, specId, invType)
			local sourceTyp, sourceName, sourceLocation = SpecBisTooltip:GetSource(sourceUrl)

			return sourceTyp, sourceName, sourceLocation, itemId, custom
		end
	end

	return nil, nil, nil, nil, custom
end

local head = "INVTYPE_HEAD"
local shoulder = "INVTYPE_SHOULDER"
local chest = "INVTYPE_CHEST"
local hand = "INVTYPE_HAND"
local legs = "INVTYPE_LEGS"
local token = {
	["RETAIL"] = {
		-- HUNTER, MAGE, DRUID
		[237582] = {
			["HUNTER"] = chest,
			["MAGE"] = chest,
			["DRUID"] = chest
		},
		[237594] = {
			["HUNTER"] = legs,
			["MAGE"] = legs,
			["DRUID"] = legs
		},
		[237586] = {
			["HUNTER"] = hand,
			["MAGE"] = hand,
			["DRUID"] = hand
		},
		[237598] = {
			["HUNTER"] = shoulder,
			["MAGE"] = shoulder,
			["DRUID"] = shoulder
		},
		[237590] = {
			["HUNTER"] = head,
			["MAGE"] = head,
			["DRUID"] = head
		},
		-- DEATHKNIGHT, WARLOCK, DEMONHUNTER
		[237581] = {
			["DEATHKNIGHT"] = chest,
			["WARLOCK"] = chest,
			["DEMONHUNTER"] = chest
		},
		[237593] = {
			["DEATHKNIGHT"] = legs,
			["WARLOCK"] = legs,
			["DEMONHUNTER"] = legs
		},
		[237585] = {
			["DEATHKNIGHT"] = hand,
			["WARLOCK"] = hand,
			["DEMONHUNTER"] = hand
		},
		[237597] = {
			["DEATHKNIGHT"] = shoulder,
			["WARLOCK"] = shoulder,
			["DEMONHUNTER"] = shoulder
		},
		[237589] = {
			["DEATHKNIGHT"] = head,
			["WARLOCK"] = head,
			["DEMONHUNTER"] = head
		},
		-- PALADIN, PRIEST, SHAMAN
		[237583] = {
			["PALADIN"] = chest,
			["PRIEST"] = chest,
			["SHAMAN"] = chest
		},
		[237595] = {
			["PALADIN"] = legs,
			["PRIEST"] = legs,
			["SHAMAN"] = legs
		},
		[237587] = {
			["PALADIN"] = hand,
			["PRIEST"] = hand,
			["SHAMAN"] = hand
		},
		[237599] = {
			["PALADIN"] = shoulder,
			["PRIEST"] = shoulder,
			["SHAMAN"] = shoulder
		},
		[237591] = {
			["PALADIN"] = head,
			["PRIEST"] = head,
			["SHAMAN"] = head
		},
		-- WARRIOR, ROGUE, MONK, EVOKER
		[237584] = {
			["WARRIOR"] = chest,
			["ROGUE"] = chest,
			["MONK"] = chest,
			["EVOKER"] = chest
		},
		[237596] = {
			["WARRIOR"] = legs,
			["ROGUE"] = legs,
			["MONK"] = legs,
			["EVOKER"] = legs
		},
		[237588] = {
			["WARRIOR"] = hand,
			["ROGUE"] = hand,
			["MONK"] = hand,
			["EVOKER"] = hand
		},
		[237600] = {
			["WARRIOR"] = shoulder,
			["ROGUE"] = shoulder,
			["MONK"] = shoulder,
			["EVOKER"] = shoulder
		},
		[237592] = {
			["WARRIOR"] = head,
			["ROGUE"] = head,
			["MONK"] = head,
			["EVOKER"] = head
		},
	},
	["MISTS"] = {
		-- HUNTER, MAGE, DRUID
		[0] = {
			["HUNTER"] = chest,
			["MAGE"] = chest,
			["DRUID"] = chest
		},
		[1] = {
			["HUNTER"] = legs,
			["MAGE"] = legs,
			["DRUID"] = legs
		},
		[2] = {
			["HUNTER"] = hand,
			["MAGE"] = hand,
			["DRUID"] = hand
		},
		[3] = {
			["HUNTER"] = shoulder,
			["MAGE"] = shoulder,
			["DRUID"] = shoulder
		},
		[4] = {
			["HUNTER"] = head,
			["MAGE"] = head,
			["DRUID"] = head
		},
		-- DEATHKNIGHT, WARLOCK, DEMONHUNTER
		[5] = {
			["DEATHKNIGHT"] = chest,
			["WARLOCK"] = chest,
			["DEMONHUNTER"] = chest
		},
		[6] = {
			["DEATHKNIGHT"] = legs,
			["WARLOCK"] = legs,
			["DEMONHUNTER"] = legs
		},
		[7] = {
			["DEATHKNIGHT"] = hand,
			["WARLOCK"] = hand,
			["DEMONHUNTER"] = hand
		},
		[8] = {
			["DEATHKNIGHT"] = shoulder,
			["WARLOCK"] = shoulder,
			["DEMONHUNTER"] = shoulder
		},
		[9] = {
			["DEATHKNIGHT"] = head,
			["WARLOCK"] = head,
			["DEMONHUNTER"] = head
		},
		-- PALADIN, PRIEST, SHAMAN
		[10] = {
			["PALADIN"] = chest,
			["PRIEST"] = chest,
			["SHAMAN"] = chest
		},
		[11] = {
			["PALADIN"] = legs,
			["PRIEST"] = legs,
			["SHAMAN"] = legs
		},
		[12] = {
			["PALADIN"] = hand,
			["PRIEST"] = hand,
			["SHAMAN"] = hand
		},
		[13] = {
			["PALADIN"] = shoulder,
			["PRIEST"] = shoulder,
			["SHAMAN"] = shoulder
		},
		[14] = {
			["PALADIN"] = head,
			["PRIEST"] = head,
			["SHAMAN"] = head
		},
		-- WARRIOR, ROGUE, MONK, EVOKER
		[15] = {
			["WARRIOR"] = chest,
			["ROGUE"] = chest,
			["MONK"] = chest,
			["EVOKER"] = chest
		},
		[16] = {
			["WARRIOR"] = legs,
			["ROGUE"] = legs,
			["MONK"] = legs,
			["EVOKER"] = legs
		},
		[17] = {
			["WARRIOR"] = hand,
			["ROGUE"] = hand,
			["MONK"] = hand,
			["EVOKER"] = hand
		},
		[18] = {
			["WARRIOR"] = shoulder,
			["ROGUE"] = shoulder,
			["MONK"] = shoulder,
			["EVOKER"] = shoulder
		},
		[19] = {
			["WARRIOR"] = head,
			["ROGUE"] = head,
			["MONK"] = head,
			["EVOKER"] = head
		},
	},
	["CLASSIC"] = {
		-- HUNTER, MAGE, DRUID
		[0] = {
			["HUNTER"] = chest,
			["MAGE"] = chest,
			["DRUID"] = chest
		},
		[1] = {
			["HUNTER"] = legs,
			["MAGE"] = legs,
			["DRUID"] = legs
		},
		[2] = {
			["HUNTER"] = hand,
			["MAGE"] = hand,
			["DRUID"] = hand
		},
		[3] = {
			["HUNTER"] = shoulder,
			["MAGE"] = shoulder,
			["DRUID"] = shoulder
		},
		[4] = {
			["HUNTER"] = head,
			["MAGE"] = head,
			["DRUID"] = head
		},
		-- DEATHKNIGHT, WARLOCK, DEMONHUNTER
		[5] = {
			["DEATHKNIGHT"] = chest,
			["WARLOCK"] = chest,
			["DEMONHUNTER"] = chest
		},
		[6] = {
			["DEATHKNIGHT"] = legs,
			["WARLOCK"] = legs,
			["DEMONHUNTER"] = legs
		},
		[7] = {
			["DEATHKNIGHT"] = hand,
			["WARLOCK"] = hand,
			["DEMONHUNTER"] = hand
		},
		[8] = {
			["DEATHKNIGHT"] = shoulder,
			["WARLOCK"] = shoulder,
			["DEMONHUNTER"] = shoulder
		},
		[9] = {
			["DEATHKNIGHT"] = head,
			["WARLOCK"] = head,
			["DEMONHUNTER"] = head
		},
		-- PALADIN, PRIEST, SHAMAN
		[10] = {
			["PALADIN"] = chest,
			["PRIEST"] = chest,
			["SHAMAN"] = chest
		},
		[11] = {
			["PALADIN"] = legs,
			["PRIEST"] = legs,
			["SHAMAN"] = legs
		},
		[12] = {
			["PALADIN"] = hand,
			["PRIEST"] = hand,
			["SHAMAN"] = hand
		},
		[13] = {
			["PALADIN"] = shoulder,
			["PRIEST"] = shoulder,
			["SHAMAN"] = shoulder
		},
		[14] = {
			["PALADIN"] = head,
			["PRIEST"] = head,
			["SHAMAN"] = head
		},
		-- WARRIOR, ROGUE, MONK, EVOKER
		[15] = {
			["WARRIOR"] = chest,
			["ROGUE"] = chest,
			["MONK"] = chest,
			["EVOKER"] = chest
		},
		[16] = {
			["WARRIOR"] = legs,
			["ROGUE"] = legs,
			["MONK"] = legs,
			["EVOKER"] = legs
		},
		[17] = {
			["WARRIOR"] = hand,
			["ROGUE"] = hand,
			["MONK"] = hand,
			["EVOKER"] = hand
		},
		[18] = {
			["WARRIOR"] = shoulder,
			["ROGUE"] = shoulder,
			["MONK"] = shoulder,
			["EVOKER"] = shoulder
		},
		[19] = {
			["WARRIOR"] = head,
			["ROGUE"] = head,
			["MONK"] = head,
			["EVOKER"] = head
		},
	}
}

function SpecBisTooltip:GetTokenTable()
	return token
end

function SpecBisTooltip:CheckIfSetItem(id)
	if id and select(16, SpecBisTooltip:GetItemInfo(id)) then return id end

	return nil
end

function SpecBisTooltip:GetSlotBis(class, specId, invType, typ)
	if SpecBisTooltip:GetBisTable()[SpecBisTooltip:GetWoWBuild()][class] == nil then return end
	if SpecBisTooltip:GetBisTable()[SpecBisTooltip:GetWoWBuild()][class][specId] == nil then return end
	if SpecBisTooltip:GetBisTable()[SpecBisTooltip:GetWoWBuild()][class][specId][typ] == nil then return end
	for id, tab in pairs(SpecBisTooltip:GetBisTable()[SpecBisTooltip:GetWoWBuild()][class][specId][typ]) do
		if tab[2] == invType then return id end
	end
end

function SpecBisTooltip:IsBisToken(class, specId, id)
	local invType = nil
	local pool = SpecBisTooltip:GetWoWBuild()
	local tab = SpecBisTooltip:GetTokenTable()
	if tab and tab[pool] and tab[pool][id] and tab[pool][id][class] then
		invType = tab[pool][id][class]
		local bisItem1 = SpecBisTooltip:CheckIfSetItem(SpecBisTooltip:GetSlotBis(class, specId, invType, "BISO"))
		local bisItem2 = SpecBisTooltip:CheckIfSetItem(SpecBisTooltip:GetSlotBis(class, specId, invType, "BISR"))
		local bisItem3 = SpecBisTooltip:CheckIfSetItem(SpecBisTooltip:GetSlotBis(class, specId, invType, "BISM"))
		if bisItem1 or bisItem2 or bisItem3 then
			return bisItem1, bisItem2, bisItem3
		else
			return id
		end
	end

	return nil
end
