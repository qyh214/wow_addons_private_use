
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@cast detailsFramework detailsframework

local CreateFrame = CreateFrame
local unpack = unpack
local wipe = table.wipe
local _

--[=[
    file description: this file has the code for the object editor
    the object editor itself is a frame and has a scrollframe as canvas showing another frame where there's the options for the editing object

--]=]


--the editor doesn't know which key in the profileTable holds the current value for an attribute, so it uses a map table to find it.
--the mapTable is a table with the attribute name as a key, and the value is the profile key. For example, {["size"] = "text_size"} means profileTable["text_size"] = 10.

---@class df_editor_attribute
---@field name string?
---@field label string?
---@field widget string
---@field default any?
---@field minvalue number?
---@field maxvalue number?
---@field step number?
---@field usedecimals boolean?
---@field subkey string?

--which object attributes are used to build the editor menu for each object type
local attributes = {
    ---@type df_editor_attribute[]
    FontString = {
        {
            name = "text",
            label = "Text",
            widget = "textentry",
            default = "font string text",
            setter = function(widget, value) widget:SetText(value) end,
        },
        {
            name = "size",
            label = "Size",
            widget = "range",
            minvalue = 5,
            maxvalue = 120,
            setter = function(widget, value) widget:SetFont(widget:GetFont(), value, select(3, widget:GetFont())) end
        },
        {
            name = "font",
            label = "Font",
            widget = "fontdropdown",
            setter = function(widget, value)
                local font = LibStub:GetLibrary("LibSharedMedia-3.0"):Fetch("font", value)
                widget:SetFont(font, select(2, widget:GetFont()))
            end
        },
        {
            name = "color",
            label = "Color",
            widget = "color",
            setter = function(widget, value) widget:SetTextColor(unpack(value)) end
        },
        {
            name = "alpha",
            label = "Alpha",
            widget = "range",
            setter = function(widget, value) widget:SetAlpha(value) end
        },
        {widget = "blank"},
        {
            name = "shadow",
            label = "Draw Shadow",
            widget = "toggle",
            setter = function(widget, value) widget:SetShadowColor(widget:GetShadowColor(), select(2, widget:GetShadowColor()), select(3, widget:GetShadowColor()), value and 0.5 or 0) end
        },
        {
            name = "shadowcolor",
            label = "Shadow Color",
            widget = "color",
            setter = function(widget, value) widget:SetShadowColor(unpack(value)) end
        },
        {
            name = "shadowoffsetx",
            label = "Shadow X Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(value, select(2, widget:GetShadowOffset())) end
        },
        {
            name = "shadowoffsety",
            label = "Shadow Y Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(widget:GetShadowOffset(), value) end
        },
        {
            name = "outline",
            label = "Outline",
            widget = "outlinedropdown",
            setter = function(widget, value) widget:SetFont(widget:GetFont(), select(2, widget:GetFont()), value) end
        },
        {widget = "blank"},
        {
            name = "anchor",
            label = "Anchor",
            widget = "anchordropdown",
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "anchoroffsetx",
            label = "Anchor X Offset",
            widget = "range",
            minvalue = -100,
            maxvalue = 100,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -100,
            maxvalue = 100,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "rotation",
            label = "Rotation",
            widget = "range",
            usedecimals = true,
            minvalue = 0,
            maxvalue = math.pi*2,
            setter = function(widget, value) widget:SetRotation(value) end
        },
        {
            name = "scale",
            label = "Scale",
            widget = "range",
            usedecimals = true,
            minvalue = 0.65,
            maxvalue = 2.5,
            setter = function(widget, value) widget:SetScale(value) end
        },
    }
}

