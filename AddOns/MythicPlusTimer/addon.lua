-- 1.0
local addon_name, addon = ...

-- ---------------------------------------------------------------------------------------------------------------------
-- Translations
local translations = {}
local current_locale = GetLocale()
local fallback_locale = "enUS"

-- ---------------------------------------------------------------------------------------------------------------------
function addon.add_locale(locale, resources)
  translations[locale] = resources
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.t(key)
  if translations[current_locale] and translations[current_locale][key] ~= nil then
    return translations[current_locale][key]
  end

  if not translations[fallback_locale] or translations[fallback_locale][key] == nil then
    return key
  end

  return translations[fallback_locale][key]
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Config
local config = {}
local config_listeners = {}

function addon.set_config(config_values)
  if type(config_values) ~= "table" then
    return
  end

  config = config_values
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.set_config_value(key, value)
  config[key] = value

  if config_listeners[key] then
    for callback, _ in pairs(config_listeners[key]) do
      callback(key, value)
    end
  end

  if config_listeners["*"] then
    for callback, _ in pairs(config_listeners["*"]) do
      callback(key, value)
    end
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.c(key)
  return config[key]
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.register_config_listener(key, callback)
  if not config_listeners[key] then
    config_listeners[key] = {[callback] = true}
  else
    config_listeners[key][callback] = true
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.unregister_config_listener(key, callback)
  if not config_listeners[key] then
    return
  end

  config_listeners[key][callback] = nil

  local count = 0
  for _ in pairs(config_listeners[key]) do
    count = count + 1
  end

  if count == 0 then
    config_listeners[key] = nil
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Events
local event_listeners = {}

local function on_event(_, event, ...)
  if not event_listeners[event] then
    return
  end

  for callback, _ in pairs(event_listeners[event]) do
    callback(...)
  end
end

local listener_frame = CreateFrame("Frame", addon_name .. "Listener")
listener_frame:SetScript("OnEvent", on_event)

-- ---------------------------------------------------------------------------------------------------------------------
function addon.register_event(event, callback)
  if not event_listeners[event] then
    listener_frame:RegisterEvent(event)
    event_listeners[event] = {[callback] = true}
  else
    event_listeners[event][callback] = true
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.unregister_event(event, callback)
  if not event_listeners[event] then
    return
  end

  event_listeners[event][callback] = nil

  local count = 0
  for _ in pairs(event_listeners[event]) do
    count = count + 1
  end

  if count == 0 then
    event_listeners[event] = nil
    listener_frame:UnregisterEvent(event)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Chat
function addon.print(text)
  DEFAULT_CHAT_FRAME:AddMessage("|cff1C80E7" .. addon_name .. "|r: " .. text)
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Modules
local AddonModule = {}

function AddonModule:init()
end

function AddonModule:enable()
end

function AddonModule:register_event(event, callback)
  addon.register_event(event, callback)
end

function AddonModule:unregister_event(event, callback)
  addon.unregister_event(event, callback)
end

-- ---------------------------------------------------------------------------------------------------------------------
local modules = {}

function addon.new_module(name)
  local module = {name = name}

  setmetatable(module, {__index = AddonModule})

  table.insert(modules, module)

  return module
end

-- ---------------------------------------------------------------------------------------------------------------------
function addon.get_module(name)
  for _, module in pairs(modules) do
    if module.name == name then
      return module
    end
  end

  return nil
end

-- ---------------------------------------------------------------------------------------------------------------------
local function call_on_modules(name)
  for _, module in ipairs(modules) do
    if module[name] then
      module[name](module)
    end
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_player_login()
  call_on_modules("init")
  call_on_modules("enable")

  addon.unregister_event("PLAYER_LOGIN", on_player_login)
end

addon.register_event("PLAYER_LOGIN", on_player_login)
