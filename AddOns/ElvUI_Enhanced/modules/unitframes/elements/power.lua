local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule('UnitFrames')

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitName = UnitName


function UF:Onlyhealth_Power(frame)
	local power = frame.Power
	if not power then return end
    
    local role = UnitGroupRolesAssigned(frame.unit)
    print(role)
    if role == "HEALER" then 
        print("healer sub")    
        return 
    end   
    print("hide power")
end
