local Addon = select(2, ...);

local checksumTextPattern = "# Checksum: %x+$";

-- Adapted from https://github.com/philanc/plc/blob/master/plc/checksum.lua
local function adler32(s)
	-- return adler32 checksum  (uint32)
	-- adler32 is a checksum defined by Mark Adler for zlib
	-- (based on the Fletcher checksum used in ITU X.224)
	-- implementation based on RFC 1950 (zlib format spec), 1996
	local prime = 65521 --largest prime smaller than 2^16
	local s1, s2 = 1, 0

	-- limit s size to ensure that modulo prime can be done only at end
	-- 2^40 is too large for WoW Lua so limit to 2^30
	if #s > (bit.lshift(1, 30)) then error("adler32: string too large") end

	for i = 1,#s do
		local b = string.byte(s, i)
		s1 = s1 + b
		s2 = s2 + s1
		-- no need to test or compute mod prime every turn.
	end

	s1 = s1 % prime
	s2 = s2 % prime

	return (bit.lshift(s2, 16)) + s1
end --adler32()

local function UpdateSimcText(simcFrame)
	local SimcEditBox = _G["SimcEditBox"];
	local simcText = SimcEditBox and SimcEditBox.GetText and SimcEditBox:GetText();
	if simcText and #simcText > 0 then
		local hasChecksum = simcText:match(checksumTextPattern);
		simcText = simcText:gsub(checksumTextPattern, "");

		for _, data in pairs(Addon:GetSpecTable()) do
			if data and data.name and data.text and not data.isLegacy then
				simcText = simcText..string.format("\n# Saved Loadout: %s\n# talents=%s", data.name, data.text);
			end
		end

		if hasChecksum then
			simcText = simcText.."\n\n";
			local checksum = adler32(simcText);
			simcText = simcText..string.format("# Checksum: %x", checksum);
		end

		SimcEditBox:SetText(simcText);
		SimcEditBox:HighlightText();
	end
end

function Addon:InitSimulationcraft()
	local simc = LibStub("AceAddon-3.0"):GetAddon("Simulationcraft");
	local funcName = "PrintSimcProfile";
	if simc and simc[funcName] then
		hooksecurefunc(simc, funcName, UpdateSimcText);
	end
end

Addon:RegisterAddonLoad("Simulationcraft", false, "InitSimulationcraft");
