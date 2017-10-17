HiddenArtifactTracker ={}  			--options
HiddenArtifactTracker.active = true;		--turn the addon on/off
HiddenArtifactTracker.colourOptions = true;	--colour tooltip text; false to make all addon text white
HiddenArtifactTracker.advTracking = true;	--extra tracking for artifact specific unlock criteria; false to hide
HiddenArtifactTracker.forceTracking = false;	--extra tracking for artifact specific unlock criteria; false to hide

if HiddenArtifactTrackerChars == nil then HiddenArtifactTrackerChars ={} end
HiddenArtifactTrackerChars.trackBosses = true;	--tracking for mage tower dungeon completion
HiddenArtifactTrackerChars.hideArtBar= false;	--hiding the artifact XP tracker bar

--DATA
local arti_names = {
	["Maw of the Damned"]=43646,
	["Blades of the Fallen Prince"]=43647,
	["Apocalypse"]=43648,
	["Twinblades of the Deceiver"]=43649,
	["Aldrachi Warblades"]=43650, 
	["Scythe of Elune"]=43651,
	["Fangs of Ashamane"]=43652,
	["Claws of Ursoc"]=43653,
	["G'Hanir, the Mother Tree"]=43654,
	["Titanstrike"]=43655,
	["Thas'dorah, Legacy of the Windrunners"]=43656,
	["Talonclaw"]=43657,
	["Aluneth"]=43658,
	["Felo'melorn"]=43659,
		["Heart of the Phoenix"]=43659,
	["Ebonchill"]=43660,
	["Fu Zan, the Wanderer's Companion"]=43661,
	["Sheilun, Staff of the Mists"]=43662,
	["Fists of the Heavens"]=43663,
	["The Silver Hand"]=43664,
		["Tome of the Silver Hand"]=43664,
	["Truthguard"]=43665,
		["Oathseeker"]=43665,
	["Ashbringer"]=43666,
	["Light's Wrath"]=43667,
	["T'uure, Beacon of the Naaru"]=43668,
	["Xal'atath, Blade of the Black Empire"]=43669,
		["Secrets of the Void"]=43669,
	["The Kingslayers"]=43670,
	["The Dreadblades"]=43671,
	["Fangs of the Devourer"]=43672,
	["The Fist of Ra-den"]=43673,
		["The Highkeeper's Ward"]=43673,
	["Doomhammer"]=43674,
		["Fury of the Stonemother"]=43674,
	["Sharas'dal, Scepter of Tides"]=43675,
		["Shield of the Sea Queen"]=43675,
	["Ulthalesh, the Deadwind Harvester"]=43676,
	["Skull of the Man'ari"]=43677,
		["Spine of Thal'kiel"]=43677,
	["Scepter of Sargeras"]=43678,
	["Strom'kar, the Warbreaker"]=43679,
	["Warswords of the Valarjar"]=43680,
	["Scale of the Earth-Warder"]=43681,
		["Scaleshard"]=43681
}

