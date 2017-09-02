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

-- they used to need each dungeon seperately, this seems to have changed to just any 10; keep until live
--				["Assault on Violet Hold"]=false,
--				["Black Rook Hold"]=false,
--				["Cathedral of Eternal Night"]=false,
--				["Court of Stars"]=false,
--				["Darkheart Thicket"]=false,
--				["Eye of Azshara"]=false,
--				["Halls of Valor"]=false,
--				["Maw of Souls"]=false,
--				["Neltharion's Lair"]=false,
--				["Return to Karazhan"]=false,
--				["The Arcway"]=false,
--				["Vault of the Wardens"]=false
			};

	if v[3] ~= nil then -- if there's a companion weapon with the artifact, it should point at the main weapon
		HiddenArtifactTrackerChars[v[3]] = HiddenArtifactTrackerChars[v[2]]
	end
end

CreateFrame("Button","HiArtTra",UIParent,"SecureHandlerClickTemplate,SecureHandlerStateTemplate")
HiArtTra:RegisterEvent("BOSS_KILL")

HiArtTra:SetScript("OnEvent", function(self,event,id,name) HiddenArtifactTrackerFuncs.doBossKill(name) end);

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
			if IsQuestFlaggedCompleted(v[1]) then
				HiddenArtifactTrackerChars[v[2]].completion = HiddenArtifactTrackerChars[v[2]].completion + 1 
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
			if IsQuestFlaggedCompleted(v[1]) then
				HiddenArtifactTrackerChars[v[2]].completion = HiddenArtifactTrackerChars[v[2]].completion - 1 
			end
		end
	end
		
end