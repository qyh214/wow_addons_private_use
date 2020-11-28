local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule('UnitFrames')

--GLOBALS: hooksecurefunc
local _G = _G

--function UF:Construct_PartyFrame()
	--if not E.db.unitframe.units.party.enable then return end
	--UF:ArrangeParty()
--end

function UF:ArrangeParty()
	local enableState = E.db.unitframe.units.party.enable
	local header = _G['ElvUF_Party']

	for i = 1, header:GetNumChildren() do
		local group = select(i, header:GetChildren())

		for j = 1, group:GetNumChildren() do
			local frame = select(j, group:GetChildren())
            -- Power
			UF:Onlyhealth_Power(frame)
		end
	end
end


function UF:InitParty()
	SUF:Construct_PartyFrame()

	hooksecurefunc(UF, "CreateAndUpdateHeaderGroup", function(_, frame)
		if frame == 'party' then UF:ArrangeParty() end
	end)
end
