if HiddenArtifactTrackerFuncs == nil then HiddenArtifactTrackerFuncs={} end
if HiddenArtifactTrackerChars == nil then HiddenArtifactTrackerChars ={} end
--DATA
local classWeaponQuests = {			--maps classes and their weapons to available mage tower quests {questID, artifact name, [companion weapon]}
	[1]={	{44925, "Strom'kar, the Warbreaker"},
		{46065, "Warswords of the Valarjar"},
		{45416, "Scale of the Earth-Warder","Scaleshard"}
		},	--warrior
	[2]={	{46035, "The Silver Hand","Tome of the Silver Hand"},
		{45416, "Truthguard","Oathseeker"},
		{45526, "Ashbringer"}
		},	--paladin
	[3]={
		{45627, "Titanstrike"},
		{46127, "Thas'dorah, Legacy of the Windrunners"},
		{44925, "Talonclaw"}
		},	--hunter
	[4]={
		{45526, "The Kingslayers"},
		{46065, "The Dreadblades"},
		{44925, "Fangs of the Devourer"}
		},	--rogue
	[5]={
		{45627, "Light's Wrath"},
		{46035, "T'uure, Beacon of the Naaru"},
		{46127, "Xal'atath, Blade of the Black Empire","Secrets of the Void"}
		},	--priest
	[6]={
		{45416,"Maw of the Damned"},
		{44925,"Blades of the Fallen Prince"},
		{46065, "Apocalypse"}
		},	--death knight
	[7]={
		{46065, "The Fist of Ra-den","The Highkeeper's Ward"},
		{45526, "Doomhammer","Fury of the Stonemother"},
		{46035, "Sharas'dal, Scepter of Tides","Shield of the Sea Queen"}
		},	--shaman
	[8]={
		{45526, "Aluneth"},
		{46065, "Felo'melorn","Heart of the Phoenix"},
		{46127, "Ebonchill"}
		},	--mage
	[9]={
		{46127, "Ulthalesh, the Deadwind Harvester"},
		{45526, "Skull of the Man'ari","Spine of Thal'kiel"},
		{45627, "Scepter of Sargeras"}
		},	--warlock
	[10]={
		{45416, "Fu Zan, the Wanderer's Companion"},
		{46035, "Sheilun, Staff of the Mists"},
		{45627, "Fists of the Heavens"}
		},	--monk
	[11]={
		{46127, "Scythe of Elune"},
		{46065, "Fangs of Ashamane"},
		{45416, "Claws of Ursoc"},
		{46035, "G'Hanir, the Mother Tree"}
		},	--druid
	[12]={
		{44925, "Twinblades of the Deceiver"},
		{45416, "Aldrachi Warblades"}
		}		--demon hunter
	}

--initialise save tables per mage challenge
local _,_,classID = UnitClass("player")
for k,v in ipairs(classWeaponQuests[classID]) do
	HiddenArtifactTrackerChars[v[2]] = {
				["completion"]=0,
				["quest"]=v[1],
				["rbg"]=nil,
				["Assault on Violet Hold"]=false,
				["Black Rook Hold"]=false,
				["Cathedral of Eternal Night"]=false,
				["Court of Stars"]=false,
				["Darkheart Thicket"]=false,
				["Eye of Azshara"]=false,
				["Halls of Valor"]=false,
				["Maw of Souls"]=false,
				["Neltharion's Lair"]=false,
				["Lower Karazhan"]=false,
				["Return to Karazhan"]=false,
				["The Arcway"]=false,
				["Vault of the Wardens"]=false,
				["Seat of the Triumvirate"]=false
			};

	if v[3] ~= nil then -- if there's a companion weapon with the artifact, it should point at the main weapon
		HiddenArtifactTrackerChars[v[3]] = HiddenArtifactTrackerChars[v[2]]
	end
end

