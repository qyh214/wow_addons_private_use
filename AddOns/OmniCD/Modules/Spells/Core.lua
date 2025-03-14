local E = select(2, ...):unpack()

E.spell_highlighted = {}
E.spell_modifiers = {}
E.hash_spelldb = {}

E.spell_marked = E.isDF and {
	[48707] = 205727,
	[287250] = true,
	[198589] = 205411,
	[217832] = 205596,
	[198793] = 354489,
	[187650] = 203340,
	[116849] = 388218,
	[122470] = 280195,
	[853] = 234299,
	[228049] = true,
	[199448] = true,
	[8122] = 196704,
	[586] = 408557,
	[88625] = 200199,
	[1966] = 79008,
	[2094] = 200733,
	[79206] = 290254,
	[23920] = 213915,
	[360806] = 410962,
	[34433] = 314867,
	[123040] = 314867,
} or E.BLANK

function E:ProcessSpellDB()
	for k, v in pairs(self.spell_db) do
		local n = #v
		for i = n, 1, -1 do
			local t = v[i]
			local id, itemID, stype = t.spellID, t.item, t.type
			if C_Spell.DoesSpellExist(id) then
				t.class = t.class or k

				local name
				if k == "TRINKET" and itemID and itemID > 0 then
					name = C_Item.GetItemNameByID(itemID) or C_Spell.GetSpellName(id)
				else
					name = C_Spell.GetSpellName(id)
				end
				t.name = name or ""

				if k == "TRINKET" or k == "PVPTRINKET" then
					if itemID == 37864 and self.userFaction == "Horde" then
						itemID = 37865
					end
					t.icon = t.icon or C_Item.GetItemIconByID(itemID)
				else
					if id == 2825 and self.userFaction ~= "Horde" then
						t.icon = 132313
					end
					t.icon = t.icon or select(2, C_Spell.GetSpellTexture(id))
				end

				t.buff = t.buff or self.buffFix[id] or id
				if self.L_HIGHLIGHTS[stype] then
					self.spell_highlighted[t.buff] = true
				end

				if self.spell_requiredLevel then
					self.spell_requiredLevel[id] = t.rlvl
				end

				E.hash_spelldb[id] = t
			else
				tremove(v, i)
				--[==[@debug@
				E.write("Removing invalid spell_db ID:" , id)
				--@end-debug@]==]
			end
		end
	end


	for castID in pairs(self.spell_merged) do
		if not self.spell_highlighted[castID] then
			self.spell_highlighted[castID] = true
		end
	end

	for k in self.pairs(self.spell_linked, self.spell_merged, self.spellcast_shared_cdstart, self.spellcast_cdreset, self.spellcast_cdr, self.covenant_abilities, self.spellcast_cdr_azerite) do
		self.spell_modifiers[k] = true
	end
end

if E.preMoP then
	E.spell_cxmod_azerite = E.BLANK
	E.spellcast_cdr_azerite = E.BLANK
	E.spell_damage_cdr_azerite = E.BLANK
	E.spell_cdmod_essrank23 = E.BLANK
	E.spell_chargemod_essrank3 = E.BLANK
	E.essMajorConflict = E.BLANK
	E.pvpTalentsByEssMajorConflict = E.BLANK
	E.essMinorStrive = E.BLANK
	E.spell_cdmod_ess_strive_mult = E.BLANK
end
