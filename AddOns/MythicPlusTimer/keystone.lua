local _, addon = ...
local keystone = addon.new_module("keystone")

-- ---------------------------------------------------------------------------------------------------------------------
local function insert_keystone()
  if not addon.c("insert_keystone") then
    return
  end

  -- search for the key in the bags
  for bag = 0, NUM_BAG_SLOTS do
    local slots = GetContainerNumSlots(bag)
    for slot = 1, slots do
      -- check if item at slot is the key
      local item_id = GetContainerItemID(bag, slot)
      if item_id == 180653 or item_id == 158923 or item_id == 151086 then
        -- pickup item and insert it
        PickupContainerItem(bag, slot)
        if (CursorHasItem()) then
          C_ChallengeMode.SlotKeystone()
        end

        -- return if key was found
        return
      end
    end
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_addon_loaded(name)
  if name == "Blizzard_ChallengesUI" then
    ChallengesKeystoneFrame:HookScript("OnShow", insert_keystone)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Enable
function keystone:enable()
  if IsAddOnLoaded("Blizzard_ChallengesUI") then
    ChallengesKeystoneFrame:HookScript("OnShow", insert_keystone)
  else
    addon.register_event("ADDON_LOADED", on_addon_loaded)
  end
end
