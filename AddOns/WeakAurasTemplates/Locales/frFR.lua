if not(GetLocale() == "frFR") then
  return
end

local L = WeakAuras.L

-- WeakAuras/Templates
	L["Abilities"] = "Capacités"
	L["Ability Charges"] = "Charges de capacité"
	L["Add Triggers"] = "Ajouter Déclencheur"
	L["Always Active"] = "Toujours actif"
	L["Always Show"] = "Toujours Affiché"
	--[[Translation missing --]]
	L["Always show the aura, highlight it if debuffed."] = "Always show the aura, highlight it if debuffed."
	L["Always show the aura, turns grey if on cooldown."] = "Toujours afficher l'aura, deviens gris si en recharge."
	L["Always show the aura, turns grey if the debuff not active."] = "Toujours afficher l'aura, deviens gris si l'affaiblissement n'est pas actif."
	L["Always shows the aura, grey if buff not active."] = "Toujours afficher l'aura, deviens gris si l'amélioration n'est pas active."
	--[[Translation missing --]]
	L["Always shows the aura, highlight it if buffed."] = "Always shows the aura, highlight it if buffed."
	--[[Translation missing --]]
	L["Always shows the aura, highlight when active, turns blue on insufficient resources."] = "Always shows the aura, highlight when active, turns blue on insufficient resources."
	--[[Translation missing --]]
	L["Always shows the aura, highlight while proc is active, blue on insufficient resources."] = "Always shows the aura, highlight while proc is active, blue on insufficient resources."
	--[[Translation missing --]]
	L["Always shows the aura, highlight while proc is active, blue when not usable."] = "Always shows the aura, highlight while proc is active, blue when not usable."
	--[[Translation missing --]]
	L["Always shows the aura, highlight while proc is active, turns red when out of range, blue on insufficient resources."] = "Always shows the aura, highlight while proc is active, turns red when out of range, blue on insufficient resources."
	--[[Translation missing --]]
	L["Always shows the aura, turns blue on insufficient resources."] = "Always shows the aura, turns blue on insufficient resources."
	--[[Translation missing --]]
	L["Always shows the aura, turns blue when not usable."] = "Always shows the aura, turns blue when not usable."
	--[[Translation missing --]]
	L["Always shows the aura, turns grey if on cooldown."] = "Always shows the aura, turns grey if on cooldown."
	--[[Translation missing --]]
	L["Always shows the aura, turns grey if the ability is not usable and red when out of range."] = "Always shows the aura, turns grey if the ability is not usable and red when out of range."
	--[[Translation missing --]]
	L["Always shows the aura, turns grey if the ability is not usable."] = "Always shows the aura, turns grey if the ability is not usable."
	--[[Translation missing --]]
	L["Always shows the aura, turns red when out of range, blue on insufficient resources."] = "Always shows the aura, turns red when out of range, blue on insufficient resources."
	--[[Translation missing --]]
	L["Always shows the aura, turns red when out of range."] = "Always shows the aura, turns red when out of range."
	L["Back"] = "Retour"
	L["Basic Show On Cooldown"] = "Affiché En Recharge De Base"
	L["Bloodlust/Heroism"] = "Furie sanguinaire/Héroïsme"
	L["buff"] = "amélioration"
	L["Buff"] = "Amélioration"
	L["Buffs"] = "Améliorations"
	L["Cancel"] = "Annuler"
	L["Cast"] = "Incantation"
	L["Charge and Buff Tracking"] = "Suivis des Charges et Amélioration"
	L["Charge and Debuff Tracking"] = "Suivis des Charges et Affaiblissement"
	--[[Translation missing --]]
	L["Charge and Duration Tracking"] = "Charge and Duration Tracking"
	L["Charge Tracking"] = "Suivis des Charges"
	L["cooldown"] = "recharge"
	L["Cooldown Tracking"] = "Suivis du Temps de Recharge"
	L["Create Auras"] = "Créer Auras"
	L["Debuffs"] = "Affaiblissements"
	L["Enchants"] = "Enchantements"
	L["General"] = "Général"
	L["General Azerite Traits"] = "Traits Azéritiques Généraux"
	L["Health"] = "Santé"
	--[[Translation missing --]]
	L["Highlight while active, red when out of range."] = "Highlight while active, red when out of range."
	--[[Translation missing --]]
	L["Highlight while active."] = "Highlight while active."
	--[[Translation missing --]]
	L["Highlight while buffed, red when out of range."] = "Highlight while buffed, red when out of range."
	--[[Translation missing --]]
	L["Highlight while buffed."] = "Highlight while buffed."
	--[[Translation missing --]]
	L["Highlight while debuffed, red when out of range."] = "Highlight while debuffed, red when out of range."
	--[[Translation missing --]]
	L["Highlight while debuffed."] = "Highlight while debuffed."
	--[[Translation missing --]]
	L["Highlight while spell is active."] = "Highlight while spell is active."
	L["Hold CTRL to create multiple auras at once"] = "Laisser appuyer sur CTRL pour créer plusieurs auras simultanément"
	L["Keeps existing triggers intact"] = "Garder intact les déclencheurs existants"
	L["Next"] = "Suivant"
	--[[Translation missing --]]
	L["On Procc Trinkets (Aura)"] = "On Procc Trinkets (Aura)"
	--[[Translation missing --]]
	L["On Use Trinkets (Aura)"] = "On Use Trinkets (Aura)"
	L["On Use Trinkets (CD)"] = "Bijoux Avec Utilisation (Recharge)"
	L["Only show the aura if the target has the debuff."] = "Montre l'aura que si la cible a l'affaiblissement."
	L["Only show the aura when the item is on cooldown."] = "Montre l'aura que lorsque l'objet est en recharge."
	L["Only shows the aura if the target has the buff."] = "Montre l'aura que si la cible a l'amélioration."
	L["Only shows the aura when the ability is on cooldown."] = "Montre l'aura que si la capacité est en recharge."
	L["Pet alive"] = "Familier vivant"
	L["Pet Behavior"] = "Comportement du Familier"
	L["PvP Azerite Traits"] = "Traits Azéritiques JcJ"
	L["PvP Talents"] = "Talents JcJ"
	--[[Translation missing --]]
	L["PVP Trinkets (Aura)"] = "PVP Trinkets (Aura)"
	L["PVP Trinkets (CD)"] = "Bijou JcJ (Recharge)"
	L["Replace all existing triggers"] = "Remplacer tous les déclencheurs existant"
	L["Replace Triggers"] = "Remplacer les déclencheurs"
	L["Resources"] = "Ressources"
	L["Resources and Shapeshift Form"] = "Ressources et Forme de Changeforme"
	L["Runes"] = "Runes"
	L["Shapeshift Form"] = "Forme de Changeforme"
	L["Show Charges and Check Usable"] = "Afficher les Charges et Vérifier si Utilisable"
	--[[Translation missing --]]
	L["Show Charges with Proc Tracking"] = "Show Charges with Proc Tracking"
	L["Show Charges with Range Tracking"] = "Afficher les Charges avec Vérification de la Portée"
	L["Show Charges with Usable Check"] = "Afficher les Charges avec Vérification si Utilisable"
	L["Show Cooldown and Buff"] = "Afficher les Temps de Recharges et Améliorations"
	L["Show Cooldown and Buff and Check for Target"] = "Afficher le Temps de Recharge et l'Amélioration et Vérifier si il y a une Cible"
	L["Show Cooldown and Buff and Check Usable"] = "Afficher le Temps de Recharge et l'Amélioration et Vérifier si c'est Utilisable"
	L["Show Cooldown and Check for Target"] = "Afficher le Temps de Recharge et Vérifier si il y a une Cible"
	--[[Translation missing --]]
	L["Show Cooldown and Check for Target & Proc Tracking"] = "Show Cooldown and Check for Target & Proc Tracking"
	L["Show Cooldown and Check Usable"] = "Afficher le Temps de Recharge et Vérifier si c'est Utilisable"
	L["Show Cooldown and Check Usable & Target"] = "Afficher le Temps de Recharge et Vérifier si c'est Utilisable et si il y a une Cible"
	--[[Translation missing --]]
	L["Show Cooldown and Check Usable, Proc Tracking"] = "Show Cooldown and Check Usable, Proc Tracking"
	--[[Translation missing --]]
	L["Show Cooldown and Check Usable, Target & Proc Tracking"] = "Show Cooldown and Check Usable, Target & Proc Tracking"
	L["Show Cooldown and Debuff"] = "Afficher le Temps de Recharge et L'Affaiblissement"
	L["Show Cooldown and Debuff and Check for Target"] = "Afficher les Temps de Recharge et l'Affaiblissement et Vérifier si il y a une Cible"
	--[[Translation missing --]]
	L["Show Cooldown and Duration"] = "Show Cooldown and Duration"
	--[[Translation missing --]]
	L["Show Cooldown and Duration and Check for Target"] = "Show Cooldown and Duration and Check for Target"
	--[[Translation missing --]]
	L["Show Cooldown and Duration and Check Usable"] = "Show Cooldown and Duration and Check Usable"
	--[[Translation missing --]]
	L["Show Cooldown and Proc Tracking"] = "Show Cooldown and Proc Tracking"
	L["Show Cooldown and Totem Information"] = "Afficher le Temps de Rechargement et l'Information du Totem"
	--[[Translation missing --]]
	L["Show Only if Buffed"] = "Show Only if Buffed"
	--[[Translation missing --]]
	L["Show Only if Debuffed"] = "Show Only if Debuffed"
	L["Show Only if on Cooldown"] = "Afficher Seulement si en Recharge"
	L["Show Totem and Charge Information"] = "Afficher les Informations du Totem et de Charge"
	L["Specific Azerite Traits"] = "Traits Azéritiques Spécéfiques"
	L["Stagger"] = "Report"
	--[[Translation missing --]]
	L["Track the charge and proc, highlight while proc is active, turns red when out of range, blue on insufficient resources."] = "Track the charge and proc, highlight while proc is active, turns red when out of range, blue on insufficient resources."
	--[[Translation missing --]]
	L["Tracks the charge and the buff, highlight while the buff is active, blue on insufficient resources."] = "Tracks the charge and the buff, highlight while the buff is active, blue on insufficient resources."
	--[[Translation missing --]]
	L["Tracks the charge and the debuff, highlight while the debuff is active, blue on insufficient resources."] = "Tracks the charge and the debuff, highlight while the debuff is active, blue on insufficient resources."
	--[[Translation missing --]]
	L["Tracks the charge and the duration of spell, highlight while the spell is active, blue on insufficient resources."] = "Tracks the charge and the duration of spell, highlight while the spell is active, blue on insufficient resources."
	L["Unknown Item"] = "Objet inconnu"
	L["Unknown Spell"] = "Sort inconnu"

