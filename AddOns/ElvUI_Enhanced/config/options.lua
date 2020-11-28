local E, L, V, P, G = unpack(ElvUI);
local EEL = E:GetModule('ElvuiEnhancedAgain')

local tinsert, format = tinsert, format

local function configOptions()
    --E.Options.name = E.Options.name.." + EEL "..format(": |cff99ff33%s|r", EEL.version)

    E.Options.args.eel = {
		type = "group",
		name = EEL.title,
		childGroups = "tab",
		--desc = L["Nick test"],
        order = 6,
        args = {
			header1 = {
				order = 1,
				type = "header",
				name = format(L["%s version |cffff8000%s|r by Tevoll "], EEL.title, EEL.version),
            }
        }
    }
end

tinsert(EEL.config, configOptions)


