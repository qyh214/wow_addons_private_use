local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization
local _,addon = ...
local _, DCS_TableData = ...
addon.DCS_TableData = DCS_TableData
local _, gdbprivate = ...
local _, pdbprivate = ...

pdbprivate.pdb = {
}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DejaCharacterStats" then
			local function initDB(pdb)
				if type(pdb) ~= "table" then pdb = {} end
				for k, v in pairs(pdb) do
					if type(v) == "table" then
						pdb[k] = initDB(pdb[k], v)
					elseif type(v) ~= type(pdb[k]) then
						pdb[k] = v
					end
				end
				return pdb
			end
            
			DCS_ClassSpecDB = initDB(DCS_ClassSpecDB) 
			pdbprivate.pdb = DCS_ClassSpecDB --fast access for checkbox states
            self:UnregisterEvent("ADDON_LOADED")
		end
    end)

local selectedProfile = "Choose Profile" -- A user-configurable setting 

-- Create the DCS_dropDown, and configure its appearance
DCS_dropDown = CreateFrame("FRAME", "WPDemoDropDown", DCS_TableResetButton, "UIDropDownMenuTemplate")
DCS_dropDown:SetPoint("TOPRIGHT", DCS_TableResetButton, "BOTTOMRIGHT", 14, -16)
UIDropDownMenu_SetWidth(DCS_dropDown, 242)
UIDropDownMenu_SetText(DCS_dropDown, selectedProfile)

-- -- Create and bind the initialization function to the DCS_dropDown menu
-- UIDropDownMenu_Initialize(DCS_dropDown, function(self, level, menuList)
--     -- for k, v in pairs(pdbprivate.pdb) do --Debugging loop
--     --     print(k)
--     -- end
--     local info = UIDropDownMenu_CreateInfo()
--     if (level or 1) == 1 then
--         info.func = self.SetValue
--         for k, v in pairs(pdbprivate.pdb) do
--             info.text, info.arg1, info.checked = k, k, k == selectedProfile
--             print(info.text, info.arg1, info.checked)
--             UIDropDownMenu_AddButton(info)
--         end
--     end
-- end)

-- Create and bind the initialization function to the DCS_dropDown menu
UIDropDownMenu_Initialize(DCS_dropDown, function(self, level, menuList)
    -- for k, v in pairs(pdbprivate.pdb) do --Debugging loop
    --     print(k)
    -- end
    local info = UIDropDownMenu_CreateInfo()
    if (level or 1) == 1 then
        info.func = self.SetValue       
        local uniqueKeyOrder = { }
        for k in pairs(pdbprivate.pdb) do
            tinsert(uniqueKeyOrder, k)
        end
        table.sort(uniqueKeyOrder)
        
        -- for i = 1, #uniqueKeyOrder do
        --     local categoryName = uniqueKeyOrder[i]
        --     local categoryData = pdbprivate.pdb[categoryName]
        --     -- print(categoryData)
        --     -- info.text, info.arg1, info.checked = categoryData, categoryData, categoryData == selectedProfile
        --     -- UIDropDownMenu_AddButton(info)
        -- end

        for k, v in ipairs(uniqueKeyOrder) do
            info.text, info.arg1, info.checked = v, v, v == selectedProfile
            -- print(info.text, info.arg1, info.checked)
            UIDropDownMenu_AddButton(info)
        end
    end
end)

-- Implement the function to change the selectedProfile
function DCS_dropDown:SetValue(newValue)
    selectedProfile = newValue --selectedProfile now = the DCSuniqueKey via addon.ShownData.DCSuniqueKey
    -- print(selectedProfile)
    UIDropDownMenu_SetText(DCS_dropDown, selectedProfile)
    addon.ShownData = DCS_TableData:MergeTable(DCS_ClassSpecDB[selectedProfile])

    --Now set the DCSuniqueKey profile to be the newValue/selectedProfileprofile
    DCSuniqueKey_SpecInfo()
	DCS_ClassSpecDB[DCSuniqueKey] = addon.ShownData
    CloseDropDownMenus()
    
    --Stat Header workaround...
    set_config_mode(true) -- This allows the ratings and corruption stats and category headers to be shown when changin specs. No clue why, but it works.
    set_relevant_stat_state() --Call with set_config_mode(true) to show..it works...
    ShowCharacterStats("player") --Call with set_config_mode(true) to show..it works...
    local function DCS_ReShowSelectedStats()
        set_config_mode(false) -- This hides the above shown config mode 0.01 secs after showing it becasue we dont want it shown, but showing it shows the selected stats, so we need to exit config after entering it.
        set_relevant_stat_state()
        ShowCharacterStats("player") --Call after closing the config
    end
    C_Timer.After(0.01, DCS_ReShowSelectedStats)
end