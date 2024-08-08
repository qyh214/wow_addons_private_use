--[[
]]

local ADDON_NAME, Internal = ...
local L = Internal.L
local External = _G[ADDON_NAME]

local format = string.format
local wipe = table.wipe
local concat = table.concat

local function StringToTable(text)
    local stringType = text:sub(1,1)
    if stringType == "{" then
        local func, err = loadstring("return " .. text, "Import")
        if not func then
            return false, err
        end
        setfenv(func, {});
        return pcall(func)
    else
        return false, L["Invalid string"]
    end
end
local function TableToString(tbl)
    local str = {}
    for k,v in pairs(tbl) do
        if type(k) == "number" then
            k = "[" .. k .. "]"
        elseif type(k) ~= "string" then
            error(format(L["Invalid key type %s"], type(k)))
        end

        if type(v) == "table" then
            v = TableToString(v)
        elseif type(v) == "string" then
            v = format("%q", v)
        elseif type(v) ~= "number" and type(v) ~= "boolean" then
            error(format(L["Invalid value type %s for key %s"], type(v), tostring(k)))
        end

        str[#str+1] = k .. "=" .. tostring(v)
    end
    return "{" .. concat(str, ",") .. "}"
end

local Base64Encode, Base64Decode
do
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    function Base64Encode(data)
        return ((data:gsub('.', function(x)
            local r,b='',x:byte()
            for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
            return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#data%3+1])
    end
    function Base64Decode(data)
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end
end

local function Encode(content, format)
    if #format == 1 then
        if format == "N" then
            return "N" .. content
        elseif format == "B" then
            return "B" .. Base64Encode(content)
        else
            error("Unsupported format")
        end
    elseif #format > 1 then
        local f, ormat = format:match("^([A-Z])([A-Z]*)$")
        return Encode(Encode(content, ormat), f)
    end
end
local function Decode(content, err)
    local format, content = content:match("^([A-Z])(.*)$")

    if format == "N" then
        return true, content
    elseif format == "B" then
        return Decode(Base64Decode(content))
    else
        return false, err or L["Unsupported format"]
    end
end

local function VerifySource(source, sourceType, version, name, ...)
    version = source.version or version
    sourceType = source.type or sourceType
    name = source.name or name

    if not name then
        return false, L["Missing name"]
    elseif type(name) ~= "string" then
        return false, L["Invalid name"]
    end

    if sourceType == "loadout" then
        if version ~= 2 then -- Only supported version
            return false, L["Invalid source version"]
        end

        local specID = source.specID or ...
        if not specID or not GetSpecializationInfoByID(specID) then
            return false, L["Invalid specialization"]
        end

        for _,segment in Internal.EnumerateLoadoutSegments() do
            if source[segment.id] then
                for _,set in ipairs(source[segment.id]) do
                    local result, err = VerifySource(set, segment.id, 1, name, specID)
                    if not result then
                        return result, err
                    end
                end
            end
        end
    else
        local segment = Internal.GetLoadoutSegment(sourceType)
        if not segment then
            return false, L["Invalid import type"]
        end
        if not segment.verify then
            return false, L["Missing verification function"]
        end

        return segment.verify(source, ...)
    end

    -- if sourceType == "loadout" then
    --     if version ~= 2 then -- Only supported version
    --         return false, L["Invalid source version"]
    --     end

    --     local specID = source.specID or ...

    --     if not source.talents and not source.pvptalents and not source.essences then
    --         return false, L["Missing value"]
    --     end
    --     if not specID or not GetSpecializationInfoByID(specID) then
    --         return false, L["Invalid specialization"]
    --     end

    --     local function VerifyType(source, type, version, name, ...)
    --         return VerifySource(source[type], type, version, name, ...)
    --     end

    --     for _,subtype in ipairs({"talents", "pvptalents", "essences"}) do
    --         for _,set in ipairs(source[subtype]) do
    --             local result, err = VerifySource(set, subtype, 1, name, specID)
    --             if not result then
    --                 return result, err
    --             end
    --         end
    --     end
    --     -- if source.talents then
    --     --     for _,set in ipairs(source.talents) do
    --     --     end
    --     --     local result, err = VerifySource(source.talents, "talents", 1, name, specID)
    --     --     if not result then
    --     --         return result, err
    --     --     end
    --     -- end
    --     -- if source.pvptalents then
    --     --     local result, err = VerifySource(source.pvptalents, "pvptalents", 1, name, specID)
    --     --     if not result then
    --     --         return result, err
    --     --     end
    --     -- end
    --     -- if source.essences then
    --     --     local result, err = VerifySource(source.essences, "essences", 1, name, GetSpecializationRoleByID(specID))
    --     --     if not result then
    --     --         return result, err
    --     --     end
    --     -- end
    -- elseif sourceType == "talents" then
    --     if version ~= 1 then -- Only supported version
    --         return false, L["Invalid source version"]
    --     end

    --     local specID = source.specID or ...
    --     if type(source.talents) ~= "table" then
    --         return false, L["Missing talents"]
    --     end
    --     if not specID or not GetSpecializationInfoByID(specID) then
    --         return false, L["Invalid specialization"]
    --     end
    -- elseif sourceType == "pvptalents" then
    --     if version ~= 1 then -- Only supported version
    --         return false, L["Invalid source version"]
    --     end

    --     local specID = source.specID or ...
    --     if type(source.talents) ~= "table" then
    --         return false, L["Missing pvp talents"]
    --     end
    --     if not specID or not GetSpecializationInfoByID(specID) then
    --         return false, L["Invalid specialization"]
    --     end
    -- elseif sourceType == "essences" then
    --     if version ~= 1 then -- Only supported version
    --         return false, L["Invalid source version"]
    --     end

    --     local role = source.role or GetSpecializationRoleByID(...)
    --     if type(source.essences) ~= "table" then
    --         return false, L["Missing essences"]
    --     end
    --     if role ~= "DAMAGER" and role ~= "HEALER" and role ~= "TANK" then
    --         return false, L["Invalid role"]
    --     end
    -- else
    --     return false, L["Invalid import type"]
    -- end

    return true
end

local DFTalentImportMixin = {
    ImportLoadout = function (self, importText, loadoutName)
        local importStream = ExportUtil.MakeImportDataStream(importText);
        local headerValid, serializationVersion, specID, treeHash = self:ReadLoadoutHeader(importStream);

        if not headerValid then
            return false, LOADOUT_ERROR_BAD_STRING
        end

        local currentSerializationVersion = C_Traits.GetLoadoutSerializationVersion();
        if serializationVersion ~= currentSerializationVersion then
            return false, LOADOUT_ERROR_SERIALIZATION_VERSION_MISMATCH
        end

        local classInfo = Internal.GetClassInfoBySpecID(specID);

        C_ClassTalents.InitializeViewLoadout(specID, GetMaxLevelForPlayerExpansion());
        C_ClassTalents.ViewLoadout({});

        local treeID = C_ClassTalents.GetTraitTreeForSpec(specID)
        local treeInfo = C_Traits.GetTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, treeID);
        if not self:IsHashEmpty(treeHash) then
            -- allow third-party sites to generate loadout strings with an empty tree hash, which bypasses hash validation
            if not self:HashEquals(treeHash, C_Traits.GetTreeHash(treeInfo.ID)) then
                return false, LOADOUT_ERROR_TREE_CHANGED;
            end
        end

        local loadoutContent = self:ReadLoadoutContent(importStream, treeInfo.ID);
        local loadoutEntryInfo = self:ConvertToImportLoadoutEntryInfo(treeInfo.ID, loadoutContent);
        
        local _, specName = GetSpecializationInfoByID(specID);

        local result = {};

        result.version = 1;
        result.type = "dftalents";
        result.name = format(loadoutName or L["New %s Set"], specName);
        result.treeID = treeInfo.ID;
        result.specID = specID;
        result.classID = classInfo.classID;

        result.nodes = loadoutEntryInfo;

        return true, result
    end,
    ConvertToImportLoadoutEntryInfo = function (self, treeID, loadoutContent)
        local results = {};
        local treeNodes = C_Traits.GetTreeNodes(treeID);
        local count = 1;
        for i, treeNodeID in ipairs(treeNodes) do
            local indexInfo = loadoutContent[i];
            if indexInfo.isNodeSelected then
                local treeNode = C_Traits.GetNodeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, treeNodeID);
                if indexInfo.isChoiceNode then
                    results[treeNodeID] = indexInfo.choiceNodeSelection;
                else
                    results[treeNodeID] = indexInfo.isPartiallyRanked and indexInfo.partialRanksPurchased or treeNode.maxRanks;
                end
            end
        end
        return results;
    end,
}

local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn
local DFTalentImport
DFTalentImport = {
    ImportLoadout = function (...)
        LoadAddOn("Blizzard_ClassTalentUI")
        LoadAddOn("Blizzard_PlayerSpells")
        Mixin(DFTalentImport, ClassTalentImportExportMixin, DFTalentImportMixin or {});
        return DFTalentImport.ImportLoadout(...)
    end
}

-- Import Frame
do
	local function GetUniqueName(setType, name)
		if not Internal.GetSetByName(setType, name) then
			return name
		end

		local index = 2
		while Internal.GetSetByName(setType, format("%s (%d)", name, index)) do
			index = index + 1
		end

		return format("%s (%d)", name, index)
	end
	local function AddSource(source, sourceType, version, name, ...)
		sourceType = source.type or sourceType
		version = source.version or version
		name = source.name or name
		
		if sourceType == "loadout" then
			assert(version == 2, "Unsupported loadout version")

			local name = GetUniqueName("profiles", name)
            for _,segment in Internal.EnumerateLoadoutSegments() do
                if segment.import and source[segment.id] then
                    for i=#source[segment.id],1,-1 do
                        if not source[segment.id][i] then
                            table.remove(source[segment.id], i)
                        end
                    end

                    for index,set in ipairs(source[segment.id]) do
                        if type(set) == "table" then
                            set = AddSource(set, segment.id, 1, name)
                            source[segment.id][index] = set
                        end
                        
                        set = segment.get(set)
                        set.useCount = (set.useCount or 0) + 1
                    end
                end
            end

            local set = Internal.ImportLoadout(source, version, name)
			return set.setID
        else
            local segment = Internal.GetLoadoutSegment(sourceType)
            if not segment then
                return false, L["Unknown source type"]
            end

			local name = GetUniqueName(segment.id, name)
            local set = segment.import(source, version, name, ...)
            return set.setID
		end
	end

	local currentImport
	BtWLoadoutsImportFrameMixin = {};
	function BtWLoadoutsImportFrameMixin:OnLoad()
        BackdropTemplateMixin.OnBackdropLoaded(self)
        if self.TooltipBackdropOnLoad then
            self:TooltipBackdropOnLoad()
        end

		tinsert(UISpecialFrames, self:GetName());
		self:RegisterForDrag("LeftButton");

		self.checkboxPool = CreateFramePool("CheckButton", self, "BtWLoadoutsImportCheckButtonTemplate")
	end
	function BtWLoadoutsImportFrameMixin:OnDragStart()
		self:StartMoving();
	end
	function BtWLoadoutsImportFrameMixin:OnDragStop()
		self:StopMovingOrSizing();
	end
	function BtWLoadoutsImportFrameMixin:OnShow()
		local source = currentImport
		if not source then
			self:Hide();
			return
		end

		self.checkboxPool:ReleaseAll()

		local previousButton = self.Name
        if source.type == "loadout" then
			self.Name:SetText(format(L["Importing Loadout \"%s\""], source.name))

            for _,segment in Internal.EnumerateLoadoutSegments() do
                local sets = source[segment.id]
                if sets then
                    for index,set in ipairs(sets) do
                        local button = self.checkboxPool:Acquire()
                        button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -5)

                        if type(set) == "number" then
                            local set = segment.get(set)
                            button.Text:SetText(format(L["Use existing %s set \"%s\""], segment.name, set.name))
                        else
                            button.Text:SetText(format(L["Include %s as \"%s\""], segment.name, set.name))
                        end

                        button.index = index
                        button.type = segment.id
                        button:SetChecked(true)
                        button:Show()

                        previousButton = button
                    end
                end
            end
        else
            local segment = Internal.GetLoadoutSegment(source.type)
            if not segment then
                return
            end

			self.Name:SetText(format(L["Importing %s \"%s\""], segment.name, source.name))
        end

		self:SetHeight(self:GetTop() - previousButton:GetBottom() + 45)
	end
	function BtWLoadoutsImportFrameMixin:Accept()
		local source = currentImport

		-- Remove parts that the user disabled
		if source.type == "loadout" then
			for button in self.checkboxPool:EnumerateActive() do
				if not button:GetChecked() then
					source[button.type][button.index] = false
				end
			end
		end

		local setID = AddSource(source)
		BtWLoadoutsFrame:SetSetByID(source.type, setID)

		currentImport = nil
		BtWLoadoutsImportFrame:Hide()
	end

	function Internal.UpdateImportFrame(source)
		BtWLoadoutsImportFrame:Hide()
		currentImport = source
		BtWLoadoutsImportFrame:Show()
	end
end
function External.Import(source)
    local success, err
    if type(source) == "string" then
        success, err = DFTalentImport:ImportLoadout(source)
        if success then -- Official DF Talents
            source = err;
        else
            success, source = Decode(source, err)
            if not success then
                return false, source
            end
    
            success, source = StringToTable(source)
            if not success then
                return false, source
            end
        end
    end
    if type(source) ~= "table" then
        return false, L["Invalid source type"]
    end

    success, err = VerifySource(source)
    if not success then
        return false, err
    end

    if source.type == "loadout" then
        -- Find existing sets with the same content
        for _,segment in Internal.EnumerateLoadoutSegments() do
            if source[segment.id] then
                for index,set in ipairs(source[segment.id]) do
                    local target = segment.getByValue(set)
                    if target then
                        source[segment.id][index] = target.setID
                    end
                end
            end
        end
    end
    
    Internal.UpdateImportFrame(source)

    return true
end

function Internal.Export(segmentType, id, format)
    if segmentType == "loadout" then
        local loadout = Internal.GetProfile(id)
        local result = {}

        assert(loadout.version == 2, "Unable to export loadouts that are not version 2")

        result.version = 2
        result.type = "loadout"
        result.name = loadout.name
        result.specID = loadout.specID

        for _,segment in Internal.EnumerateLoadoutSegments() do
            if segment.export and #loadout[segment.id] > 0 then
                local sets = {}
                for _,setID in ipairs(loadout[segment.id]) do
                    sets[#sets+1] = segment.export(segment.get(setID))
                end
                result[segment.id] = sets
            end
        end

        return Encode(TableToString(result), format or "BN")
    else
        local segment = Internal.GetLoadoutSegment(segmentType)
        assert(segment ~= nil)

        local set = segment.get(id)
        local result = segment.export(set)
        result.type = segment.id
        
        return Encode(TableToString(result), format or "BN")
    end
end
function External.Export(id, format)
    return Internal.Export("loadout", id, format)
end

-- /run BtWLoadoutsFrame:SetExport(BtWLoadouts.Export(1))
BtWLoadoutsImportMixin = {}
function BtWLoadoutsImportMixin:Update()
    self:GetParent():SetTitle(L["Import"]);

    self:GetParent().Sidebar:Hide()

    BtWLoadoutsFrame:SetNPEShown(false);

    self.Scroll.EditBox.text = ""
    self.Scroll.EditBox:SetText("")

    self:GetParent().RefreshButton:Hide();
    self:GetParent().ActivateButton:Hide();
    self:GetParent().ExportButton:Hide();
    self:GetParent().DeleteButton:Hide();
    self:GetParent().AddButton:Hide();
end
function BtWLoadoutsImportMixin:OnShow()
    self.Scroll.EditBox:SetFocus()
end