CreateFrame("Button","HiArtTra",UIParent,"SecureHandlerClickTemplate,SecureHandlerStateTemplate")
HiArtTra:RegisterEvent("BOSS_KILL")
HiArtTra:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

HiArtTra:SetScript("OnEvent", function(...) HiddenArtifactTrackerFuncs.event(...) end);

function HiddenArtifactTrackerFuncs.event(...)
	local arg = {...}
	local event = arg[2]

	if event == "PLAYER_ENTERING_BATTLEGROUND" then
		HiddenArtifactTrackerFuncs.enterBG()
	elseif event == "BOSS_KILL" then
		local name = arg[4]
		HiddenArtifactTrackerFuncs.doBossKill(name)
	end
end

function HiddenArtifactTrackerFuncs.enterBG()
	for k,v in ipairs(classWeaponQuests[classID]) do

		local rbgWins =  GetStatistic(5694)
		if rbgWins == "--" then rbgWins = 0 end

		--if the mage tower is done for this weapon, and you've never initialised this weapon counter before, initialise it now
		if HiddenArtifactTrackerChars[v[2]].rbg==nil and IsQuestFlaggedCompleted(v[1]) then
			HiddenArtifactTrackerChars[v[2]].rbg = rbgWins
		end
	end
end

function HiddenArtifactTrackerFuncs.doBossKill(name)

	for k,v in ipairs(classWeaponQuests[classID]) do
		if HiddenArtifactTrackerChars[v[2]]["completion"]>9 then
			classWeaponQuests[classID][k] = nil
		end
	end

	-- if classWeaponQuests table is empty, so there are no quest numbers left to track for this class, stop tracking
	if next(classWeaponQuests[classID]) == nil then
		HiArtTra:UnregisterEvent("BOSS_KILL")
		return
	end

	local bossKills = {	
			[EJ_GetEncounterInfo(1697)]="Assault on Violet Hold",		--Sael'orn
			[EJ_GetEncounterInfo(1711)]="Assault on Violet Hold",		--Fel Lord Betrug
			[EJ_GetEncounterInfo(1672)]="Black Rook Hold",			--Lord Kur'talos Ravencrest
			[EJ_GetEncounterInfo(1878)]="Cathedral of Eternal Night",	--Mephistroth
			[EJ_GetEncounterInfo(1720)]="Court of Stars",			--Advisor Melandrus
			[EJ_GetEncounterInfo(1657)]="Darkheart Thicket",		--Shade of Xavius
			[EJ_GetEncounterInfo(1492)]="Eye of Azshara",			--Wrath of Azshara
			[EJ_GetEncounterInfo(1489)]="Halls of Valor",			--Odyn
			[EJ_GetEncounterInfo(1663)]="Maw of Souls",			--Helya
			[EJ_GetEncounterInfo(1687)]="Neltharion's Lair",		--Dargrul the Underking
			[EJ_GetEncounterInfo(1838)]="Return to Karazhan",		--Viz'aduum the Watcher
			[EJ_GetEncounterInfo(1837)]="Lower Karazhan",			--Moroes
			[EJ_GetEncounterInfo(1501)]="The Arcway",			--Advisor Vandros
			[EJ_GetEncounterInfo(1470)]="Vault of the Wardens",		--Cordana Felsong
			[EJ_GetEncounterInfo(1982)]="Seat of the Triumvirate"		--L'ura
	}

	-- classWeaponQuests is now definitely not empty, so save tracking for these quest numbers
	if bossKills[name] ~= nil then
		for k,v in ipairs(classWeaponQuests[classID]) do
 			if IsQuestFlaggedCompleted(v[1]) and HiddenArtifactTrackerChars[v[2]][bossKills[name]] ~= true then
				HiddenArtifactTrackerChars[v[2]].completion = HiddenArtifactTrackerChars[v[2]].completion + 1
				HiddenArtifactTrackerChars[v[2]][bossKills[name]] = true
			end
		end
	end
		
