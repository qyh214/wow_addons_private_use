local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name
local FrameHolder = G.FrameHolder

----------------------------------------------------------
-----------------[[    团队私人光环    ]]-------------------
----------------------------------------------------------
local RaidPAFrame = CreateFrame("Frame", addon_name.."PAFrame", FrameHolder)
RaidPAFrame:SetSize(200, 200)
RaidPAFrame.unitframes = {}

RaidPAFrame.movingname = L["团队PA光环"]
RaidPAFrame.point = { a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -20}
T.CreateDragFrame(RaidPAFrame)

T.CopyGroupPANote = function()	
	local button = JSTtoolsScrollAnchor.pa_copy_mrt
	local str = [[
		#jst_pa_start
		player player player player player
		player player player player player
		player player player player player
		player player player player player
		end
	]]
	
	str = gsub(str, "	", "")
	T.DisplayCopyString(button, str)
end

local function Hook_PrivateAura_Anchor(uf)
	local unit = T.GUIDToUnit(uf.GUID)
	if not unit then return end
	for i = 1, 4 do
		if not uf["auraAnchorID"..i] then
			uf["auraAnchorID"..i] = C_UnitAuras.AddPrivateAuraAnchor({
				unitToken = unit,
				auraIndex = i,
				parent = uf,
				showCountdownFrame = true,
				showCountdownNumbers = false,
				iconInfo = {
					iconWidth = C.DB["GeneralOption"]["raid_pa_height"],
					iconHeight = C.DB["GeneralOption"]["raid_pa_height"],
					iconAnchor = {
						point = "LEFT",
						relativeTo = uf,
						relativePoint = "RIGHT",
						offsetX = 2+(i-1)*(C.DB["GeneralOption"]["raid_pa_height"]+2),
						offsetY = 0,
					},
				},
			})
		end
	end
end

local function Remove_PrivateAura_Anchor(uf)
	for i = 1, 4 do
		if uf["auraAnchorID"..i] then
			C_UnitAuras.RemovePrivateAuraAnchor(uf["auraAnchorID"..i])
			uf["auraAnchorID"..i] = nil
		end
	end
end

local function GetUFSize()
	local width = C.DB["GeneralOption"]["raid_pa_width"]
	local height = C.DB["GeneralOption"]["raid_pa_height"]
	local icon_num = C.DB["GeneralOption"]["raid_pa_icon_num"]
	local full_width = width+2+icon_num*(height+2)
	return width, height, full_width
end

local function Create_PrivateAura_UF(GUID, column_num, row_num)
	local uf = CreateFrame("Frame", nil, RaidPAFrame)
	
	uf.text = T.createtext(uf, "OVERLAY", 10, "OUTLINE", "CENTER")
	uf.text:SetPoint("LEFT", uf, "LEFT", 3, 0)
	uf.text:SetText(T.ColorNickNameByGUID(GUID))
	
	T.createborder(uf, .3, .3, .3)
	
	if GUID == G.PlayerGUID then
		uf.sd:SetBackdropColor(0, 1, 0)
	end
	
	function uf:update_onedit()
		local width, height, full_width = GetUFSize()
		uf:SetSize(width, height)
		
		local font_size = C.DB["GeneralOption"]["raid_pa_fsize"]
		uf.text:SetFont(G.Font, font_size, "OUTLINE")
		
		local uf_x = (column_num-1)*(full_width+5)
		local uf_y = -(row_num-1)*(height+3)
		uf:ClearAllPoints()
		uf:SetPoint("TOPLEFT", RaidPAFrame, "TOPLEFT", uf_x, -uf_y)
	end
	
	uf.GUID = GUID
	Hook_PrivateAura_Anchor(uf)	
	
	uf:update_onedit()
	
	table.insert(RaidPAFrame.unitframes, uf)
end

T.EditRaidPAFrame = function(option)
	if option == "all" or option == "enable" then
		if C.DB["GeneralOption"]["raid_pa"] then
			T.RestoreDragFrame(RaidPAFrame)
			RaidPAFrame:RegisterEvent("ENCOUNTER_START")
			RaidPAFrame:RegisterEvent("ENCOUNTER_END")
		else
			T.ReleaseDragFrame(RaidPAFrame)
			RaidPAFrame:UnregisterEvent("ENCOUNTER_START")
			RaidPAFrame:RegisterEvent("ENCOUNTER_END")
			RaidPAFrame:release_all()
		end
	end
	
	if option == "all" or option == "size" then
		local row_num, column_num = 0, 0
		
		for lineCount, line in T.IterateNoteAssignment("jst_pa_") do
			local GUIDs = T.LineToGUIDArray(line)
			if next(GUIDs) then
				row_num = max(#GUIDs, row_num)
				column_num = column_num + 1
			end
		end
		
		for i, uf in pairs(RaidPAFrame.unitframes) do
			uf:update_onedit()
		end
		
		row_num = max(1, row_num)
		column_num = max(1, column_num)
		
		local width, height, full_width = GetUFSize()
		local frame_width = column_num*full_width+(column_num-1)*5
		local frame_height = row_num*(height+3)-3
		RaidPAFrame:SetSize(frame_width, frame_height)
	end
end

function RaidPAFrame:generate_all()
	local row_num, column_num = 0, 0
	for lineCount, line in T.IterateNoteAssignment("jst_pa_") do
		local GUIDs = T.LineToGUIDArray(line)
		if next(GUIDs) then
			row_num = max(#GUIDs, row_num)
			column_num = column_num + 1
			for i, GUID in pairs(GUIDs) do
				Create_PrivateAura_UF(GUID, column_num, i)
			end
		end
	end
	
	row_num = max(1, row_num)
	column_num = max(1, column_num)
	
	local width, height, full_width = GetUFSize()
	local frame_width = column_num*full_width+(column_num-1)*5
	local frame_height = row_num*(height+3)-3
	RaidPAFrame:SetSize(frame_width, frame_height)
	RaidPAFrame:Show()
end

function RaidPAFrame:release_all()
	for i, uf in pairs(RaidPAFrame.unitframes) do
		uf:Hide()
		Remove_PrivateAura_Anchor(uf)
	end
	RaidPAFrame.unitframes = table.wipe(RaidPAFrame.unitframes)
	RaidPAFrame:Hide()
end

RaidPAFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RaidPAFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ENCOUNTER_START" then
		local _, _, _, groupSize = ...
		if groupSize > 5 then
			self:generate_all()
		end
	elseif event == "ENCOUNTER_END" then
		self:release_all()
	end
end)

function RaidPAFrame:PreviewShow()
	self:generate_all()
end

function RaidPAFrame:PreviewHide()
	self:release_all()
end

