---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.FrameTemplates; addon.C.FrameTemplates = NS

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS

end

--------------------------------
-- TEMPLATES
--------------------------------

do
	-- Creates a texture.
	---@param parent any
	---@param frameStrata string
	---@param texture string
	---@param name? string
	function NS:CreateTexture(parent, frameStrata, texture, name)
		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name or nil, parent)
		Frame:SetFrameStrata(frameStrata)

		local Texture = Frame:CreateTexture(tostring(name) .. "Texture" or nil, "BACKGROUND")
		Texture:SetAllPoints(Frame, true)
		Texture:SetTexture(texture)

		--------------------------------

		do -- LOGIC
			do -- FUNCTIONS
				do -- GET
					-- Returns the texture's id
					function Texture:GetId()
						return Texture.C_REFERENCE_REGISTRY_ID
					end

					-- Returns the texture's class
					function Texture:GetClass()
						return Texture.C_REFERENCE_REGISTRY_CLASS
					end
				end

				do -- SET
					-- Adds the texture to the reference registry under an id. The id must be unique.
					---@param id string
					function Texture:SetId(id)
						TagManager.Id:Add(Texture, id)
					end

					-- Adds the texture to the reference registry under a class. The class may contain multiple frames.
					---@param class string
					function Texture:SetClass(class)
						TagManager.Class:Add(Texture, class)
					end

					-- Removes the texture from the reference registry under an id.
					function Texture:RemoveId()
						TagManager.Id:Remove(Texture:GetId())
					end

					-- Removes the texture from the reference registry in a class.
					function Texture:RemoveClass()
						TagManager.Class:Remove(Texture, Frame:GetClass())
					end
				end
			end
		end

		--------------------------------

		return Frame, Texture
	end

	-- Creates a NineSlice with any texture.
	---@param parent any
	---@param frameStrata string
	---@param path string
	---@param margin number|table
	---@param size number
	---@param name? string
	---@param sliceMode? number
	function NS:CreateNineSlice(parent, frameStrata, path, margin, size, name, sliceMode)
		local margins
		if type(margin) == "table" then
			margins = { margin.left, margin.top, margin.right, margin.bottom }
		else
			margins = { margin or 50, margin or 50, margin or 50, margin or 50 }
		end

		--------------------------------

		local Frame, FrameTexture = addon.C.FrameTemplates:CreateTexture(parent, frameStrata, path, name or nil)
		FrameTexture:SetTextureSliceMargins(margins[1], margins[2], margins[3], margins[4])
		FrameTexture:SetTextureSliceMode(sliceMode or Enum.UITextureSliceMode.Tiled)
		FrameTexture:SetScale(size or 1)

		--------------------------------

		return Frame, FrameTexture
	end

	-- Creates a backdrop.
	---@param parent any
	---@param frameStrata string
	---@param color table
	---@param borderColor table
	---@param edgeSize? number
	---@param name? string
	function NS:CreateBackdrop(parent, frameStrata, color, borderColor, edgeSize, name)
		local EdgeSize = edgeSize or 12
		local Backdrop =
		{
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileEdge = true,
			tileSize = 8,
			edgeSize = EdgeSize,
			insets = { left = 1, right = 1, top = 1, bottom = 1 },
		}

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name or nil, parent, BackdropTemplateMixin and "BackdropTemplate")
		Frame:SetBackdrop(Backdrop)
		Frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		Frame:SetBackdropColor(color.r, color.g, color.b, color.a)
		Frame:SetFrameStrata(frameStrata)

		--------------------------------

		return Frame
	end

	-- Creates an advanced backdrop.
	---@param parent any
	---@param bgFile string
	---@param edgeFile string
	---@param color table
	---@param borderColor table
	---@param tileSize number
	---@param edgeSize number
	---@param name? string
	function NS:CreateCustomBackdrop(parent, frameStrata, bgFile, edgeFile, color, borderColor, tileSize, edgeSize, name)
		local TileSize = tileSize or 8
		local EdgeSize = edgeSize or 12
		local Backdrop =
		{
			bgFile = bgFile or "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = edgeFile or "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileEdge = true,
			tileSize = TileSize,
			edgeSize = EdgeSize,
			insets = { left = TileSize, right = TileSize, top = TileSize, bottom = TileSize },
		}

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name or nil, parent, BackdropTemplateMixin and "BackdropTemplate")
		Frame:SetBackdrop(Backdrop)
		Frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		Frame:SetBackdropColor(color.r, color.g, color.b, color.a)
		Frame:SetFrameStrata(frameStrata)

		--------------------------------

		return Frame
	end
end
