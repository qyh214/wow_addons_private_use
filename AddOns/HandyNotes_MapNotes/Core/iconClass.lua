-- IconClass.lua
-- Written by KyrosKrane Sylvanblade (kyros@kyros.info)
-- Copyright (c) 2018 KyrosKrane Sylvanblade
-- Licensed under the MIT License, as per the included file.

-- File revision: @file-abbreviated-hash@
-- File last updated: @file-date-iso@


--#########################################
--# Description
--#########################################

-- This file creates a class that can be used to store information on icons.
-- Methods are available to get a text string to display those icons inline with text.

-- The normal way of handling icons is to create a texture, load the icon file into that, set the region you want, and done.
-- However, we need to embed icons into a text string; for example, to display in an LDB label.
-- So, we create a custom object to hold icon information, and give it a method to create a text string to display that icon.
-- That text string can then be embedded in the LDB label to show the icon.


--#########################################
--# Global to local references
--#########################################

-- Get local references to globals
local setmetatable = setmetatable
local string = string


--#########################################
--# Icon class setup
--#########################################

-- Create the object class
-- Adapted from http://lua-users.org/wiki/ObjectOrientationTutorial

IconClass = {}
IconClass.__index = IconClass

setmetatable(IconClass, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})


--#########################################
--# Constructor
--#########################################

-- Create the constructor
function IconClass.new(iconfile, IconFileX, IconFileY, StartX, EndX, StartY, EndY)
	local self = setmetatable({}, IconClass)

	-- The caller has to specify an iconfile before actually using the class, or the results will not be what is expected.
	self.IconFile = iconfile or ""	-- the game file that has the icon we want

	-- The initial values are sane defaults, but they should be updated for each icon.

	-- These settings control the display of the icon
	self.SizeOne = 0	-- SizeOne and SizeTwo jointly control the size of the icon. The logic is not intuitive.
	self.SizeTwo = nil	-- For more details on the SizeOne and SizeTwo parameters, see http://wowwiki.wikia.com/wiki/UI_escape_sequences#Textures
						-- For the purposes of our icons, they should always be 0 and nil (indicating a square sized to the height of the text).

	self.OffsetX = 0	-- This moves the image n pixels horizontally in the final display. For our icons, it's always 0.
	self.OffsetY = 0	-- This moves the image n pixels vertically in the final display. For our icons, it's always 0.

	-- These settings control the extraction of the icon from a bigger texture file
	self.IconFileX = IconFileX or 0	-- the total X (horizontal) pixels in the image file - not just the icon we want
	self.IconFileY = IconFileY or 0	-- the total Y (vertical) pixels in the image file
	self.StartX = StartX or 0		-- The starting point in the file where the icon begins, counted from the left border, in pixels
	self.EndX = EndX or 0			-- The ending point in the file where the icon ends, counted from the left border, in pixels
	self.StartY = StartY or 0		-- The starting point in the file where the icon begins, counted from the top border, in pixels
	self.EndY = EndY or 0			-- The ending point in the file where the icon ends, counted from the top border, in pixels

	return self
end -- IconClass.new()


--#########################################
--# Methods
--#########################################

-- Gets the display string without the control codes that make WoW display it as an icon.
-- Useful for debugging or when there's additional text that needs to be added or modified before the control codes are added.
function IconClass:GetIconStringInner()
	-- Icon strings effectively have to be built right to left, since if the rightmost parameters are required, then the ones to the left are also required.

	-- This function constructs the inner part of the icon string, without the control codes to cause it to display as an actual icon.
	-- This is mostly useful for debugging. In actual use, you'd want the GetIconString() function.

	local required = false -- tells us whether the remaining parameters are required

	local OutputString = "";

	if required or self.StartX > 0 or self.StartY > 0 or self.EndX > 0 or self.EndY > 0 then
		required = true
		OutputString = string.format(":%d:%d:%d:%d", self.StartX, self.EndX, self.StartY, self.EndY)
	end

	if required or self.IconFileX > 0 or self.IconFileY > 0 then
		required = true
		OutputString = string.format(":%d:%d%s", self.IconFileX, self.IconFileY, OutputString)
	end

	if required or self.OffsetX > 0 or self.OffsetY > 0 then
		required = true
		OutputString = string.format(":%d:%d%s", self.OffsetX, self.OffsetY, OutputString)
	end

	-- Size2 can be nil, so to avoid comparing or concatenating a nil, we have some special handling
	if required or (self.SizeTwo and self.SizeTwo >= 0) then
		OutputString = string.format(":%s%s", (self.SizeTwo or ""), OutputString)
	end

	-- Size1 and the icon path are required.
	OutputString = string.format("%s:%d%s", self.IconFile, self.SizeOne, OutputString)

	return OutputString
end -- IconClass:GetIconStringInner()


-- Gets a string that, when printed in the UI, is converted to an icon shown inline in the text.
function IconClass:GetIconString()
	-- This function wraps the icon string in the control code that causes it to display as an icon
	return string.format("\124T%s\124t", self:GetIconStringInner())
end -- IconClass:GetIconString()


-- @TODO: Add method to get the TexCoords of an icon for inclusion in the LDB object's iconCoords parameter.
-- See:
--	https://wow.gamepedia.com/API_Texture_SetTexCoord
--	https://github.com/tekkub/libdatabroker-1-1/wiki/Data-Specifications
--	https://us.battle.net/forums/en/wow/topic/20752506801

-- Escape sequence reference:
--	http://wowwiki.wikia.com/wiki/UI_escape_sequences#Grammar