local artNumbers = {
	[128402] = "Maw of the Damned",
	[128292] = "Blades of the Fallen Prince",
	[128293] = "Blades of the Fallen Prince",
	[128403] = "Apocalypse",
	[127829] = "Twinblades of the Deceiver",
	[127830] = "Twinblades of the Deceiver",
	[128832] = "Aldrachi Warblades",
	[128831] = "Aldrachi Warblades",
	[128858] = "Scythe of Elune",
	[128859] = "Fangs of Ashamane",
	[128860] = "Fangs of Ashamane",
	[128821] = "Claws of Ursoc",
	[128822] = "Claws of Ursoc",
	[128306] = "G'Hanir, the Mother Tree",
	[128861] = "Titanstrike",
	[128826] = "Thas'dorah, Legacy of the Windrunners",
	[128808] = "Talonclaw",
	[127857] = "Aluneth",
	[128820] = "Felo'melorn",
	[133959] = "Heart of the Phoenix",
	[128862] = "Ebonchill",
	[128938] = "Fu Zan, the Wanderer's Companion",
	[128937] = "Sheilun, Staff of the Mists",
	[128940] = "Fists of the Heavens",
	[133948] = "Fists of the Heavens",
	[128823] = "The Silver Hand", 
	[128824] = "Tome of the Silver Hand",
	[128866] = "Truthguard",
	[128867] = "Oathseeker",
	[120978] = "Ashbringer",
	[128868] = "Light's Wrath",
	[128825] = "T'uure, Beacon of the Naaru",
	[128827] = "Xal'atath, Blade of the Black Empire",
	[133958] = "Secrets of the Void",
	[128870] = "The Kingslayers",
	[128869] = "The Kingslayers",
	[128872] = "The Dreadblades",
	[134552] = "The Dreadblades",
	[128476] = "Fangs of the Devourer",
	[128479] = "Fangs of the Devourer",
	[128935] = "The Fist of Ra-den",
	[128936] = "The Highkeeper's Ward",
	[128819] = "Doomhammer",
	[128873] = "Fury of the Stonemother",
	[128911] = "Sharas'dal, Scepter of Tides",
	[128934] = "Shield of the Sea Queen",
	[128942] = "Ulthalesh, the Deadwind Harvester",
	[128943] = "Skull of the Man'ari",
	[137246] = "Spine of Thal'kiel",
	[128941] = "Scepter of Sargeras",
	[128910] = "Strom'kar, the Warbreaker",
	[128908] = "Warswords of the Valarjar",
	[134553] = "Warswords of the Valarjar",
	[128289] = "Scale of the Earth-Warder",
	[128288] = "Scaleshard"
	}

local localisedDungeons = {
				["Assault on Violet Hold"]=GetLFGDungeonInfo(1209),
				["Black Rook Hold"]=GetLFGDungeonInfo(1205),
				["Cathedral of Eternal Night"]=GetLFGDungeonInfo(1488),
				["Court of Stars"]=GetLFGDungeonInfo(1318),
				["Darkheart Thicket"]=GetLFGDungeonInfo(1202),
				["Eye of Azshara"]=GetLFGDungeonInfo(1175),
				["Halls of Valor"]=GetLFGDungeonInfo(1194),
				["Maw of Souls"]=GetLFGDungeonInfo(1192),
				["Neltharion's Lair"]=GetLFGDungeonInfo(1207),
				["Lower Karazhan"]=GetLFGDungeonInfo(1475),
				["Return to Karazhan"]=GetLFGDungeonInfo(1474),
				["The Arcway"]=GetLFGDungeonInfo(1190),
				["Vault of the Wardens"]=GetLFGDungeonInfo(1044),
				["Seat of the Triumvirate"]=GetLFGDungeonInfo(1535)
			}

SLASH_HIDDENAT1 = '/hat'
function SlashCmdList.HIDDENAT(msg, editbox)

	local success = 1
	for imsg in string.gmatch(msg, "%S+") do
		if imsg=="on" then
			HiddenArtifactTracker.active = true
		elseif imsg=="off" then
			HiddenArtifactTracker.active = false
		elseif imsg=="colour" or msg=="color" then
			HiddenArtifactTracker.colourOptions = not HiddenArtifactTracker.colourOptions
		elseif imsg=="adv" then
			HiddenArtifactTracker.advTracking = not HiddenArtifactTracker.advTracking
		elseif imsg=="force" then
			HiddenArtifactTracker.forceTracking = not HiddenArtifactTracker.forceTracking
		elseif imsg=="mage" then
			HiddenArtifactTrackerChars.trackBosses = not HiddenArtifactTrackerChars.trackBosses
		elseif imsg=="apbar" then
			if HiddenArtifactTrackerChars.hideArtBar == false or HiddenArtifactTrackerChars.hideArtBar == nil then
		 	--toggle to the HIDING state, and hide
			print("The Artifact Power bar is now hidden.")
				HiddenArtifactTrackerChars.hideArtBar = true
				HiddenArtifactTrackerFuncs.hideBar()
			else
				HiddenArtifactTrackerChars.hideArtBar = false			--toggle to the SHOWING state, but only show if an artifact is actually equipped
			print("The Artifact Power bar has been returned to default behaviour.")
				if HiddenArtifactTrackerFuncs.isArtEquipped() and (not MainMenuExpBar:IsVisible() or not ReputationWatchBar:IsVisible() ) then
					MainMenuMaxLevelBar0:GetParent():Hide()
					ArtifactWatchBar:Show()
				end
			end
		else
			success = 0
		end
	end

	if success ~= 1 or msg == "" then
		print("Usage: /hat <option> where option is:\noff - deactivate\non - enable\nadv - toggle advanced tracking\ncolour - toggle coloured/white text\nmage - toggle display of dungeon boss tracking for mage tower skin\napbar - toggle display of the Artifact power bar")
	end
