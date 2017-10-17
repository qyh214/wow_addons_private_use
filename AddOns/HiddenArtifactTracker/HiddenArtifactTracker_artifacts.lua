if HiddenArtifactTrackerFuncs == nil then HiddenArtifactTrackerFuncs={} end

--Blood
HiddenArtifactTrackerFuncs["Maw of the Damned"] = 
	function()
		HiddenArtifactTrackerFuncs.getWorldBossQ(true,"Withered Training", 43943, 1033) -- Withered Training / questnumber / in Suramar
	end

--Frost (DK)
HiddenArtifactTrackerFuncs["Blades of the Fallen Prince"] = 
	function()
		HiddenArtifactTrackerFuncs.getWorldBossQ(true,"World Boss: Soultakers", 42269, 1017) -- Soultakers / questnumber / in Stormheim
	end

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
		HiddenArtifactTrackerFuncs.CheckQuest(43828, "Check class-hall for sheep event", nil)
	end

--fire
HiddenArtifactTrackerFuncs["Felo'melorn"] =
	function()
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

--windwalker
HiddenArtifactTrackerFuncs["Fists of the Heavens"] = 
	function()
		GameTooltip:AddLine(" ")
		HiddenArtifactTrackerFuncs.getWorldBossQ(true,"Withered Training", 43943, 1033) -- Withered Training / questnumber / in Suramar
	end

--holy (paladin)
HiddenArtifactTrackerFuncs["The Silver Hand"] =
	function()
	end
HiddenArtifactTrackerFuncs["Tome of the Silver Hand"] = HiddenArtifactTrackerFuncs["The Silver Hand"]

--protection
HiddenArtifactTrackerFuncs["Truthguard"] = 
	function()
		GameTooltip:AddLine(" ")
		HiddenArtifactTrackerFuncs.getWorldBossQ(true,"Withered Training", 43943, 1033) -- Withered Training / questnumber / in Suramar
	end
HiddenArtifactTrackerFuncs["Oathseeker"] = HiddenArtifactTrackerFuncs["Truthguard"]

--retribution
HiddenArtifactTrackerFuncs["Ashbringer"] =
	function()
	end

--discipline
HiddenArtifactTrackerFuncs["Light's Wrath"] =
	function()
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
	end

--outlaw
HiddenArtifactTrackerFuncs["The Dreadblades"] =
	function()
	end

--elemental
HiddenArtifactTrackerFuncs["The Fist of Ra-den"] =
	function()
	end
HiddenArtifactTrackerFuncs["The Highkeeper's Ward"] = HiddenArtifactTrackerFuncs["The Fist of Ra-den"]

--enhancement
HiddenArtifactTrackerFuncs["Doomhammer"] = 
	function()
		GameTooltip:AddLine(" ")
		HiddenArtifactTrackerFuncs.getWorldBossQ(true,"World Boss: Flotsam", 43985, 1024) --1024 = highmountain
		HiddenArtifactTrackerFuncs.getWorldBossQ(true,"World Boss: Levantus", 43192, 1015) --1015 = azsuna
		GameTooltip:AddLine(" ")
		HiddenArtifactTrackerFuncs.BossLockouts("Trial of Valor", 1411, "Helya", 3)
	end
HiddenArtifactTrackerFuncs["Fury of the Stonemother"] = HiddenArtifactTrackerFuncs["Doomhammer"]

