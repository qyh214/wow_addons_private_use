local env   = select(2, ...)
local Sound = env.modules:New("packages\\sound")

local layers = {}

local function InitLayer(layer)
    layers[layer] = true
end

local function IsLayerEnabled(layer)
    if layers[layer] == nil then InitLayer(layer) end
    return layers[layer]
end

function Sound.PlaySoundFile(layer, filePath, force)
    assert(filePath, "Invalid variable `filePath`")
    if not force and IsLayerEnabled(layer) == false then return end
    PlaySoundFile(filePath, "SFX")
end

function Sound.PlaySound(layer, soundID, force)
    assert(soundID, "Invalid variable `soundID`")
    if not tonumber(soundID) then return end
    if not force and IsLayerEnabled(layer) == false then return end
    PlaySound(soundID, "SFX")
end

function Sound.Enable(layer)
    layers[layer] = true
end

function Sound.Disable(layer)
    layers[layer] = false
end

function Sound.SetEnabled(layer, enabled)
    if enabled == true then
        Sound.Enable(layer)
    elseif enabled == false then
        Sound.Disable(layer)
    end
end

function Sound.GetEnabled(layer)
    if not layers[layer] then return nil end
    return layers[layer]
end