end

--these hide the artifact XP bar if something tries to show it, and we have set to hide
local artbarShow = ArtifactWatchBar:GetScript("OnShow")
local artbarHide = MainMenuMaxLevelBar0:GetParent():GetScript("OnHide")
ArtifactWatchBar:SetScript("OnShow", 
	function(...)
		artbarShow(...)
		HiddenArtifactTrackerFuncs.hideBar()
	end)
function HiddenArtifactTrackerFuncs.hideBar()
		if HiddenArtifactTrackerChars.hideArtBar==true then
			ArtifactWatchBar:Hide()
			if not MainMenuExpBar:IsVisible() and not ReputationWatchBar:IsVisible() then
				ArtifactWatchBar:Hide()
				MainMenuMaxLevelBar0:GetParent():Show()
			elseif not MainMenuExpBar:IsVisible() or not ReputationWatchBar:IsVisible() then
				ArtifactWatchBar:Hide()
				MainMenuMaxLevelBar0:GetParent():Hide()
			end
		end

		if not MainMenuExpBar:IsVisible() and HiddenArtifactTrackerChars.hideArtBar==true then
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint("BOTTOM", 0, 42)
		else
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint("BOTTOM", 0, 50)
		end
end
function HiddenArtifactTrackerFuncs.isArtEquipped()
	for key,value in pairs(artNumbers) do
		if IsEquippedItem(key) then
			return true
		end
	end
	return false
end

MainMenuMaxLevelBar0:GetParent():SetScript("OnHide", ArtifactWatchBar:GetScript("OnShow"))

