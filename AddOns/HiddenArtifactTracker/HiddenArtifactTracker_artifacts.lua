HiddenArtifactTrackerFuncs={}

--Unholy
HiddenArtifactTrackerFuncs["Apocalypse"] =
	function()

		local r,g,b=1,1,1

		local y,z
		 _,_,_,y,z = GetAchievementCriteriaInfo(11231,1)
		if HiddenArtifactTracker.colourOptions then
			r=math.min(1,2-(2*y/z)); g=math.min(1,2*y/z); b=0
		end

		GameTooltip:AddLine("\nSummoned ghouls: "..y.."/"..z,r,g,b);
	end

--havoc
HiddenArtifactTrackerFuncs["Twinblades of the Deceiver"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(5)
	end


--balance
HiddenArtifactTrackerFuncs["Scythe of Elune"] =
	function()
		HiddenArtifactTrackerFuncs.RepCheck(1883, 8) --dreamweavers to exalted
	end

--Feral
HiddenArtifactTrackerFuncs["Fangs of Ashamane"] = 
	function()

			local r,g,b
			HiddenArtifactTrackerFuncs.getAK(4)

			HiddenArtifactTrackerFuncs.CheckQuest(44326, "Check the Emerald Dreamway", nil)

			local feral_quests = {{"Feralas", 44331, 44327}, {"Hinterlands", 44332, 44328}, {"Duskwood", 44330, 44329}}
			for i=1,3 do
				if IsQuestFlaggedCompleted(feral_quests[i][2]) then
					r = not HiddenArtifactTracker.colourOptions and 1 or 0.5
					g = 1
					b = not HiddenArtifactTracker.colourOptions and 1 or 0.5
					GameTooltip:AddLine(feral_quests[i][1].." Stone: Complete",r,g,b)
				else
					if IsQuestFlaggedCompleted(feral_quests[i][3]) then
						r = 1; g=1
						b = not HiddenArtifactTracker.colourOptions and 1 or 0
						GameTooltip:AddLine(feral_quests[i][1].." Stone: ACTIVE",r,g,b)
					else
						r = 1
						g = not HiddenArtifactTracker.colourOptions and 1 or 0
						b = not HiddenArtifactTracker.colourOptions and 1 or 0
						GameTooltip:AddLine(feral_quests[i][1].." Stone: Incomplete",r,g,b)
					end
				end
			end
	end

--guardian
HiddenArtifactTrackerFuncs["Claws of Ursoc"] = 
	function()
		HiddenArtifactTrackerFuncs.BossLockouts("The Emerald Nightmare", 1288, "Ursoc", 1) 
	end

--marksmanship
HiddenArtifactTrackerFuncs["Thas'dorah, Legacy of the Windrunners"] =
	function()
		HiddenArtifactTrackerFuncs.RepCheck(1900, 7) --Court of Farondis to revered
	end

--survival
HiddenArtifactTrackerFuncs["Talonclaw"] =
	function()
		HiddenArtifactTrackerFuncs.BossLockouts("The Emerald Nightmare", 1288, "Ursoc", 1) 
	end

--arcane
HiddenArtifactTrackerFuncs["Aluneth"] =
	function()

		HiddenArtifactTrackerFuncs.CheckQuest(43787, "Polymorph a Cliffwing Hippogryph in Azsuna", nil)
		HiddenArtifactTrackerFuncs.CheckQuest(43788, "Polymorph a Highpeak Goat in Highmountain", nil)
		HiddenArtifactTrackerFuncs.CheckQuest(43789, "Polymorph a Plains Runehorn Calf in Stormheim", nil)
		HiddenArtifactTrackerFuncs.CheckQuest(43790, "Polymorph a Wild Dreamrunner in Val'sharah", nil)
		HiddenArtifactTrackerFuncs.CheckQuest(43791, "Polymorph a Heartwood Doe in Suramar", nil)

		HiddenArtifactTrackerFuncs.getAK(6)
		HiddenArtifactTrackerFuncs.CheckQuest(43828, "Check class-hall for sheep event", nil)
	end

--fire
HiddenArtifactTrackerFuncs["Felo'melorn"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(5)
	end
HiddenArtifactTrackerFuncs["Heart of the Phoenix"] = HiddenArtifactTrackerFuncs["Felo'melorn"]

--frost
HiddenArtifactTrackerFuncs["Ebonchill"] = 
	function()
		HiddenArtifactTrackerFuncs.CheckQuest(44384, "Check class-hall portal room", nil)
	end

--mistweaver
HiddenArtifactTrackerFuncs["Sheilun, Staff of the Mists"] = 
	function()
		HiddenArtifactTrackerFuncs.BossLockouts("The Emerald Nightmare", 1288, "Dragons of Nightmare", 2) 
	end

--holy (paladin)
HiddenArtifactTrackerFuncs["The Silver Hand"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(5)
	end
HiddenArtifactTrackerFuncs["Tome of the Silver Hand"] = HiddenArtifactTrackerFuncs["The Silver Hand"]

--retribution
HiddenArtifactTrackerFuncs["Ashbringer"] =
	function()

		--track questline?
		HiddenArtifactTrackerFuncs.getAK(6)
	end

--discipline
HiddenArtifactTrackerFuncs["Light's Wrath"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(4)

		HiddenArtifactTrackerFuncs.CheckQuest(44339, "Book 1 not read", "Book 1 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44340, "Book 2 not read", "Book 2 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44341, "Book 3 not read", "Book 3 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44342, "Book 4 not read", "Book 4 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44343, "Book 5 not read", "Book 5 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44344, "Book 6 not read", "Book 6 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44345, "Book 7 not read", "Book 7 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44346, "Book 8 not read", "Book 8 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44347, "Book 9 not read", "Book 9 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44348, "Book 10 not read", "Book 10 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44349, "Book 11 not read", "Book 11 read")
		HiddenArtifactTrackerFuncs.CheckQuest(44350, "Book 12 not read", "Book 12 read")
	end

--holy (priest)
HiddenArtifactTrackerFuncs["T'uure, Beacon of the Naaru"] =
	function()
		HiddenArtifactTrackerFuncs.RepCheck(1948, 8) --Valarjar to exalted
	end

--shadow
HiddenArtifactTrackerFuncs["Xal'atath, Blade of the Black Empire"] = 
	function()
		HiddenArtifactTrackerFuncs.BossLockouts("The Emerald Nightmare", 1287, "Il'gynoth, The Heart of Corruption", 2) 
	end
HiddenArtifactTrackerFuncs["Secrets of the Void"] = HiddenArtifactTrackerFuncs["Xal'atath, Blade of the Black Empire"]	

--assassination
HiddenArtifactTrackerFuncs["The Kingslayers"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(4)
	end

--elemental
HiddenArtifactTrackerFuncs["The Fist of Ra-den"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(4)
	end
HiddenArtifactTrackerFuncs["The Highkeeper's Ward"] = HiddenArtifactTrackerFuncs["The Fist of Ra-den"]

--Demonology
HiddenArtifactTrackerFuncs["Skull of the Man'ari"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(4)
	--track heads?
	end
HiddenArtifactTrackerFuncs["Spine of Thal'kiel"] = HiddenArtifactTrackerFuncs["Skull of the Man'ari"]

--fury
HiddenArtifactTrackerFuncs["Warswords of the Valarjar"] =
	function()
		HiddenArtifactTrackerFuncs.RepCheck(1948, 8) --Valarjar to exalted
		HiddenArtifactTrackerFuncs.getWorldBossQ("Nithogg", 42270, 1017) -- Nithogg / questnumber / in Stormheim
		HiddenArtifactTrackerFuncs.getWorldBossQ("Shar'thos", 42779, 1018) --Shar'thos / quest number / in val'sharah
	end

--protection (warrior)
HiddenArtifactTrackerFuncs["Scale of the Earth-Warder"] =
	function()
		HiddenArtifactTrackerFuncs.getAK(5)
		
		if IsQuestFlaggedCompleted(44311) then
			local r = HiddenArtifactTracker.colourOptions and 0 or 1
			local g = 1
			local b = HiddenArtifactTracker.colourOptions and 0 or 1
			GameTooltip:AddLine("Visit Neltharion's Vault in Highmountain (not Lair!).", r,g,b)
		end
	end
HiddenArtifactTrackerFuncs["Scaleshard"] = HiddenArtifactTrackerFuncs["Scale of the Earth-Warder"]

-- utility functions
function HiddenArtifactTrackerFuncs.getWorldBossQ(name, qNumber, zNumber)

	SetMapByID(1007)
	local a=C_TaskQuest.GetQuestsForPlayerByMapID(zNumber)

	for i,j in ipairs(a) do
		if j.questId == qNumber then
			local r = HiddenArtifactTracker.colourOptions and 0 or 1
			local g = 1
			local b = HiddenArtifactTracker.colourOptions and 0 or 1
			GameTooltip:AddLine("World Boss "..name.." is available!",r,g,b)
			return
		end
	end
	
	local r = 1
	local g = HiddenArtifactTracker.colourOptions and 0 or 1
	local b = HiddenArtifactTracker.colourOptions and 0 or 1
	GameTooltip:AddLine("World Boss "..name.." is NOT available.",r,g,b)

end

function HiddenArtifactTrackerFuncs.getBossAvailability(rName, bName, bDiff)

	local getInst, getBoss = GetSavedInstanceInfo, GetSavedInstanceEncounterInfo

	local i,j=0,0
	local name, numEncounters, diff, locked, killed

	while i~=GetNumSavedInstances() and (name ~= rName or diff~= bDiff) do
		i=i+1
		name, _, _, diff, locked ,_ , _, _, _, _, numEncounters, _ = getInst(i)
	end

	--if the while loop is exhausted without finding the raid at the right difficulty
	-- or it was found but the raid is not locked then player cannot be locked to the boss
	if name~=rName or diff~=bDiff or locked==false then 
		return false
	end

	--if the raid was found to be locked, check through each boss in that encounter
	while j~=numEncounters and name ~= bName do
		j=j+1
		name, _, killed,_ = getBoss(i,j)
	end

	if name~=bName then
		print("(HiddenArtifactTracker) Boss "..bName.." was not found in raid "..rName..". Please report this error.")
	end

	return killed
end

function HiddenArtifactTrackerFuncs.BossLockouts(raid, raidID, boss, bossID)
		local r,g,b=1,1,1

		local killed

		_, _, killed, _ = GetLFGDungeonEncounterInfo(raidID, bossID)
		if not killed then
			if HiddenArtifactTracker.colourOptions then
				r,g,b=0,1,0
			end
			GameTooltip:AddLine("\n"..boss.." is available in LFR",r,g,b)
		else
			if HiddenArtifactTracker.colourOptions then
				r,g,b=1,0,0
			end
			GameTooltip:AddLine("\nYou are locked on "..boss.." in LFR",r,g,b)
		end

		--everything else
		local difficulty={[14]="Normal", [15]="Heroic", [16]="Mythic"}
		for i = 14,16 do
			killed = HiddenArtifactTrackerFuncs.getBossAvailability(raid, boss, i)
			if not killed then
				if HiddenArtifactTracker.colourOptions then
					r,g,b=0,1,0
				end
				GameTooltip:AddLine(boss.." is available in "..difficulty[i],r,g,b)
			else
				if HiddenArtifactTracker.colourOptions then
					r,g,b=1,0,0
				end
				GameTooltip:AddLine("You are locked on "..boss.." in "..difficulty[i],r,g,b)
			end
		end
	end

function HiddenArtifactTrackerFuncs.getAK(threshold)

		local name, amount = GetCurrencyInfo(1171)	--Artifact knowledge	
		local r,g,b=1,1,1

		if HiddenArtifactTracker.colourOptions and amount <threshold then
			r,g,b = 1,0,0
		elseif HiddenArtifactTracker.colourOptions then
			r,g,b = 0,1,0
		end
		
		GameTooltip:AddLine("\n"..name..": "..amount.."/"..threshold,r,g,b)
end

function HiddenArtifactTrackerFuncs.RepCheck(faction, level)

		local name, _, standingID, _, _, value = GetFactionInfoByID(faction)
		local standing = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
		standingLvls = {0,0,0,0, 3000, 9000, 21000, 42000}
		local r,g,b=1,1,1

		if HiddenArtifactTracker.colourOptions then
			r = math.min(1, 2 - 2*value/standingLvls[level])
			g = math.min(1, 2*value/standingLvls[level])
			b = (level < standingID) and 0.5 or 0
		end
		GameTooltip:AddLine("\n"..name..": "..value.."/"..standingLvls[level].." ("..standing[standingID].."/"..standing[level]..")", r,g,b)
end

function HiddenArtifactTrackerFuncs.CheckQuest(id, promptStringF, promptStringT)
			if promptStringF ~=nil and not IsQuestFlaggedCompleted(id) then
				if HiddenArtifactTracker.colourOptions then
					GameTooltip:AddLine(promptStringF, 1,1,0)
				else
					GameTooltip:AddLine(promptStringF, 1,1,1)
				end
			end

			if promptStringT ~=nil and IsQuestFlaggedCompleted(id) then
				if HiddenArtifactTracker.colourOptions then
					GameTooltip:AddLine(promptStringT, 0,1,0)
				else
					GameTooltip:AddLine(promptStringT, 1,1,1)
				end
			end
	end