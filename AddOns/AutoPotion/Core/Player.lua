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
    local spells = {}

    for i, spell in ipairs(HAMDB.activatedSpells) do
      if IsSpellKnown(spell) or IsSpellKnown(spell, true) then
        table.insert(spells, spell)
      end
    end

    return spells
  end

  return self
end