local handler = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem",

	function(...)

		--default tooltip behaviours
		handler(...)

		if HiddenArtifactTrackerFuncs.recoverSaveData then 
			HiddenArtifactTrackerFuncs.recoverSaveData()
			HiddenArtifactTrackerFuncs.recoverSaveData = nil
		end

		-- artifact specific additional text
		local name = GameTooltip:GetItem()

		if GetLocale() ~= "enUS" and GetLocale() ~= "enGB" then --have to do longer item matching for non-english clients
			
			for key,value in pairs(artNumbers) do
				local localName = GetItemInfo(key)
				if localName == name then
					name = value
					break
				end
			end

		end
	

		if HiddenArtifactTracker.active and arti_names[name] then

			-- Advanced tracking for unlocking base appearance (only for supported artifacts [WIP])
			if HiddenArtifactTracker.advTracking and not IsQuestFlaggedCompleted(arti_names[name]) and HiddenArtifactTrackerFuncs[name] then
				HiddenArtifactTrackerFuncs[name]()
			end

			-- tracking for tint unlocks if base appearance is unlocked
			if IsQuestFlaggedCompleted(arti_names[name]) or HiddenArtifactTracker.forceTracking then

				-- Check additional tint criteria
				local k=GetAchievementCriteriaInfo
				local x,b; local a=0
				for i=1,15 do 
					_,_,_,x,b = k(11152,i)
					a=a+x
				end
				local _,_,_,c, d = k(11153,1)
				local _,_,_,e, f = k(11154,1)
		
				local n_once="\n"

				if a<b then
					if HiddenArtifactTracker.colourOptions then
						GameTooltip:AddLine(n_once.."Dungeons: "..a.."/"..b,math.min(1,2-(2*a/b)),math.min(1,2*a/b),0,True)
					else
						GameTooltip:AddLine(n_once.."Dungeons: "..a.."/"..b,1,1,1,True)
					end
					n_once=""
				end
				if c~=d then
					if HiddenArtifactTracker.colourOptions then
						GameTooltip:AddLine(n_once.."World Quests: "..c.."/"..d,math.min(1,2-(2*c/d)),2*c/d,0,True)
					else
						GameTooltip:AddLine(n_once.."World Quests: "..c.."/"..d,1,1,1,True)
					end
					n_once=""
				end
				if e~=f then
					if HiddenArtifactTracker.colourOptions then
						GameTooltip:AddLine(n_once.."PvP: "..e.."/"..f,math.min(1,2-(2*e/f)),2*e/f,0,True)
					else
						GameTooltip:AddLine(n_once.."PvP: "..e.."/"..f,1,1,1,True)
					end
					n_once=""
				end
			end

			if HiddenArtifactTrackerChars.trackBosses and HiddenArtifactTrackerChars[name] ~= nil and IsQuestFlaggedCompleted(HiddenArtifactTrackerChars[name]["quest"]) then
				--mage dungeon colour
				if HiddenArtifactTrackerChars[name]["completion"] < 10 then
					GameTooltip:AddLine(" ", 1,1,1,True)

					if HiddenArtifactTracker.colourOptions then
						local col = HiddenArtifactTrackerChars[name]["completion"] / 10
						GameTooltip:AddLine("Mage Tower dungeons: "..HiddenArtifactTrackerChars[name]["completion"].."/10", 2-2*col, 2*col, 0, True)
					else
						GameTooltip:AddLine("Mage Tower dungeons: "..HiddenArtifactTrackerChars[name]["completion"].."/10", 1,1,1, True)
					end

					for k,v in pairs(HiddenArtifactTrackerChars[name]) do
						if k ~= "rbg" and k ~= "completion" and k ~= "quest" then
							if v==false then
								if HiddenArtifactTracker.colourOptions then
								GameTooltip:AddLine(localisedDungeons[k], 1,0,0,True)
							else
								GameTooltip:AddLine(localisedDungeons[k].." is available.", 1,1,1,True)
							end
							elseif v==true and HiddenArtifactTracker.colourOptions then
								GameTooltip:AddLine(localisedDungeons[k], 0,1,0,True)
							end
						end
					end
				end
				
				--mage RBG colour
				local rbgWins =  GetStatistic(5694)
				if rbgWins == "--" then rbgWins = 0 end
				local startWins = HiddenArtifactTrackerChars[name].rbg or rbgWins
				local deltaWins = rbgWins - startWins
				if deltaWins < 10 then
					GameTooltip:AddLine(" ", 1,1,1,True)
					if HiddenArtifactTracker.colourOptions then
						local col = deltaWins / 10
						GameTooltip:AddLine("Mage Tower RBG wins: "..deltaWins.."/10", 2-2*col, 2*col, 0, True)	
					else
						GameTooltip:AddLine("Mage Tower RBG wins: "..deltaWins.."/10", 1,1,1, True)	
					end
				end

			elseif HiddenArtifactTrackerChars.trackBosses and HiddenArtifactTrackerChars[name] ~= nil and IsQuestFlaggedCompleted(HiddenArtifactTrackerChars[name]["quest"]) == false then
				GameTooltip:AddLine(" ", 1,1,1,True)

				local state,perc,time = C_ContributionCollector.GetState(1)
				perc = math.floor(perc*100)
				local col = not HiddenArtifactTracker.colourOptions and 1 or 0

				if state == Enum.ContributionState.Active or state == Enum.ContributionState.UnderAttack then
					GameTooltip:AddLine("Mage Tower is available!", col, 1, col, True)
				elseif state == Enum.ContributionState.Destroyed then
					GameTooltip:AddLine("Mage Tower is destroyed!", 1, col, col, True)			
				else
					GameTooltip:AddLine("Mage Tower is at "..perc.."% completion.", 1,col,col,True)
				end
			end

			-- force tooltip to resize itself
			GameTooltip:Show()
		end
	end

)