---@class df_editormixin : table
---@field GetAllRegisteredObjects fun(self:df_editor):df_editor_objectinfo[]
---@field GetEditingObject fun(self:df_editor):uiobject
---@field GetEditingOptions fun(self:df_editor):df_editobjectoptions
---@field GetExtraOptions fun(self:df_editor):table
---@field GetEditingProfile fun(self:df_editor):table, table
---@field GetOnEditCallback fun(self:df_editor):function
---@field GetOptionsFrame fun(self:df_editor):frame
---@field GetCanvasScrollBox fun(self:df_editor):df_canvasscrollbox
---@field GetObjectSelector fun(self:df_editor):df_scrollbox
---@field EditObject fun(self:df_editor, object:uiobject, profileTable:table, profileKeyMap:table, extraOptions:table?, callback:function?, options:df_editobjectoptions?)
---@field PrepareObjectForEditing fun(self:df_editor)
---@field CreateMoverGuideLines fun(self:df_editor)
---@field GetOverTheTopFrame fun(self:df_editor):frame
---@field GetMoverFrame fun(self:df_editor):frame
---@field StartObjectMovement fun(self:df_editor, anchorSettings:df_anchor)
---@field StopObjectMovement fun(self:df_editor)

---@class df_editobjectoptions : table
---@field use_colon boolean if true a colon is shown after the option name
---@field can_move boolean if true the object can be moved
---@field use_guide_lines boolean if true guide lines are shown when the object is being moved

---@type df_editobjectoptions
local editObjectDefaultOptions = {
    use_colon = true,
    can_move = true,
    use_guide_lines = true,
}

local getParentTable = function(profileTable, profileKey)
    local parentPath
    if (profileKey:match("%]$")) then
        parentPath = profileKey:gsub("%s*%[.*%]%s*$", "")
    else
        parentPath = profileKey:gsub("%.[^.]*$", "")
    end

    local parentTable = detailsFramework.table.getfrompath(profileTable, parentPath)
    return parentTable
end

