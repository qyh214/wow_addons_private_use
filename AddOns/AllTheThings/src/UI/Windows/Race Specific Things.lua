-- App locals
local appName, app = ...;
local containsValue = app.containsValue;
local tinsert = tinsert;
local C_CreatureInfo_GetRaceInfo = C_CreatureInfo.GetRaceInfo;

-- Implementation
app:CreateWindow("Race Specific Things", {
	Commands = { "attraces" },
	OnRebuild = function(self)
		if self.data then return true; end
		self.data = {
			text = "Race Specific Things",
			icon = app.asset("WindowIcon_RWP"), 
			description = "This window shows you all of the race specific things for all races.",
			visible = true, 
			expanded = true,
			back = 1,
			indent = 0,
			g = { },
			OnUpdate = function(t)
				local g = t.g;
				if #g < 1 then
					for raceID=1,20,1 do
						if C_CreatureInfo_GetRaceInfo(raceID) then
							local raceObject = app.CreateRace(raceID);
							tinsert(g, raceObject);
							raceObject.g = app:BuildSearchFilteredResponse(app:GetDataCache().g, function(group)
								if group.races and #group.races == 1 and containsValue(group.races, raceID) then
									return true;
								end
							end);
						end
					end
					t.OnUpdate = nil;
					self:AssignChildren();
					self:ExpandData(true);
				end
			end,
		};
		return true;
	end,
});