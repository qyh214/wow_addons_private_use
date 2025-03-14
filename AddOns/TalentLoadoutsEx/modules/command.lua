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
	Addon:ImportTextAsync(data.text);
	Addon:SetPvpTalent(data.pvp1, data.pvp2, data.pvp3);
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

local commandName_Load = addonName.."_Load";
_G["SLASH_"..commandName_Load..1] = "/tlx"
SlashCmdList[commandName_Load] = function(msg, ...)
	local name = SecureCmdOptionParse(msg or "");
	if name and #name > 0 then
		if Addon:IsAddOnLoaded("Blizzard_PlayerSpells") then
			Addon:CommitConfigByName(name);
		else
			Addon:RegisterAddonLoad("Blizzard_PlayerSpells", true, "CommitConfigByName", name);
		end
	end
end
