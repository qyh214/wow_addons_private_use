local env                            = select(2, ...)
local UIKit_Primitives_Utils_Texture = env.WPM:Import("wpm_modules/ui-kit/primitives/utils/texture")
local UIKit_Define                   = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Utils                    = env.WPM:Import("wpm_modules/ui-kit/utils")
local UIKit_Renderer_Background      = env.WPM:New("wpm_modules/ui-kit/renderer/background")


-- Mask
--------------------------------

function UIKit_Renderer_Background.SetMaskTexture(frame, mask)
    if not frame.Background then return end
    if not mask then return end

    if mask.GetBackground and mask:GetBackground().__isMaskTexture == true then
        frame.Background:SetMaskFromObject(mask)
    elseif mask == UIKit_Define.Texture then
        frame.Background:SetMaskFromTexture(mask.path)
    end
end


-- Background
--------------------------------

function UIKit_Renderer_Background.SetBackground(frame, isMaskTexture)
    local backgroundInfo = frame.uk_prop_background
    if not backgroundInfo then
        -- No provided texture, hide background if it exists
        if not frame.Background or not frame.Background:IsShown() then return end
        frame.Background:Hide()
        return
    end

    -- Create a new background if it doesn't exist
    if not frame.Background then
        frame.Background = UIKit_Primitives_Utils_Texture.New(frame, isMaskTexture)
    elseif not frame.Background:IsShown() then
        frame.Background:Show()
    end

    -- Set background object texture
    if backgroundInfo == UIKit_Define.Texture then
        frame.Background:SetTexture(backgroundInfo.path)
    elseif backgroundInfo == UIKit_Define.Texture_NineSlice then
        frame.Background:SetNineSlice(backgroundInfo.path, backgroundInfo.inset, backgroundInfo.scale, backgroundInfo.sliceMode)
    elseif backgroundInfo == UIKit_Define.Texture_Backdrop then
        frame.Background:SetBackdrop(backgroundInfo)
    elseif backgroundInfo == UIKit_Define.Texture_Atlas then
        frame.Background:SetAtlas(backgroundInfo)
    end
end

function UIKit_Renderer_Background.SetBackgroundColor(frame)
    local color = frame.uk_prop_backgroundColor
    if not color or not frame.Background then return end

    frame.Background:SetColor(UIKit_Utils:ProcessColor(color))
end

function UIKit_Renderer_Background.SetBackdropColor(frame)
    local backgroundColor = frame.uk_prop_backdropColor_background
    local borderColor = frame.uk_prop_backdropColor_border or frame.uk_prop_backdropColor_background
    if not backgroundColor or not borderColor or not frame.Background.backdrop then return end

    frame.Background:SetBackdropColor(UIKit_Utils:ProcessColor(backgroundColor), UIKit_Utils:ProcessColor(borderColor))
end

function UIKit_Renderer_Background.SetRotation(frame)
    local rotation = frame.uk_prop_backgroundRotation
    if not rotation or not frame.Background then return end

    frame.Background:SetRotation(rotation)
end

function UIKit_Renderer_Background.SetBlendMode(frame)
    local backgroundBlendMode = frame.uk_prop_blendMode
    if not backgroundBlendMode or not frame.Background then return end

    frame.Background:SetBlendMode(backgroundBlendMode)
end

function UIKit_Renderer_Background.SetDesaturated(frame)
    local backgroundDesaturated = frame.uk_prop_desaturated
    if not backgroundDesaturated or not frame.Background then return end

    frame.Background:SetDesaturated(backgroundDesaturated)
end
