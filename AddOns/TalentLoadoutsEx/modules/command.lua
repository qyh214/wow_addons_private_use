local addonName, Addon = ...;

local function CommitTalent()
	local configID = C_ClassTalents.GetActiveConfigID();
	if configID then
		-- When applying Talent from an addon, a taint error may occur.
		-- If there are too many reports of this occurring, I will discontinue this feature.
		-- Addon.TalentsFrame:CommitConfig();

		-- It looks a little worse than it is, but this one does not cause taint error.
		C_Traits.CommitConfig(configID);
	else
		Addon:Print("Error: C_ClassTalents.GetActiveConfigID() = nil");
	end
end

function Addon:CommitConfigByName(name)
	local talentsFrame = Addon.TalentsFrame;
	if not talentsFrame then
		Addon:Print("Error: TalentsFrame is not exists.");
		return;
	end

	local data = Addon:GetDataByName(name);
	if not data then
		return;
	elseif data.isLegacy then
		Addon:Print("Legacy format text is obsolated.");
		return;
	end

	Addon:Print("Loading: |cff00ccff"..name.."|r");
	Addon:SetPvpTalent(data.pvp1, data.pvp2, data.pvp3);
	Addon:ImportTextAsync(data.text);
	Addon:SendUpdateMessage();

	local isLoaded = false;
	C_Timer.NewTicker(
		0.1,
		function()
			if not isLoaded and not Addon.isLocked then
				isLoaded = true;
				CommitTalent();
			end
		end,
		10
	);
end

local loadedConfigNames = {};
local function UpdateLoadedConfigNames()
	if not Addon.loadedDataList then
		PlayerSpellsFrame.TalentsFrame:UpdateTreeInfo();
		Addon:UpdateScrollBox(true);
	end

	table.wipe(loadedConfigNames);
	for _, data in ipairs(Addon.loadedDataList) do
		loadedConfigNames[data.name] = true;
	end
end

local function IsMatchedOption(option)
	local optionText = "";
	for conditionals in option:gmatch("(%[[^%[%]]*%])") do
		optionText = optionText.."[";
		for conditional in conditionals:gsub("[%[%]]", ""):gmatch("([^,]+)") do
			local tlx = conditional:match("^tlx:(.+)$");
			local notlx = conditional:match("^notlx:(.+)$");

			if tlx then
				if not loadedConfigNames[tlx] then
					return false;
				end
			elseif notlx then
				if loadedConfigNames[notlx] then
					return false;
				end
			else
				optionText = optionText..","..conditional;
			end
		end

		optionText = optionText.."]";
	end

	return SecureCmdOptionParse(optionText) and true or false;
end

local function CmdOptionParse(msg)
	UpdateLoadedConfigNames();

	for option in msg:gmatch("([^;]+)") do
		local name = option:match("[^%]]*$");
		if not name or #name == 0 then
			return nil;
		end

		if not option:match("%]") then
			return name;
		end

		if IsMatchedOption(option) then
			return name;
		end
	end
end

function Addon:ExecuteCommand(msg)
	local name = CmdOptionParse(msg or "");
	if name and #name > 0 then
		Addon:CommitConfigByName(name);
	end
end

local commandName_Load = addonName.."_Load";
_G["SLASH_"..commandName_Load..1] = "/tlx"
SlashCmdList[commandName_Load] = function(msg, ...)
	msg = msg or "";
	if Addon:IsAddOnLoaded("Blizzard_PlayerSpells") then
		Addon:ExecuteCommand(msg);
	else
		Addon:RegisterAddonLoad("Blizzard_PlayerSpells", true, "ExecuteCommand", msg);
	end
end
