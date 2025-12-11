local env                         = select(2, ...)
local MixinUtil                   = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                       = MixinUtil.Mixin

local UIKit_Primitives_Frame      = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_ModelScene = env.WPM:New("wpm_modules/ui-kit/primitives/model-scene")


-- Model Scene
--------------------------------

local ModelSceneMixin = {}
do

end


function UIKit_Primitives_ModelScene.New(name, parent)
    name = name or "undefined"


    local modelScene = UIKit_Primitives_Frame.New("ModelScene", name, parent)
    Mixin(modelScene, ModelSceneMixin)


    return modelScene
end
