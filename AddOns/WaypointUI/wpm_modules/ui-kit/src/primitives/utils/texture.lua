local env                            = select(2, ...)
local MixinUtil                      = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                          = MixinUtil.Mixin
local type                           = type

local UIkit_Primitives_Frame         = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_Utils_Texture = env.WPM:New("wpm_modules/ui-kit/primitives/utils/texture")


-- Shared
--------------------------------

local TEXTURE_PORT_METHODS = {
    "SetDesaturated"
}


-- Texture
--------------------------------

local TextureMixin = {}
do
    -- Accessor
    --------------------------------

    function TextureMixin:GetTextureObject()
        return self.__Texture
    end

    function TextureMixin:GetBackdropObject()
        if not self.__Backdrop then return end
        return self.__Backdrop
    end

    -- Port
    --------------------------------

    for i = 1, #TEXTURE_PORT_METHODS do
        local method = TEXTURE_PORT_METHODS[i]
        TextureMixin[method] = function(self, ...)
            return self.__Texture[method](self.__Texture, ...)
        end
    end


    -- Set
    --------------------------------

    function TextureMixin:SetMaskFromTexture(texture)
        self.__Texture:SetMask(texture)
    end

    function TextureMixin:SetMaskFromObject(maskTextureObject)
        self.__Texture:AddMaskTexture(maskTextureObject:GetBackground():GetTextureObject())
    end

    function TextureMixin:SetTexture(texture)
        -- Set "Texture"
        self.__Texture:SetTexture(texture)

        -- Hide "Backdrop"
        if self.__Backdrop then self.__Backdrop:Hide() end
    end

    function TextureMixin:SetNineSlice(texture, inset, scale, sliceMode)
        -- Set "Texture"
        local insetLeft, insetRight, insetTop, insetBottom

        texture = texture or self.__Texture:GetTexture()
        if type(inset) ~= "table" then
            insetLeft = inset or 50
            insetRight = inset or 50
            insetTop = inset or 50
            insetBottom = inset or 50
        else
            insetLeft, insetRight, insetTop, insetBottom = unpack(inset)
        end
        scale = scale or 1
        sliceMode = sliceMode or Enum.UITextureSliceMode.Stretched

        self.__Texture:SetTexture(texture)
        self.__Texture:SetTextureSliceMargins(insetLeft, insetTop, insetRight, insetBottom)
        self.__Texture:SetTextureSliceMode(sliceMode)
        self.__Texture:SetScale(scale)

        -- Hide "Backdrop"
        if self.__Backdrop then self.__Backdrop:Hide() end
    end

    function TextureMixin:SetBackdrop(info)
        -- Prevent "Backdrop" from being set on mask texture obj type
        if self.__isMaskTexture then return end

        -- Hide "Texture"
        self.__Texture:SetTexture(nil)

        -- Set "Backdrop"
        -- Creates a Backdrop instance if it doesn't exist
        if not self.__Backdrop then
            self.__Backdrop = UIkit_Primitives_Frame("Frame", "$parent.Backdrop", self:GetParent(), "BackdropTemplate")
            self.__Backdrop:SetAllPoints(self)
        end
        self.__Backdrop:Show()
        self.__Backdrop:SetBackdrop(info)
    end

    function TextureMixin:SetAtlas(info)
        -- Set "Texture"
        if type(info) == "string" then -- If provided `info` is a string, assume it's using Blizzard's atlas paths
            self.__Texture:SetAtlas(info)
            self.__Texture:SetTextureSliceMargins(0, 1, 0, 1)
            self.__Texture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
            self.__Texture:SetTexCoord(0, 1, 0, 1)
        else -- Provided `info` is a table, use custom texture slicing behavior
            self:SetNineSlice(info.path, info.inset, info.scale)
            self.__Texture:SetTexCoord(info.left, info.right, info.top, info.bottom)
        end

        -- Hide "Backdrop"
        if self.__Backdrop then self.__Backdrop:Hide() end
    end

    function TextureMixin:SetBlendMode(backgroundBlendMode)
        self.__Texture:SetBlendMode(backgroundBlendMode)
        if self.__Backdrop then self.__Backdrop:SetBlendMode(backgroundBlendMode) end
    end

    -- Color
    --------------------------------

    function TextureMixin:SetColor(r, g, b, a)
        local colorR, colorG, colorB, colorA

        -- Only argument equals color table
        if r and not g and not b then
            colorR = r.r or 1
            colorG = r.g or 1
            colorB = r.b or 1
            colorA = r.a or 1
        else
            colorR = r or 1
            colorG = g or 1
            colorB = b or 1
            colorA = a or 1
        end

        if not self.__Backdrop then
            if self.__Texture.SetVertexColor then
                self.__Texture:SetVertexColor(colorR, colorG, colorB, colorA)
            elseif self.__Texture.SetColorTexture then
                self.__Texture:SetColorTexture(colorR, colorG, colorB, colorA)
            end
        end
    end

    function TextureMixin:SetBackdropColor(background, border)
        if self.__Backdrop then
            self.__Backdrop:SetBackdropColor(background.r, background.g, background.b, background.a or 1)
            self.__Backdrop:SetBackdropBorderColor(border.r, border.g, border.b, border.a or 1)
        end
    end

    -- Property
    --------------------------------

    function TextureMixin:SetRotation(rotation)
        if self.__Backdrop then
            self.__Backdrop:SetRotation(rotation)
        end
        self.__Texture:SetRotation(rotation)
    end

    function TextureMixin:GetRotation()
        if self.__Backdrop then
            return self.__Backdrop:GetRotation()
        end
        return self.__Texture:GetRotation()
    end
end


function UIKit_Primitives_Utils_Texture.New(parent, isMaskTexture)
    local frame = UIkit_Primitives_Frame.New("Frame", "$parent.Texture", parent)
    Mixin(frame, TextureMixin)
    frame:SetAllPoints(parent)
    frame:SetFrameStrata(parent:GetFrameStrata())
    frame:SetFrameLevel(parent:GetFrameLevel())

    local texture = nil

    if isMaskTexture then
        texture = frame:CreateMaskTexture("$parent.MaskTextureObject")
    else
        texture = frame:CreateTexture("$parent.TextureObject")
    end


    texture:SetAllPoints(frame)
    texture:SetTexelSnappingBias(0)

    frame.__Texture = texture
    frame.__isMaskTexture = isMaskTexture

    -- Remove from global table
    _G[texture:GetName()] = nil
    _G[frame:GetName()] = nil
    return frame
end