detailsFramework.EditorMixin = {
    ---@param self df_editor
    GetEditingObject = function(self)
        return self.editingObject
    end,

    ---@param self df_editor
    ---@return df_editobjectoptions
    GetEditingOptions = function(self)
        return self.editingOptions
    end,

    ---@param self df_editor
    ---@return table
    GetExtraOptions = function(self)
        return self.editingExtraOptions
    end,

    ---@param self df_editor
    ---@return table, table
    GetEditingProfile = function(self)
        return self.editingProfileTable, self.editingProfileMap
    end,

    ---@param self df_editor
    ---@return function
    GetOnEditCallback = function(self)
        return self.onEditCallback
    end,

    GetOptionsFrame = function(self)
        return self.optionsFrame
    end,

    GetOverTheTopFrame = function(self)
        return self.overTheTopFrame
    end,

    GetMoverFrame = function(self)
        return self.moverFrame
    end,

    GetCanvasScrollBox = function(self)
        return self.canvasScrollBox
    end,

    GetObjectSelector = function(self)
        return self.objectSelector
    end,

    EditObjectById = function(self, id)
        ---@type df_editor_objectinfo
        local objectRegistered = self:GetObjectById(id)
        assert(type(objectRegistered) == "table", "EditObjectById() object not found.")
        self:EditObject(objectRegistered)
    end,

    EditObjectByIndex = function(self, index)
        ---@type df_editor_objectinfo
        local objectRegistered = self:GetObjectByIndex(index)
        assert(type(objectRegistered) == "table", "EditObjectById() object not found.")
        self:EditObject(objectRegistered)
    end,

    ---@param self df_editor
    ---@param registeredObject df_editor_objectinfo
    EditObject = function(self, registeredObject)
        --clear previous values
        self.editingObject = nil
        self.editingProfileMap = nil
        self.editingProfileTable = nil
        self.editingOptions = nil
        self.editingExtraOptions = nil
        self.onEditCallback = nil

        local object = registeredObject.object
        local profileTable = registeredObject.profiletable
        local profileKeyMap = registeredObject.profilekeymap
        local extraOptions = registeredObject.extraoptions
        local callback = registeredObject.callback
        local options = registeredObject.options

        --as there's no other place which this members are set, there is no need to create setter functions
        self.editingObject = object
        self.editingProfileMap = profileKeyMap
        self.editingProfileTable = profileTable
        self.editingOptions = options
        self.editingExtraOptions = extraOptions

        if (type(callback) == "function") then
            self.onEditCallback = callback
        end

        self:PrepareObjectForEditing()
    end,

    ---@param self df_editor
    CreateMoverGuideLines = function(self)
        local overTheTopFrame = self:GetOverTheTopFrame()
        local moverFrame = self:GetMoverFrame()

        self.moverGuideLines = {
            left = overTheTopFrame:CreateTexture(nil, "overlay"),
            right = overTheTopFrame:CreateTexture(nil, "overlay"),
            top = overTheTopFrame:CreateTexture(nil, "overlay"),
            bottom = overTheTopFrame:CreateTexture(nil, "overlay"),
        }

        for side, texture in pairs(self.moverGuideLines) do
            texture:SetColorTexture(.8, .8, .8, 0.1)
            texture:SetSize(1, 1)
            texture:SetDrawLayer("overlay", 7)
            texture:Hide()

            if (side == "left" or side == "right") then
                texture:SetHeight(1)
                texture:SetWidth(GetScreenWidth())
            else
                texture:SetWidth(1)
                texture:SetHeight(GetScreenHeight())
            end
        end
    end,

    UpdateGuideLinesAnchors = function(self)
        local object = self:GetEditingObject()

        for side, texture in pairs(self.moverGuideLines) do
            texture:ClearAllPoints()
            if (side == "left" or side == "right") then
                if (side == "left") then
                    texture:SetPoint("right", object, "left", -2, 0)
                else
                    texture:SetPoint("left", object, "right", 2, 0)
                end
            else
                if (side == "top") then
                    texture:SetPoint("bottom", object, "top", 0, 2)
                else
                    texture:SetPoint("top", object, "bottom", 0, -2)
                end
            end
        end
    end,

    PrepareObjectForEditing = function(self)
        --get the object and its profile table with the current values
        local object = self:GetEditingObject()
        local profileTable, profileMap = self:GetEditingProfile()
        profileMap = profileMap or {}

        if (not object or not profileTable) then
            return
        end

        --get the object type
        local objectType = object:GetObjectType()
        local attributeList

        --get options and extra options
        local editingOptions = self:GetEditingOptions()
        local extraOptions = self:GetExtraOptions()

        --get the attribute list for the object type
        if (objectType == "FontString") then
            ---@cast object fontstring
            attributeList = attributes[objectType]
        end

        --if there's extra options, add the attributeList to a new table and right after the extra options
        if (extraOptions and #extraOptions > 0) then
            local attributeListWithExtraOptions = {}

            for i = 1, #attributeList do
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = attributeList[i]
            end

            attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = {widget = "blank", default = true}

            for i = 1, #extraOptions do
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = extraOptions[i]
            end

            attributeList = attributeListWithExtraOptions
        end

        local anchorSettings

        --table to use on DF:BuildMenu()
        local menuOptions = {}
        for i = 1, #attributeList do
            local option = attributeList[i]

            if (option.widget == "blank") then
                menuOptions[#menuOptions+1] = {type = "blank"}
            else
                --get the key to be used on profile table
                local profileKey = profileMap[option.name]
                local value

                --if the key contains a dot or a bracket, it means it's a table path, example: "text_settings[1].width"
                if (profileKey and (profileKey:match("%.") or profileKey:match("%["))) then
                    value = detailsFramework.table.getfrompath(profileTable, profileKey)
                else
                    value = profileTable[profileKey]
                end

                --if no value is found, attempt to get a default
                if (type(value) == "nil") then
                    value = option.default
                end

                local bHasValue = type(value) ~= "nil"

                local minValue = option.minvalue
                local maxValue = option.maxvalue

                if (option.name == "anchoroffsetx") then
                    minValue = -object:GetParent():GetWidth()/2
                    maxValue = object:GetParent():GetWidth()/2
                elseif (option.name == "anchoroffsety") then
                    minValue = -object:GetParent():GetHeight()/2
                    maxValue = object:GetParent():GetHeight()/2
                end

                if (option.name == "classcolor") then print("", value) end

                if (bHasValue) then
                    if (option.name == "classcolor") then print("HERE", value) end

                    local parentTable = getParentTable(profileTable, profileKey)

                    if (option.name == "anchor" or option.name == "anchoroffsetx" or option.name == "anchoroffsety") then
                        anchorSettings = parentTable
                    end

                    menuOptions[#menuOptions+1] = {
                        type = option.widget,
                        name = option.label,
                        get = function() return value end,
                        set = function(widget, fixedValue, newValue, ...)
                            --color is a table with 4 indexes for each color plus alpha
                            if (option.widget == "color") then
                                --calor callback sends the red color in the fixedParameter slot
                                local r, g, b, alpha = fixedValue, newValue, ...
                                --need to use the same table from the profile table
                                parentTable[1] = r
                                parentTable[2] = g
                                parentTable[3] = b
                                parentTable[4] = alpha

                                newValue = parentTable
                            else
                                detailsFramework.table.setfrompath(profileTable, profileKey, newValue)
                            end

                            if (self:GetOnEditCallback()) then
                                self:GetOnEditCallback()(object, option.name, newValue, profileTable, profileKey)
                            end

                            --update the widget visual
                            --anchoring uses SetAnchor() which require the anchorTable to be passed
                            if (option.name == "anchor" or option.name == "anchoroffsetx" or option.name == "anchoroffsety") then
                                anchorSettings = parentTable

                                if (option.name == "anchor") then
                                    anchorSettings.x = 0
                                    anchorSettings.y = 0
                                end

                                self:StopObjectMovement()

                                option.setter(object, parentTable)

                                if (editingOptions.can_move) then
                                    self:StartObjectMovement(anchorSettings)
                                end
                            else
                                option.setter(object, newValue)
                            end
                        end,
                        min = minValue,
                        max = maxValue,
                        step = option.step,
                        usedecimals = option.usedecimals,
                        id = option.name,
                    }
                end
            end
        end

        --at this point, the optionsTable is ready to be used on DF:BuildMenuVolatile()
        menuOptions.align_as_pairs = true
        menuOptions.align_as_pairs_length = 150
        menuOptions.widget_width = 180

        local optionsFrame = self:GetOptionsFrame()
        local canvasScrollBox = self:GetCanvasScrollBox()

        local bUseColon = editingOptions.use_colon

        local bSwitchIsCheckbox = true
        local maxHeight = 5000

        local amountOfOptions = #menuOptions
        local optionsFrameHeight = amountOfOptions * 20
        optionsFrame:SetHeight(optionsFrameHeight)

        --templates
        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        detailsFramework:BuildMenuVolatile(optionsFrame, menuOptions, 0, -2, maxHeight, bUseColon, options_text_template, options_dropdown_template, options_switch_template, bSwitchIsCheckbox, options_slider_template, options_button_template)

        if (editingOptions.can_move) then
            self:StartObjectMovement(anchorSettings)
        end
    end,

    ---@param self df_editor
    ---@param anchorSettings df_anchor
    StartObjectMovement = function(self, anchorSettings)
        local object = self:GetEditingObject()

        local moverFrame = self:GetMoverFrame()
        moverFrame:EnableMouse(true)
        moverFrame:SetMovable(true)
        moverFrame:ClearAllPoints()
        moverFrame:Show()

        --update guidelines
        if (self:GetEditingOptions().use_guide_lines) then
            --self:UpdateGuideLinesAnchors()
            --show all four guidelines
            for side, texture in pairs(self.moverGuideLines) do
                texture:Show()
            end
        end

        local optionsFrame = self:GetOptionsFrame()

        local objectWidth, objectHeight = object:GetSize()
        moverFrame:SetSize(objectWidth, objectHeight)
        detailsFramework:SetAnchor(moverFrame, anchorSettings, object:GetParent())
        local currentPosX, currentPosY

        moverFrame:SetScript("OnMouseDown", function()
            object:ClearAllPoints()
            object:SetPoint("topleft", moverFrame, "topleft", 0, 0)

            currentPosX, currentPosY = moverFrame:GetCenter()
            moverFrame.bIsMoving = true
            moverFrame:StartMoving()
        end)

        moverFrame:SetScript("OnMouseUp", function()
            moverFrame:StopMovingOrSizing()
            moverFrame.bIsMoving = false

            local originX = anchorSettings.x
            local originY = anchorSettings.y

            local newPosX, newPosY = moverFrame:GetCenter()

            local xOffset = newPosX - currentPosX
            local yOffset = newPosY - currentPosY

            anchorSettings.x = originX + xOffset
            anchorSettings.y = originY + yOffset

            local anchorXSlider = optionsFrame:GetWidgetById("anchoroffsetx")
            anchorXSlider:SetValueNoCallback(anchorSettings.x)

            local anchorYSlider = optionsFrame:GetWidgetById("anchoroffsety")
            anchorYSlider:SetValueNoCallback(anchorSettings.y)

            object:ClearAllPoints()
            detailsFramework:SetAnchor(object, anchorSettings, object:GetParent())
        end)

        --detailsFramework:SetAnchor(moverFrame, anchorSettings)
        --detailsFramework:SetAnchor(object, anchorSettings, moverFrame)

        moverFrame:SetScript("OnUpdate", function()
            --if the object isn't moving, make the mover follow the object position
            if (false and moverFrame.bIsMoving) then
                --object:ClearAllPoints()
                --object:SetPoint("topleft", moverFrame, "topleft", 0, 0)

                --if the object is moving, check if the moverFrame has moved
                local newPosX, newPosY = moverFrame:GetCenter()

                --did the frame moved?
                if (newPosX ~= currentPosX) then
                    local xOffset = newPosX - currentPosX
                    anchorSettings.x = anchorSettings.x + xOffset
                    local anchorXSlider = optionsFrame:GetWidgetById("anchoroffsetx")
                    anchorXSlider:SetValueNoCallback(anchorSettings.x)
                end

                if (newPosY ~= currentPosY) then
                    local yOffset = newPosY - currentPosY
                    anchorSettings.y = anchorSettings.y + yOffset
                    local anchorYSlider = optionsFrame:GetWidgetById("anchoroffsety")
                    anchorYSlider:SetValueNoCallback(anchorSettings.y)
                end

                currentPosX, currentPosY = newPosX, newPosY
            end

            --[=[
            --update the mover frame size to match the object size
            if (object:GetObjectType() == "FontString") then
                ---@cast object fontstring
                local width = object:GetStringWidth()
                local height = object:GetStringHeight()
                moverFrame:SetSize(width, height)
            else
                local width, height = object:GetSize()
                moverFrame:SetSize(width, height)
            end
            --]=]
        end)
    end,

    ---@param self df_editor
    StopObjectMovement = function(self)
        local moverFrame = self:GetMoverFrame()

        moverFrame:EnableMouse(false)
        moverFrame:SetScript("OnUpdate", nil)

        --hide all four guidelines
        for side, texture in pairs(self.moverGuideLines) do
            texture:Hide()
        end

        moverFrame:Hide()
    end,

    RegisterObject = function(self, object, localizedLabel, id, profileTable, profileKeyMap, extraOptions, callback, options)
        assert(type(object) == "table", "RegisterObjectToEdit() expects an UIObject on #1 parameter.")
        assert(object.GetObjectType, "RegisterObjectToEdit() expects an UIObject on #1 parameter.")
        assert(type(profileTable) == "table", "RegisterObjectToEdit() expects a table on #4 parameter.")
        assert(type(id) ~= "nil" and type(id) ~= "boolean", "RegisterObjectToEdit() expects an ID on parameter #3.")
        assert(type(callback) == "function" or callback == nil, "RegisterObjectToEdit() expects a function or nil as the #7 parameter.")

        local registeredObjects = self:GetAllRegisteredObjects()

        --is object already registered?
        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                error("RegisterObjectToEdit() object already registered.")
            end
        end

        --deploy the options table
        options = type(options) == "table" and options or {}
        detailsFramework.table.deploy(options, editObjectDefaultOptions)

        localizedLabel = type(localizedLabel) == "string" and localizedLabel or "invalid label"

        --a button to select the widget
        local selectButton = CreateFrame("button", "$parentSelectButton" .. id, object:GetParent())
        selectButton:SetAllPoints(object)

        ---@type df_editor_objectinfo
        local objectRegistered = {
            object = object,
            label = localizedLabel,
            id = id,
            profiletable = profileTable,
            profilekeymap = profileKeyMap,
            extraoptions = extraOptions or {},
            callback = callback,
            options = options,
            selectButton = selectButton,
        }

        selectButton:SetScript("OnClick", function()
            self:EditObject(objectRegistered)
        end)

        registeredObjects[#registeredObjects+1] = objectRegistered
        self.registeredObjectsByID[id] = objectRegistered

        local objectSelector = self:GetObjectSelector()
        objectSelector:RefreshMe()

        --what to do after an object is registered?
        return objectRegistered
    end,

    UnregisterObject = function(self, object)
        local registeredObjects = self:GetAllRegisteredObjects()

        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                self.registeredObjectsByID[objectRegistered.id] = nil
                table.remove(registeredObjects, i)
                break
            end
        end

        local objectSelector = self:GetObjectSelector()
        objectSelector:RefreshMe()

        --stop editing the object
    end,

    ---@param self df_editor
    ---@return df_editor_objectinfo[]
    GetAllRegisteredObjects = function(self)
        return self.registeredObjects
    end,

    ---@param self df_editor
    ---@return df_editor_objectinfo?
    GetObjectByRef = function(self, object)
        local registeredObjects = self:GetAllRegisteredObjects()
        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                return objectRegistered
            end
        end
    end,

    GetObjectByIndex = function(self, index)
        local registeredObjects = self:GetAllRegisteredObjects()
        return registeredObjects[index]
    end,

    GetObjectById = function(self, id)
        return self.registeredObjectsByID[id]
    end,

    CreateObjectSelectionList = function(self, scroll_width, scroll_height, scroll_lines, scroll_line_height)
        local editorFrame = self

        local refreshFunc = function(self, data, offset, totalLines) --~refresh
			for i = 1, totalLines do
				local index = i + offset
                ---@type df_editor_objectinfo
				local objectRegistered = data[index]

				if (objectRegistered) then
                    local line = self:GetLine(i)
                    line.index = index
                    if (objectRegistered.object:GetObjectType() == "Texture") then
                        line.Icon:SetTexture([[Interface\AnimCreate\AnimCreateIcons]])
                        line.Icon:SetTexCoord(1/4, 2/4, 1/4, 2/4)

                    elseif (objectRegistered.object:GetObjectType() == "Texture") then
                        line.Icon:SetTexture([[Interface\AnimCreate\AnimCreateIcons]])
                        line.Icon:SetTexCoord(2/4, 3/4, 0, 1/4)
                    end

                    line.Label:SetText(objectRegistered.label)
                end
            end
        end

		local createLineFunc = function(self, index) -- ~createline --~line
			local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
			line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize(scroll_width - 2, scroll_line_height)

			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            if (index % 2 == 0) then
                line:SetBackdropColor(.1, .1, .1, .1)
            else
                line:SetBackdropColor(.1, .1, .1, .4)
            end

			detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

			--line:SetScript("OnEnter", lineOnEnter)
			--line:SetScript("OnLeave", lineOnLeave)

            line:SetScript("OnClick", function(self)
                local objectRegistered = editorFrame:GetObjectByIndex(self.index)
                editorFrame:EditObject(objectRegistered)
            end)

			--icon
			local objectIcon = line:CreateTexture("$parentIcon", "overlay")
			objectIcon:SetSize(scroll_line_height - 2, scroll_line_height - 2)

			--object label
			local objectLabel = line:CreateFontString("$parentLabel", "overlay", "GameFontNormal")

            objectIcon:SetPoint("left", line, "left", 2, 0)
            objectLabel:SetPoint("left", objectIcon, "right", 2, 0)

			line.Icon = objectIcon
			line.Label = objectLabel

			return line
		end

        local selectObjectScrollBox = detailsFramework:CreateScrollBox(self:GetParent(), "$parentSelectObjectScrollBox", refreshFunc, editorFrame:GetAllRegisteredObjects(), scroll_width, scroll_height, scroll_lines, scroll_line_height)
        detailsFramework:ReskinSlider(selectObjectScrollBox)

		function selectObjectScrollBox:RefreshMe()
			selectObjectScrollBox:SetData(editorFrame:GetAllRegisteredObjects())
		    selectObjectScrollBox:Refresh()
		end

		--create lines
		for i = 1, scroll_lines do
			selectObjectScrollBox:CreateLine(createLineFunc)
		end

        return selectObjectScrollBox
    end,
}

---@class df_editor_defaultoptions : table
---@field width number
---@field height number
---@field create_object_list boolean
---@field object_list_width number
---@field object_list_height number
---@field object_list_lines number
---@field object_list_line_height number

---@class df_editor_defaultoptions
local editorDefaultOptions = {
    width = 400,
    height = 600,
    create_object_list = true,
    object_list_width = 200,
    object_list_height = 420,
    object_list_lines = 20,
    object_list_line_height = 20,
}

---@class df_editor : frame, df_optionsmixin, df_editormixin
---@field options table
---@field registeredObjects df_editor_objectinfo[]
---@field registeredObjectsByID table<any, df_editor_objectinfo>
---@field editingObject uiobject
---@field editingProfileTable table
---@field editingProfileMap table
---@field editingOptions df_editobjectoptions
---@field editingExtraOptions table
---@field moverGuideLines table<string, texture>
---@field onEditCallback function
---@field optionsFrame frame
---@field overTheTopFrame frame
---@field objectSelector df_scrollbox
---@field moverFrame frame
---@field canvasScrollBox df_canvasscrollbox

---@class df_editor_objectinfo : table
---@field object uiobject
---@field label string
---@field id any
---@field profiletable table
---@field profilekeymap table
---@field extraoptions table
---@field callback function
---@field options df_editobjectoptions
---@field selectButton button

function detailsFramework:CreateEditor(parent, name, options)
    name = name or ("DetailsFrameworkEditor" .. math.random(100000, 10000000))
    local editorFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(editorFrame, detailsFramework.EditorMixin)
    detailsFramework:Mixin(editorFrame, detailsFramework.OptionsFunctions)

    editorFrame.registeredObjects = {}
    editorFrame.registeredObjectsByID = {}

    editorFrame:BuildOptionsTable(editorDefaultOptions, options)

    editorFrame:SetSize(editorFrame.options.width, editorFrame.options.height)

    if (editorFrame.options.create_object_list) then
        local scrollWidth = editorFrame.options.object_list_width
        local scrollHeight = editorFrame.options.object_list_height
        local scrollLinesAmount = editorFrame.options.object_list_lines
        local scrollLineHeight = editorFrame.options.object_list_line_height

        local objectSelector = editorFrame:CreateObjectSelectionList(scrollWidth, scrollHeight, scrollLinesAmount, scrollLineHeight)
        objectSelector:SetPoint("topleft", editorFrame, "topright", 2, 0)
        editorFrame.objectSelector = objectSelector
        objectSelector:RefreshMe()
    end

    --options frame is the frame that holds the options for the editing object, it is used as the parent frame for BuildMenuVolatile()
    local optionsFrame = CreateFrame("frame", name .. "OptionsFrame", editorFrame, "BackdropTemplate")
    optionsFrame:SetSize(editorFrame.options.width, 5000)

    local canvasFrame = detailsFramework:CreateCanvasScrollBox(editorFrame, optionsFrame, name .. "CanvasScrollBox")
    canvasFrame:SetAllPoints()

    --over the top frame is a frame that is always on top of everything else
    local OTTFrame = CreateFrame("frame", "$parentOTTFrame", UIParent)
    OTTFrame:SetFrameStrata("TOOLTIP")
    editorFrame.overTheTopFrame = OTTFrame

    --frame that is used to move the object
    local moverFrame = CreateFrame("frame", "$parentMoverFrame", OTTFrame, "BackdropTemplate")
    moverFrame:SetClampedToScreen(true)
    detailsFramework:ApplyStandardBackdrop(moverFrame)
    moverFrame:SetBackdropColor(.10, .10, .10, 0)
    moverFrame.__background:SetAlpha(0.1)
    editorFrame.moverFrame = moverFrame

    editorFrame:CreateMoverGuideLines()

    editorFrame.optionsFrame = optionsFrame
    editorFrame.canvasScrollBox = canvasFrame

    return editorFrame
end
