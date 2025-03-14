-- App locals
local appName, app = ...;
local tinsert, math_floor
	= tinsert, math.floor;
local Colorize = app.Modules.Color.Colorize;

-- Local functions
local DefaultRWP = ((math.ceil(app.GameBuildVersion / 10000) + 1) * 10000) - 1;
local ExcludeNonCollectibles, MaximumRWP;
function RemovedWithPatchFilter(group)
	if group.rwp and group.rwp < MaximumRWP and (not ExcludeNonCollectibles or group.collectible) then
		return true;
	end
end
local function GetPatchString(patch)
	patch = tonumber(patch)
	return patch and (math_floor(patch / 10000) .. "." .. (math_floor(patch / 100) % 100) .. "." .. (patch % 10))
end


-- Implementation
app:CreateWindow("Removed With Patch", {
	Commands = { "attrwp" },
	OnLoad = function(self, settings)
		ExcludeNonCollectibles = settings.ExcludeNonCollectibles;
		if ExcludeNonCollectibles == nil then ExcludeNonCollectibles = true; end
		MaximumRWP = settings.MaximumRWP;
		if not MaximumRWP or DefaultRWP > MaximumRWP then
			MaximumRWP = DefaultRWP;
		end
	end,
	OnSave = function(self, settings)
		settings.ExcludeNonCollectibles = ExcludeNonCollectibles;
		settings.MaximumRWP = MaximumRWP;
	end,
	OnRebuild = function(self)
		if self.data then return true; end
		local options = {
			{	-- Exclude Non-Collectibles Button
				text = "Exclude Non-Collectibles",
				icon = 134941,
				description = "Press this button to toggle excluding non-collectible items such as Thrown weapons and Relic items.",
				visible = true,
				priority = 6,
				OnClick = function(row, button)
					ExcludeNonCollectibles = not ExcludeNonCollectibles;
					wipe(self.data.g);
					self:Rebuild();
					return true;
				end,
				OnUpdate = function(data)
					data.saved = ExcludeNonCollectibles;
					return true;
				end,
			},
			{	-- Maximum Removed With Patch
				prefix = "Maximum Removed With Patch: ",
				text = RETRIEVING_DATA,
				icon = 134941,
				description = "Press this button to change the maximum removed with patch value.\n\nChanging this value will filter out items that get removed after the given patch.",
				visible = true,
				priority = 6,
				OnClick = function(row, button)
					app:ShowPopupDialogWithEditBox("Please enter a new maximum RWP", MaximumRWP, function(cmd)
						if cmd and cmd ~= "" then
							cmd = cmd:lower();
							local patch = 0;
							local major, minor, build = ("."):split(cmd);
							if not minor then
								if cmd == "default" then
									patch = DefaultRWP;
								elseif cmd == "classic" then
									patch = 19999;
								elseif cmd == "tbc" then
									patch = 29999;
								elseif cmd == "wrath" then
									patch = 39999;
								elseif cmd == "cata" then
									patch = 49999;
								elseif cmd == "mop" then
									patch = 59999;
								elseif cmd == "wod" then
									patch = 69999;
								elseif cmd == "legion" then
									patch = 79999;
								elseif cmd == "bfa" then
									patch = 89999;
								elseif cmd == "shadowlands" or cmd == "sl" then
									patch = 99999;
								elseif cmd == "dragonflight" or cmd == "df" then
									patch = 109999;
								elseif cmd == "tww" then
									patch = 119999;
								elseif cmd == "midnight" then
									patch = 129999;
								elseif cmd == "any" or cmd == "all" then
									patch = 9999999999;
								else
									patch = tonumber(cmd);
								end
							else
								if build then patch = patch + tonumber(build); end
								patch = patch + (tonumber(minor) * 100);
								patch = patch + (tonumber(major) * 10000);
							end
							if patch > 0 then
								while patch < 10000 do patch = patch * 10; end
								if MaximumRWP ~= patch then
									MaximumRWP = patch;
									wipe(self.data.g);
									self:Rebuild();
								end
							else
								app.print("Invalid patch format '" .. cmd .. "'");
							end
						end
					end);
					return true;
				end,
				OnUpdate = function(data)
					data.text = data.prefix .. Colorize(GetPatchString(MaximumRWP), app.Colors.RemovedWithPatch);
					return true;
				end,
			},
		};
		self.data = {
			text = "Removed With Patch Loot",
			icon = app.asset("WindowIcon_RWP"), 
			description = "This window shows you all of the things that get removed in a future patch that we know about and have documented in the addon. These items use a 'removed in patch' note on their tooltip to indicate when you can expect an item to be removed from the game.",
			visible = true, 
			expanded = true,
			back = 1,
			indent = 0,
			g = { },
			OnUpdate = function(t)
				local g = t.g;
				if #g < 1 then
					for i,option in ipairs(options) do
						option.parent = data;
						tinsert(g, option);
					end
					local results = app:BuildSearchFilteredResponse(app:GetDataCache().g, RemovedWithPatchFilter);
					if results and #results > 0 then
						for i,result in ipairs(results) do
							tinsert(g, result);
						end
						self:AssignChildren();
					end
				end
			end,
		};
		return true;
	end,
});