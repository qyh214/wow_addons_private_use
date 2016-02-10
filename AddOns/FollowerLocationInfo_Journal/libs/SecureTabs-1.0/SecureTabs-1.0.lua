--[[
Copyright 2013 João Cardoso
SecureTabs is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of SecureTabs.

SecureTabs is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

SecureTabs is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SecureTabs. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib, Old = LibStub:NewLibrary('SecureTabs-1.0', 6)
if not Lib then
	return
elseif Old then
	Lib.Update = function() end
end

function Lib:Startup(parent, ...)
	if parent.secureTabs then
		return
	end

	local secure = CreateFrame('Frame', '$parentSecureTabs', parent, 'SecureHandlerAttributeTemplate')
	for i = 1, select('#', ...) do
		secure:SetFrameRef('panel' .. i, select(i, ...))
		secure[i] = _G[parent:GetName() .. 'Tab' .. i]
		secure[i]:SetScript('OnClick',  self.OnClick)
		secure[i].panel = select(i, ...)
	end

	secure:SetAttribute('_onattributechanged', [[
		if name == 'selected' then
			for i = 1, self:GetAttribute('numTabs') do
				local panel = self:GetFrameRef('panel' .. i)
				if panel then
					if i == value then
						panel:Show()
					else
						panel:Hide()
					end
				end
			end
		end
	]])

	parent.secureTabs = secure
end

function Lib:Add(parent, panel, label, anchor)
	local numTabs = parent.numTabs or 0
	local id = numTabs + 1
	local tab = CreateFrame('Button', '$parentTab' .. id, parent, 'CharacterFrameTabButtonTemplate', id)
	tab:SetScript('OnClick', self.OnClick)
	tab.Open = self.OnClick
	tab:SetText(label)

	if anchor then
		for k = 1, numTabs do
			if parent.secureTabs[k].panel == anchor then
				anchor = k+1
			end
		end
	end

	parent.numTabs = id
	parent.secureTabs:SetFrameRef('panel' .. id, panel)
	parent.secureTabs:SetAttribute('numTabs', parent.numTabs)
	tinsert(parent.secureTabs, anchor or numTabs, tab)
	PanelTemplates_UpdateTabs(parent)

	for k = 1, numTabs do
		parent.secureTabs[k+1]:SetPoint('TOPLEFT', parent.secureTabs[k], 'TOPRIGHT', -16, 0)
	end
	parent.secureTabs[1]:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', 11, 2)

	return tab
end

function Lib:OnClick()
	local parent = self:GetParent()
	if parent and parent.secureTabs then
		PanelTemplates_SetTab(parent, self:GetID())
		parent.secureTabs:SetAttribute('selected', parent.selectedTab)
	end
end