end

-- for debugging; keep until changes to unlock criteria are confirmed on live
function HiddenArtifactTrackerFuncs.undoBossKill(name)
	for k,v in ipairs(classWeaponQuests[classID]) do
		if HiddenArtifactTrackerChars[v[2]]["completion"]>9 then
			classWeaponQuests[classID][k] = nil
		end
	end

	-- if classWeaponQuests table is empty, so there are no quest numbers left to track for this class, stop tracking
	if next(classWeaponQuests[classID]) == nil then
		HiArtTra:UnregisterEvent("BOSS_KILL")
		return
	end

	local bossKills = {	
			["Sael'orn"]="Assault on Violet Hold",
			["Fel Lord Betrug"]="Assault on Violet Hold",
			["Lord Kur'talos Ravencrest"]="Black Rook Hold",
			["Mephistroth"]="Cathedral of Eternal Night",
			["Advisor Melandrus"]="Court of Stars",
			["Shade of Xavius"]="Darkheart Thicket",
			["Wrath of Azshara"]="Eye of Azshara",
			["Odyn"]="Halls of Valor",
			["Helya"]="Maw of Souls",
			["Dargrul the Underking"]="Neltharion's Lair",
			["Viz'aduum the Watcher"]="Return to Karazhan",
			["Advisor Vandros"]="The Arcway",
			["Cordana Felsong"]="Vault of the Wardens",
			["L'ura"]="Seat of the Triumvirate"
	}

	-- classWeaponQuests is now definitely not empty, so save tracking for these quest numbers
	if bossKills[name] ~= nil then
		for k,v in ipairs(classWeaponQuests[classID]) do
			if IsQuestFlaggedCompleted(v[1]) and HiddenArtifactTrackerChars[v[2]][bossKills[name]] ~= false then
				HiddenArtifactTrackerChars[v[2]].completion = HiddenArtifactTrackerChars[v[2]].completion - 1 
				HiddenArtifactTrackerChars[v[2]][bossKills[name]] = false
			end
		end
	end
		
end

function HiddenArtifactTrackerFuncs.recoverSaveData()

	local neededKeys = {
				["completion"]=0,
				["quest"]=1,
				["rbg"]=nil,
				["Assault on Violet Hold"]=false,
				["Black Rook Hold"]=false,
				["Cathedral of Eternal Night"]=false,
				["Court of Stars"]=false,
				["Darkheart Thicket"]=false,
				["Eye of Azshara"]=false,
				["Halls of Valor"]=false,
				["Maw of Souls"]=false,
				["Neltharion's Lair"]=false,
				["Lower Karazhan"]=false,
				["Return to Karazhan"]=false,
				["The Arcway"]=false,
				["Vault of the Wardens"]=false,
				["Seat of the Triumvirate"]=false
			}

		for k,v in pairs(neededKeys) do
			for i,d in pairs(classWeaponQuests[classID]) do
				if HiddenArtifactTrackerChars[d[2]][k] == nil then
					if k~="quest" then
						HiddenArtifactTrackerChars[d[2]][k] = v
					else
						HiddenArtifactTrackerChars[d[2]][k] = d[1]
					end
				end
	
			end
		end
end

--5694
--function GetStatisticId(CategoryTitle, StatisticTitle)
--	local str = ""
--	for _, CategoryId in pairs(GetStatisticsCategoryList()) do
--		local Title, ParentCategoryId, Something
--		Title, ParentCategoryId, Something = GetCategoryInfo(CategoryId)
--		
--		if Title == CategoryTitle then
--			local i
--			local statisticCount = GetCategoryNumAchievements(CategoryId)
--			for i = 1, statisticCount do
--				local IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText
--				IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText = GetAchievementInfo(CategoryId, i)
--				if Name == StatisticTitle then
--					return IDNumber
--				end
--			end
--		end
--	end
--	return -1
--end

