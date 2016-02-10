
local levelIdx,qualityIdx,classIdx,classSpecIdx,portraitIdx,modelIdx,modelHeightIdx,modelScaleIdx,abilitiesIdx,countersIdx,traitsIdx,isCollectableIdx = 1,2,3,4,5,6,7,8,9,10,11,12; -- table indexes for FollowerLocationInfoData.basics entries.
local D = FollowerLocationInfoData;

function FollowerLocationInfo_Collector(clear)
	if(clear)then FollowerLocationInfoDataCollectorDB = {}; return end

	local Faction = UnitFactionGroup("player");
	local dataFaction = C_Garrison.GetFollowerInfo(34).displayID==55047 and "Alliance" or "Horde";
	if Faction~=dataFaction then
		print("|cffff0000ERROR|r: |cffffaa00Collector disabled! Blizzard provides follower data from opposite faction|r");
		return;
	end

	local _CLASS_SORT_ORDER={};
	for i=1, #CLASS_SORT_ORDER do
		_CLASS_SORT_ORDER[CLASS_SORT_ORDER[i]:lower()] = i;
	end

	if(not FollowerLocationInfoDataCollectorDB) then
		FollowerLocationInfoDataCollectorDB={};
	end

	local db = FollowerLocationInfoDataCollectorDB;
	local line = "B[%d] = {%d,%d,%d,%d,%d,%d,%s,%s,{%s},{%s},{%s},%s}";

	db[Faction] = {};

	local collectable = {};
	for i,v in ipairs(C_Garrison.GetFollowers() or {})do
		collectable[tonumber(v.garrFollowerID or v.followerID)] = true;
	end

	for i=1, 650 do
		local v = C_Garrison.GetFollowerInfo(i);
		if (v) and (v.portraitIconID~=0) then
			local a,c,t = {},{},{};
			for _,V in ipairs(C_Garrison.GetFollowerAbilities(i) or {}) do
				if(V.id)then
					if(V.isTrait)then
						tinsert(t,V.id); -- traits
					else
						tinsert(a,V.id); -- abilities
						if(V.counters)then
							for cID in pairs(V.counters) do
								tinsert(c,cID);
							end
						end
					end
				end
			end
			tinsert(db[Faction],line:format(
				i,
				v.level,
				v.quality,
				D.ClassName2ID[gsub(v.classAtlas,"GarrMission_ClassIcon%-",""):lower()],
				v.classSpec,
				v.portraitIconID,
				v.displayID,
				v.displayHeight,
				v.displayScale,
				table.concat(a,","), -- abilities
				table.concat(c,","), -- counters [from abilities]
				table.concat(t,","), -- traits
				(collectable[i] and "true" or "false")
			));
		end
	end
end


function FollowerLocationInfo_GetTooltipData(Type,Id)
	local tt,data,line,link = FollowerLocationInfo_Tooltip,{},1;
	tt:Show();
	tt:SetOwner(UIParent,"LEFT",0,0);
	if Type=="npc" then
		link="unit:Creature-0-1-1-1-"..Id.."-0";
	elseif Type=="object" then
		link="unit:GameObject-0-1-1-1-"..Id.."-0";
--	elseif Type=="follower" then
--		link="garrfollower:34:4:100:600:"..Id..":0:0:0:0:0:0:0";
	end
	if link then
		tt:SetHyperlink(link);
		for _,v in ipairs({tt:GetRegions()}) do
			if v and v:GetObjectType()=="FontString" and v:GetText() then
				data["tooltipLine"..line]=v:GetText();
				line=line+1;
			end
		end
		tt:ClearLines();
		tt:Hide();
		return data;
	end
	return false;
end

