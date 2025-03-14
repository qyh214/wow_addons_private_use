-- App locals
local appName, app = ...;

-- Implementation
app:CreateWindow("Prime", {
	AllowCompleteSound = true,
	SettingsName = "Main List",
	IsTopLevel = true,
	Defaults = {
		["y"] = 20,
		["x"] = 0,
		["scale"] = 1.2,
		["width"] = 360,
		["height"] = 600,
		["visible"] = false,
		["point"] = "CENTER",
		["relativePoint"] = "CENTER",
	},
	Commands = {
		"att",
		"allthethings",
		"attc",
	},
	RootCommandIndex = 2,
	OnCommand = function(self, cmd)
		if cmd and cmd:len() > 0 then
			-- Search for the Link in the database
			cmd = cmd:lower();
			local args = { (" "):split(cmd) };
			local arg1 = args[1]

			local commandFunc = app.ChatCommands[arg1]
			if commandFunc then
				if args[2] == "help" then return app.ChatCommands.PrintHelp(arg1) end
				return commandFunc(args)
			end

			local group = app.GetCachedSearchResults(app.SearchForLink, cmd);
			if group then app:CreateMiniListForGroup(group); end
			return true;
		end
	end,
	OnInit = function(self)
		app.ToggleMainList = function()
			self:Toggle();
		end
	end,
	OnLoad = function(self, settings)
		if not settings.visible then
			self:ForceRebuild();
		end
	end,
	OnRebuild = function(self)
		-- Prime's data is built elsewhere.
		self.data = app:GetDataCache();
		return false;
	end,
	OnUpdate = function(self, ...)
		self.DefaultUpdate(self, ...);

		-- Write the current character's progress.
		local rootData = self.data;
		app.CurrentCharacter.PrimeData = {
			progress = rootData.progress,
			total = rootData.total,
			modeString = rootData.modeString,
		};
	end
});