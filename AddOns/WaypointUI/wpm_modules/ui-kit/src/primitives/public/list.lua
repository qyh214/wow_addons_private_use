local env                    = select(2, ...)
local MixinUtil              = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                  = MixinUtil.Mixin
local tinsert                = table.insert
local ipairs                 = ipairs
local type                   = type

local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_List  = env.WPM:New("wpm_modules/ui-kit/primitives/list")


-- List
--------------------------------

local ListMixin = {}
do
    local DEFAULT_VARIANT_KEY = "Default"


    -- Init
    --------------------------------

    function ListMixin:Init()
        self.__elementPool = {}
        self.__elementPoolVariantIndex = {}
        self.__data = nil
        self.__prefabConstructorFunc = {}
        self.__onElementUpdateFunc = nil
    end


    -- API
    --------------------------------

    function ListMixin:UpdateAllVisibleElements()
        if not self.__data then return end

        for index, value in ipairs(self.__data) do
            local variantKey = value.uk_poolElementVariant or DEFAULT_VARIANT_KEY
            local element = self:GetElement(index, variantKey)
            self.__onElementUpdateFunc(element, index, value)
        end
    end

    function ListMixin:SetPrefab(prefabConstructorFunc)
        if type(prefabConstructorFunc) == "table" then
            for k, v in pairs(prefabConstructorFunc) do
                self.__prefabConstructorFunc[k] = v
            end
        else
            self.__prefabConstructorFunc[DEFAULT_VARIANT_KEY] = prefabConstructorFunc
        end
    end

    function ListMixin:SetOnElementUpdate(func)
        self.__onElementUpdateFunc = func
    end

    function ListMixin:SetData(data)
        self.__data = data
        self:RenderElements()
    end

    function ListMixin:GetData()
        return self.__data
    end


    -- Internal
    --------------------------------

    function ListMixin:HideElements()
        for _, variantFramePool in pairs(self.__elementPool) do
            for variantKey, element in pairs(variantFramePool) do
                element:Hide()
            end
        end
    end

    function ListMixin:WipeElementVariantIndex()
        wipe(self.__elementPoolVariantIndex)
    end

    function ListMixin:EnsureVariantKeyInPool(variantKey)
        if not self.__elementPool[variantKey] then
            self.__elementPool[variantKey] = {}
        end

        if not self.__elementPoolVariantIndex[variantKey] then
            self.__elementPoolVariantIndex[variantKey] = 0
        end
    end

    function ListMixin:NewElement(variantKey)
        assert(self.__prefabConstructorFunc, "No prefab constructor set!")
        assert(self.uk_parent, "No parent set!")

        self:EnsureVariantKeyInPool(variantKey)

        local index = #self.__elementPool[variantKey] + 1
        local name = self:GetDebugName() .. ".Element" .. index
        local element = self.__prefabConstructorFunc[variantKey](name)
        element:parent(self.uk_parent)
        tinsert(self.__elementPool[variantKey], element)

        return element
    end

    function ListMixin:GetElement(index, variantKey)
        self:EnsureVariantKeyInPool(variantKey)

        local element = nil
        if #self.__elementPool[variantKey] < index then
            element = self:NewElement(variantKey)
        else
            element = self.__elementPool[variantKey][index]
        end
        return element
    end

    function ListMixin:RenderElements()
        self:HideElements()
        self:WipeElementVariantIndex()
        if not self.__data then return end

        for index, value in ipairs(self.__data) do
            local variantKey = value.uk_poolElementVariant or DEFAULT_VARIANT_KEY
            self:EnsureVariantKeyInPool(variantKey)

            self.__elementPoolVariantIndex[variantKey] = self.__elementPoolVariantIndex[variantKey] + 1

            local element = self:GetElement(self.__elementPoolVariantIndex[variantKey], variantKey)
            element:Show()

            if self.__onElementUpdateFunc then
                self.__onElementUpdateFunc(element, index, value)
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


--[[
    local BACKGROUND = UIKit.Define.Texture_NineSlice{ path = Path.Root .. "/wpm_modules/uic-common/resources/InputCaret.png", inset = 128, scale = 1 }

    local Element = UIKit.Prefab(function(id, name, children, ...)
        return
            Frame(name, {

            })
            :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Num{ value = 25 })
            :background(BACKGROUND)
            :backgroundColor(UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .5 })
            :_Render()
    end)

    local function handleOnElementUpdate(element, index, value)
        element:alpha(index * .1)
    end

    Frame{
        LayoutVertical{
            List()
                :id("List")
                :poolPrefab(Element)
                :poolOnElementUpdate(handleOnElementUpdate)
        }
            :point(UIKit.Enum.Point.Center)
            :size(UIKit.Define.Percentage{value = 100}, UIKit.Define.Fit{})
            :background(BACKGROUND)
            :backgroundColor(UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .5 })
            :layoutDirection(UIKit.Enum.Direction.Vertical)
            :layoutSpacing(UIKit.Define.Num{value = 7.5})
    }
        :id("Frame")
        :point(UIKit.Enum.Point.Center)
        :size(UIKit.Define.Num{ value = 325 }, UIKit.Define.Num{ value = 575 })
        :background(BACKGROUND)
        :backgroundColor(UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .5 })
        :_Render()

    local data = {
        "entry1",
        "entry2",
        "entry3",
        "entry4",
        "entry5",
        "entry6",
        "entry7",
        "entry8",
        "entry9",
        "entry10",
    }

    local poolingElementVariantExample = {
        {
            -- Default variant is `Default`
            name = "entry1"
        },
        {
            uk_poolElementVariant = "Variant1",
            name = "entry2"
        },
        {
            uk_poolElementVariant = "Variant2",
            name = "entry3"
        },
    }

    myFrame = UIKit.GetElementById("Frame")
    myList = UIKit.GetElementById("List")
    myList:SetData(data)
]]
