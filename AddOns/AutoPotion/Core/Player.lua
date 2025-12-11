local addonName, ham = ...

ham.Player = {}

ham.Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");

  function self.getHealingItems()
    local healingItems = {}
    return healingItems
  end

  function self.getHealingSpells()
    local mySpells = {}
    for i, id in ipairs(HAMDB.activatedSpells) do
      local currentSpell = ham.Spell.new(id)
      if currentSpell.isKnown() then
        table.insert(mySpells, currentSpell)
      end
    end
    return mySpells
  end

  return self
end