--affliction
HiddenArtifactTrackerFuncs["Ulthalesh, the Deadwind Harvester"] =
	function()

		--as requested by jetah! using comments from http://www.wowhead.com/quest=44083/the-grimoire-of-the-first-necrolyte#comments
			GameTooltip:AddLine(" ")
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Fjorlag", 42806 ,1017)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Captain Dargun",42864,1017)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Rulf Bonesnapper",42963,1017)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Lagertha",42964,1017)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Runeseer Sigvid",42991,1017)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Soulbinder Halldora",42953,1017)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Stormheim: Aegir Wavecrusher",42820,1017)

			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Azsuna: Mortiferous",43027,1015)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Azsuna: Lysanis Shadesoul",44192,1015)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Azsuna: Jade Darkhaven",44190,1015)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Azsuna: Chief Treasurer Jabrill",43121,1015)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Azsuna: Sea King Tidross",44193,1015)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Azsuna: Valakar the Thirsty",43040,1015)

			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Highmountain: Ormagrogg",41703,1024)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Highmountain: Durguth",41,1024)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Highmountain: Oubdob da Smasher",41816,1024)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Highmountain: Olokk the Shipbreaker",41686,1024)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Highmountain: Defilia",41695,1024)

			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Suramar: Magistrix Vilessa",44114,1033)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Suramar: Auditor Esiel",44118,1033)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Suramar: Az'jatar",44121,1033)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Suramar: Apothecary Faldren",44032,1033)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Suramar: Colerian, Alteria, and Selenyi - Outrider Trio",41697,1033)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Suramar: Sorallus",44122,1033)

			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Kathaw the Savage",42870,1018)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Malisandra",42927,1018)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Ealdis",43346,1018)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Rabxach",43347,1018)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Shalas'aman",41700,1018)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Aodh Witherpetal",43344,1018)
			HiddenArtifactTrackerFuncs.getWorldBossQ(false,"Val'sharah: Witchdoctor Grgl-Brgl",43101,1018)
	end

--Demonology
HiddenArtifactTrackerFuncs["Skull of the Man'ari"] =
	function()
	--track heads?
	end
HiddenArtifactTrackerFuncs["Spine of Thal'kiel"] = HiddenArtifactTrackerFuncs["Skull of the Man'ari"]

--arms
HiddenArtifactTrackerFuncs["Strom'kar, the Warbreaker"] =
	function()
	end
--fury
HiddenArtifactTrackerFuncs["Warswords of the Valarjar"] =
	function()
		if HiddenArtifactTrackerFuncs.RepCheck(1948, 8) then --Valarjar to exalted
			HiddenArtifactTrackerFuncs.getWorldBossQ(true,"World Boss: Nithogg", 42270, 1017) -- Nithogg / questnumber / in Stormheim
			HiddenArtifactTrackerFuncs.getWorldBossQ(true,"World Boss: Shar'thos", 42779, 1018) --Shar'thos / quest number / in val'sharah
			GameTooltip:AddLine(" ")
			HiddenArtifactTrackerFuncs.BossLockouts("Trial of Valor", 1411, "Odyn", 1) 
		end
	end

--protection (warrior)
HiddenArtifactTrackerFuncs["Scale of the Earth-Warder"] =
	function()
				
			if IsQuestFlaggedCompleted(44311) then
				local r = HiddenArtifactTracker.colourOptions and 0 or 1
				local g = 1
				local b = HiddenArtifactTracker.colourOptions and 0 or 1
				GameTooltip:AddLine("Hidden appearance successfully rolled!", r,g,b)
			elseif IsQuestFlaggedCompleted(44312) then
				local r = 1
				local g = HiddenArtifactTracker.colourOptions and 0 or 1
				local b = HiddenArtifactTracker.colourOptions and 0 or 1
				GameTooltip:AddLine("Hidden appearance event did not roll today.", r,g,b)
			else
				local r = HiddenArtifactTracker.colourOptions and 0.5 or 1
				local g = HiddenArtifactTracker.colourOptions and 0.5 or 1
				local b = 1
				GameTooltip:AddLine("Visit Neltharion's Vault in Highmountain (not Lair!).", r,g,b)
			end
	end
HiddenArtifactTrackerFuncs["Scaleshard"] = HiddenArtifactTrackerFuncs["Scale of the Earth-Warder"]

-- utility functions
function HiddenArtifactTrackerFuncs.getWorldBossQ(showNeg,name, qNumber, zNumber)

	SetMapByID(1007)
	local a=C_TaskQuest.GetQuestsForPlayerByMapID(zNumber)

	for i,j in ipairs(a) do
		if j.questId == qNumber then
			local r = HiddenArtifactTracker.colourOptions and 0 or 1
			local g = 1
			local b = HiddenArtifactTracker.colourOptions and 0 or 1
			GameTooltip:AddLine(name.." is available!",r,g,b)
			return
		end
	end
	
	if showNeg then
		local r = 1
		local g = HiddenArtifactTracker.colourOptions and 0 or 1
		local b = HiddenArtifactTracker.colourOptions and 0 or 1
		GameTooltip:AddLine(name.." is NOT available.",r,g,b)
	end
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

		return amount >= threshold
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

		return standingID >= level
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