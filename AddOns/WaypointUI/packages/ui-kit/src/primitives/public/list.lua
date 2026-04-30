local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_List = env.modules:New("packages\\ui-kit\\primitives\\list")

local Mixin = Mixin
local tinsert = table.insert
local tremove = table.remove
local ipairs = ipairs
local type = type

local DEFAULT_TYPE_KEY = "Default"
local ListMixin = {}

local function MoveFrameChildToEnd(parentFrame, childFrame)
    if not parentFrame or not childFrame then return end

    local children = parentFrame.GetFrameChildren and parentFrame:GetFrameChildren()
    if not children then return end

    local childIndex = nil
    for i = 1, #children do
        if children[i] == childFrame then
            childIndex = i
            break
        end
    end

    if not childIndex or childIndex == #children then
        return
    end

    tremove(children, childIndex)
    tinsert(children, childFrame)
end

function ListMixin:Init()
    self.__onElementUpdateFunc = nil
    self.__onElementVisibilityChangedFunc = nil

    self.__elementPool = {}
    self.__elementPoolTypeIndex = {}
    self.__data = nil
    self.__templateConstructorFunc = {}
end

function ListMixin:SetOnElementUpdate(func)
    self.__onElementUpdateFunc = func
end

function ListMixin:SetOnElementVisibilityChanged(func)
    self.__onElementVisibilityChangedFunc = func
end

function ListMixin:SetTemplate(templateConstructorFunc)
    if type(templateConstructorFunc) == "table" then
        for k, v in pairs(templateConstructorFunc) do
            self.__templateConstructorFunc[k] = v
        end
    else
        self.__templateConstructorFunc[DEFAULT_TYPE_KEY] = templateConstructorFunc
    end
end

function ListMixin:SetData(data)
    self.__data = data
    self:RenderElements()
end

function ListMixin:GetData()
    return self.__data
end

function ListMixin:UpdateAllVisibleElements()
    if not self.__data then return end

    for index, value in ipairs(self.__data) do
        local typeKey = value.uk_poolElementType or DEFAULT_TYPE_KEY
        local element = self:GetElement(index, typeKey)
        self.__onElementUpdateFunc(element, index, value)
    end
end

function ListMixin:ClearElementFlags()
    for _, typeFramePool in pairs(self.__elementPool) do
        for _, element in pairs(typeFramePool) do
            element.__shouldShow = false
        end
    end
end

function ListMixin:ClearElementTypeIndex()
    wipe(self.__elementPoolTypeIndex)
end

function ListMixin:EnsureTypeKeyInPool(typeKey)
    if not self.__elementPool[typeKey] then
        self.__elementPool[typeKey] = {}
    end

    if not self.__elementPoolTypeIndex[typeKey] then
        self.__elementPoolTypeIndex[typeKey] = 0
    end
end

function ListMixin:NewElement(typeKey)
    assert(self.__templateConstructorFunc, "No template constructor set!")
    assert(self.uk_parent, "No parent set!")

    self:EnsureTypeKeyInPool(typeKey)

    local index = #self.__elementPool[typeKey] + 1
    local name = self:GetDebugName() .. ".Element" .. index
    local element = self.__templateConstructorFunc[typeKey](name)
    element:parent(self.uk_parent)
    tinsert(self.__elementPool[typeKey], element)

    return element
end

function ListMixin:GetElement(index, typeKey)
    self:EnsureTypeKeyInPool(typeKey)

    local element = nil
    if #self.__elementPool[typeKey] < index then
        element = self:NewElement(typeKey)
    else
        element = self.__elementPool[typeKey][index]
    end
    return element
end

function ListMixin:GetAllElementsInPoolByType(typeKey)
    if not typeKey then return end
    return self.__elementPool[typeKey]
end

function ListMixin:RenderElements()
    self:ClearElementFlags()
    self:ClearElementTypeIndex()
    if not self.__data then return end

    for index, value in ipairs(self.__data) do
        local typeKey = value.uk_poolElementType or DEFAULT_TYPE_KEY
        self:EnsureTypeKeyInPool(typeKey)

        self.__elementPoolTypeIndex[typeKey] = self.__elementPoolTypeIndex[typeKey] + 1

        local element = self:GetElement(self.__elementPoolTypeIndex[typeKey], typeKey)
        element.__shouldShow = true
        element.__uk_poolElementType = typeKey
        
        MoveFrameChildToEnd(self.uk_parent, element)

        if self.__onElementUpdateFunc then
            self.__onElementUpdateFunc(element, index, value)
        end
    end

    for _, typeFramePool in pairs(self.__elementPool) do
        for _, element in pairs(typeFramePool) do
            if element:IsShown() ~= element.__shouldShow then
                if self.__onElementVisibilityChangedFunc then
                    self.__onElementVisibilityChangedFunc(element, element.__shouldShow, element.__uk_poolElementType)
                else
                    element:SetShown(element.__shouldShow)
                end
            end
        end
    end
end

function UIKit_Primitives_List.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ListMixin)
    frame:Init()

    return frame
end
