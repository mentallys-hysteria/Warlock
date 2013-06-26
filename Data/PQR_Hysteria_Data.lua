------------------------------------------------------------
-- Functions & Variables
------------------------
Version = 2.0
Minor = 1

if not PQR_LoadedDataFile then
	PQR_LoadedDateFile = 1
	PQR_WriteToChat("|cffBE69FFHysteria Data File - v"..Version.."."..Minor.." - 5/11/2013|cffffffff")
end

-- Aura Info function.
buffs = {
	stat 		=	{ 90363, 20217,	115921, 1126 },
	stamina		= 	{ 469, 90364, 109773, 21562},
	atkpwr		= 	{ 19506, 57330,	6673 },
	atkspeed	=	{ 55610, 113742, 30809, 128432, 128433 },
	spllpwr		=	{ 77747, 109773, 126309, 61316, 1459 },
	spllhaste	= 	{ 24907, 15473, 51470, 49868 },
	crit		=	{ 17007, 1459, 61316, 116781, 97229, 24604, 90309, 126373, 126309 },
	mastery		=	{ 116956, 19740, 93435, 128997 },
}

-- Trinket Proc list
buffList = {104423,128985,33702,126577,126659,126478,136082,126605,126476,136089,138898,139133,138786,138703,137590}

-- Doom no-dot List
disableDoomList = {69556,69553,69548,69492,69491,69480,69153,60885,68192,69050,70579,69069,69172,69184,69168,69013,69133,69462,63873,69232}

-- Calculate accumulated power of procs
mentallyPower = nil
function mentallyPower(spellID)
	-- Fetch our current stats.
	local mastery, haste, crit, spd, sorbs = GetMastery(), UnitSpellHaste("player"), GetSpellCritChance(6), GetSpellBonusDamage(6), UnitPower("player",13)
	
	-- Calculate potential damage buffs.
	dmg_buff = 1
	local fluidity, tricks, fearless, nutriment, shadowform, pi, tof = UnitBuffID("player",138002), UnitBuffID("player",57934), UnitBuffID("player",118977), select(4,UnitBuffID("player",138002)), UnitBuffID("player",15473), UnitBuffID("player",10060), UnitBuffID("player",123254)
	if fluidity		then dmg_buff = dmg_buff * 1.4		end
	if fearless		then dmg_buff = dmg_buff * 1.6		end
	if tricks		then dmg_buff = dmg_buff * 1.15		end
	if nutriment	then dmg_buff = 2+(nutriment-1)*0.1	end
	if shadowform	then dmg_buff = dmg_buff * 1.25		end
	if pi			then dmg_buff = dmg_buff * 1.05		end
	if tof			then dmg_buff = dmg_buff * 1.15		end
	
	-- Skull Banner
	if crit >= 100	then
		if skullbanner then dmg_buff = dmg_buff * 1.20	end
	end
	
	-- If Unerring proceed, take it into account.
	if crit > 100 then crit = 100 end
	
	-- Class/spec detection
	if select(2,UnitClass("player")) == "PRIEST" then
		if GetSpecialization() == 3 then
			damage_bonus 		= (1+crit/100)*(1+(mastery*1.8)/100)
			tick_every 			= 3/(1+(haste/100))
			
			-- Shadow Word: Pain
			if spellID == 589 then
				ticks		= PQ_PowerRound(18/tick_every)
				duration	= ticks * tick_every
				damage		= ticks * (623+spd*0.293) * damage_bonus
				dps			= PQ_PowerRound(damage/duration)
				dot_power	= PQ_PowerRound(dps/100)/10
				return dot_power
			end
			
			-- Vampiric Touch
			if spellID == 34914 then
				ticks		= PQ_PowerRound(15/tick_every)
				duration	= ticks * tick_every
				damage		= ticks*(62+spd*0.346)*damage_bonus
				dps			= PQ_PowerRound(damage/duration)
				dot_power	= PQ_PowerRound(dps/100)/10
				return dot_power
			end		
			
			-- Devouring Plague
			if spellID == 2944 then
				tick_every	= 1/(1+(haste/100))
				ticks		= PQ_PowerRound(5/tick_every)
				duration	= ticks * tick_every
				damage		= ticks*(9+spd*0.131)*sorbs*damage_bonus
				dps			= PQ_PowerRound(damage/duration)
				dot_power	= PQ_PowerRound(dps/100)/10
				return dot_power
			end
			
			-- Fail-safe
			return 0
		else return 0 end
	elseif select(2,UnitClass("player")) == "WARLOCK" then
		if GetSpecialization() == 2 then
			-- Doom
			if spellID == 603 then
				bonus		= (1+crit/100)*(1+(mastery*3)/100)
				tick_every	= 15/(1+(haste/100))
				ticks		= PQ_PowerRound(60/tick_every)
				duration	= ticks * tick_every
				damage		= (5340/ticks+spd*1.25)*bonus*ticks*dmg_buff
				dps			= PQ_PowerRound(damage/duration)
				dot_power	= PQ_PowerRound(dps/100)/10
				return dot_power
			end
			
			-- Fail-safe
			return 0
		else return 0 end
	else return 0 end
end

-- Unerring Vision of Lei-Shen
visionTrinket = {
	95814,	-- LFR
	94524,	-- Normal
	96186,	-- Thunderforged
	96558,	-- Heroic
	96930	-- Heroic Thunderforged
}

-- Complete boss unit table (Dungeons/Heroics/Raids)
PQ_BossUnits = {
	-- Cataclysm Dungeons --
	-- Abyssal Maw: Throne of the Tides
	40586,		-- Lady Naz'jar
	40765,		-- Commander Ulthok
	40825,		-- Erunak Stonespeaker
	40788,		-- Mindbender Ghur'sha
	42172,		-- Ozumat
	-- Blackrock Caverns
	39665,		-- Rom'ogg Bonecrusher
	39679,		-- Corla, Herald of Twilight
	39698,		-- Karsh Steelbender
	39700,		-- Beauty
	39705,		-- Ascendant Lord Obsidius
	-- The Stonecore
	43438,		-- Corborus
	43214,		-- Slabhide
	42188,		-- Ozruk
	42333,		-- High Priestess Azil
	-- The Vortex Pinnacle
	43878,		-- Grand Vizier Ertan
	43873,		-- Altairus
	43875,		-- Asaad
	-- Grim Batol
	39625,		-- General Umbriss
	40177,		-- Forgemaster Throngus
	40319,		-- Drahga Shadowburner
	40484,		-- Erudax
	-- Halls of Origination
	39425,		-- Temple Guardian Anhuur
	39428,		-- Earthrager Ptah
	39788,		-- Anraphet
	39587,		-- Isiset
	39731,		-- Ammunae
	39732,		-- Setesh
	39378,		-- Rajh
	-- Lost City of the Tol'vir
	44577,		-- General Husam
	43612,		-- High Prophet Barim
	43614,		-- Lockmaw
	49045,		-- Augh
	44819,		-- Siamat
	-- Zul'Aman
	23574,		-- Akil'zon
	23576,		-- Nalorakk
	23578,		-- Jan'alai
	23577,		-- Halazzi
	24239,		-- Hex Lord Malacrass
	23863,		-- Daakara
	-- Zul'Gurub
	52155,		-- High Priest Venoxis
	52151,		-- Bloodlord Mandokir
	52271,		-- Edge of Madness
	52059,		-- High Priestess Kilnara
	52053,		-- Zanzil
	52148,		-- Jin'do the Godbreaker
	-- End Time
	54431,		-- Echo of Baine
	54445,		-- Echo of Jaina
	54123,		-- Echo of Sylvanas
	54544,		-- Echo of Tyrande
	54432,		-- Murozond
	-- Hour of Twilight
	54590,		-- Arcurion
	54968,		-- Asira Dawnslayer
	54938,		-- Archbishop Benedictus
	-- Well of Eternity
	55085,		-- Peroth'arn
	54853,		-- Queen Azshara
	54969,		-- Mannoroth
	55419,		-- Captain Varo'then
	
	-- Mists of Pandaria Dungeons --
	-- Scarlet Halls
	59303,		-- Houndmaster Braun
	58632,		-- Armsmaster Harlan
	59150,		-- Flameweaver Koegler
	-- Scarlet Monastery
	59789,		-- Thalnos the Soulrender
	59223,		-- Brother Korloff
	3977,		-- High Inquisitor Whitemane
	60040,		-- Commander Durand
	-- Scholomance
	58633,		-- Instructor Chillheart
	59184,		-- Jandice Barov
	59153,		-- Rattlegore
	58722,		-- Lilian Voss
	58791,		-- Lilian's Soul
	59080,		-- Darkmaster Gandling
	-- Stormstout Brewery
	56637,		-- Ook-Ook
	56717,		-- Hoptallus
	59479,		-- Yan-Zhu the Uncasked
	-- Tempe of the Jade Serpent
	56448,		-- Wise Mari
	56843,		-- Lorewalker Stonestep
	59051,		-- Strife
	59726,		-- Peril
	58826,		-- Zao Sunseeker
	56732,		-- Liu Flameheart
	56762,		-- Yu'lon
	56439,		-- Sha of Doubt
	-- Mogu'shan Palace
	61444,		-- Ming the Cunning
	61442,		-- Kuai the Brute
	61445,		-- Haiyan the Unstoppable
	61243,		-- Gekkan
	61398,		-- Xin the Weaponmaster
	-- Shado-Pan Monastery
	56747,		-- Gu Cloudstrike
	56541,		-- Master Snowdrift
	56719,		-- Sha of Violence
	56884,		-- Taran Zhu
	-- Gate of the Setting Sun
	56906,		-- Saboteur Kip'tilak
	56589,		-- Striker Ga'dok
	56636,		-- Commander Ri'mok
	56877,		-- Raigonn
	-- Siege of Niuzao Temple
	61567,		-- Vizier Jin'bak
	61634,		-- Commander Vo'jak
	61485,		-- General Pa'valak
	62205,		-- Wing Leader Ner'onok
	
	-- Mists of Pandaria Heroic Scenarios --
	-- A Brewing Storm
	58739,		-- Borokhula the Destroyer
	-- Battle on the High Seas
	71303,		-- Whale Shark <Son of Whale Shark>
	71327,		-- Admiral Hodgson
	67426,		-- Admiral Hagman
	70893,		-- Lieutenant Blasthammer
	71329,		-- Lieutenant Boltblaster
	-- Blood in the Snow
	70468,		-- Bonechiller Barafu
	70474,		-- Farastu <The Living Ice>
	70544,		-- Hekima the Wise <Herald of Rastakhan>
	-- Crypt of the Forgotten Kings
	61707,		-- Abomination of Anger
	71492,		-- Maragor <Guardian of the Golden Doors>
	67081,		-- Forgotten King
	-- Dark Heart of Pandaria
	71123,		-- Echo of Y'Shaarj
	-- The Secrets of Ragefire
	70683,		-- Dark Shaman Xorenth
	71030,		-- Overseer Elaglo
	70665,		-- Kor'kron Dire Soldier

	-- Training Dummies --
	46647,		-- Level 85 Training Dummy
	67127,		-- Level 90 Training Dummy
	
	-- Pandaria Raid Adds --
	63346,		-- Tsulong: The Dark of Night
	62969,		-- Tsulong: Embodied Terror
	62977,		-- Tsulong: Frightspawn
	62919,		-- Tsulong: Unstable Sha
	61034,		-- Sha of Fear: Terror Spawn
	61003		-- Sha of Fear: Dread Spawn
}

-- Cataclysm: Dragon Soul variables
PQ_Shrapnel			= {106794,106791}
PQ_FadingLight		= {105925,105926,109075,109200}
PQ_HourOfTwilight	= {106371,103327,106389,106174,106370}

-- Temporary Buffs/Procs
PQ_Lightweave		= 125487
PQ_PowerTorrent		= 74241
PQ_VolcanicPotion	= 79476
PQ_SynapseSprings	= 96230
PQ_SynapseSprings2	= 126734
PQ_JadeSerpent		= 105702
PQ_JadeSpirit		= 104993
PQ_BloodLust		= 2825
PQ_Heroism			= 32182
PQ_TimeWarp			= 80353
PQ_Hysteria			= 90355
PQ_Zerk				= 26297

-- Temporary Buff Table
PQ_TemporaryBuffs = {
	{spellID = PQ_JadeSpirit, check = true, hasBuff = false, endTime = nil},
	{spellID = PQ_Lightweave, check = true, hasBuff = false, endTime = nil},
	{spellID = PQ_JadeSerpent, check = true, hasBuff = false, endTime = nil},
	{spellID = PQ_PowerTorrent, check = true, hasBuff = false, endTime = nil},
	{spellID = PQ_VolcanicPotion, check = true, hasBuff = false, endTime = nil},
	{spellID = PQ_SynapseSprings, check = true, hasBuff = false, endTime = nil},
	{spellID = PQ_SynapseSprings2, check = true, hasBuff = false, endTime = nil},
	{spellID = 126577, check = true, hasBuff = false, endTime = nil},
	{spellID = 138703, check = true, hasBuff = false, endTime = nil},
	{spellID = 137590, check = true, hasBuff = false, endTime = nil},
	{spellID = 138963, check = true, hasBuff = false, endTime = nil}
}

-- Warlock Tier set table
warlockT15 = {
	96725,96726,96727,96728,96729,	-- Tier 15: Heroic
	95325,95326,95327,95328,95329,	-- Tier 15: Normal
	95981,95982,95983,95984,95985	-- Tier 15: LFR
}

-- Disable Doom
disableDoom = nil
function disableDoom(unit)
	local disableDoomList = disableDoomList
	local npcID = false
	
	-- Grab NPC ID
	if UnitExists("target") then
		local npcID = tonumber(UnitGUID("target"):sub(6,10), 16)
	end
	if UnitExists("mouseover") then
		local npcID = tonumber(UnitGUID("mouseover"):sub(6,10), 16)
	end
	
	-- Loop Units.
	if npcID then
		for i=1,#disableDoom do
			if disableDoom[i] == npcID then return true end
		end
		return false
	end
end
	

-- Unit Information Function
Hysteria_UnitInfo = nil
function Hysteria_UnitInfo(t)
	local TManaActual = UnitPower(t)
	local TMaxMana = UnitPowerMax(t)
	local TMana = 100 * UnitPower(t) / TMaxMana
	local THealthActual = UnitHealth(t)
	local THealth = 100 * UnitHealth(t) / UnitHealthMax(t)
	local myClassPower = 0
	local PQ_Class = select(2, UnitClass(t))
	local PQ_UnitLevel = UnitLevel(t)
	local PQ_CombatCheck = UnitAffectingCombat(t)
	local PQ_Spec = GetSpecialization()
	
	if TMaxMana == 0 then TMaxMana = 1 end
	
	if PQ_Class == "PALADIN" then
		myClassPower = UnitPower("player", 9)
		if UnitBuffID("player", 90174) then
			myClassPower = myClassPower + 3
		end
	elseif PQ_Class == "PRIEST" then myClassPower = UnitPower("player", 13)
	elseif PQ_Class == "WARLOCK" then
		if PQ_Spec == 3 then
			myClassPower = UnitPower("player", 14)	-- Destruction: Burning Embers
		elseif PQ_Spec == 2 then
			myClassPower = UnitPower("player", 15)	-- Demonology: Demonic Fury
		elseif PQ_Spec == 1 then
			myClassPower = UnitPower("player", 7)	-- Affliction: Soul Shards
		end
	elseif PQ_Class == "DRUID" and PQ_Class == 2 then myClassPower = UnitPower("player", 8)
	elseif PQ_Class == "MONK"  then myClassPower = UnitPower("player", 12)
	elseif PQ_Class == "ROGUE" and t ~= "player" then myClassPower = GetComboPoints("player", t) end
	
	return THealth, THealthActual, TMana, TManaActual, myClassPower, PQ_Class, PQ_UnitLevel, PQ_CombatCheck
end

-- Combat log event reader
function HysteriaFrame_OnEvent(self,event,...)
	if event == "UNIT_SPELLCAST_CHANNEL_START" then
		if UnitChannelInfo("player") == GetSpellInfo(15407) then
			flayTicks = 0
			maxFlayTicks = 3
		end
		if UnitChannelInfo("player") == GetSpellInfo(129197) then
			insanityTicks = 0
			maxInsanityTicks = 3
		end
	end
	
	if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		flayTicks = 0
		insanityTicks = 0
		maxFlayTicks = 3
		maxInsanityTicks = 3
	end
	
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
		if #dotTracker > 0 then dotTracker = {} end
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local subEvent		= select(2, ...)
		local source		= select(5, ...)
		local destGUID		= select(8, ...)
		local destination	= select(9, ...)
		local spell			= select(13, ...)
		local damage		= select(15, ...)
		local critical		= select(21, ...)
		local buffList = buffList
		local doom_tick_every = PQ_Round(15/(1+(UnitSpellHaste("player")/100)),2)
		
		if subEvent == "UNIT_DIED" then
			-- A unit has died, is it in our tracker?
			if #dotTracker > 0 then
				for i=1,#dotTracker do
					if dotTracker[i].guid == destGUID then tremove(dotTracker, i) return true end
				end
			end
		end
		
		if subEvent == "SPELL_CAST_SUCCESS" then
			-- Tortos: Rockfall Timer
			if UnitName("boss1") == source and spell == GetSpellInfo(134476) then Rockfall = GetTime() end
		end
		
		if subEvent == "SPELL_PERIODIC_DAMAGE" then
			-- Catch Ignite
			if UnitName("player") == source and destination == UnitName("target") then
				if spell == GetSpellInfo(12654) then  
					IgniteDamage = damage 
				end
			end
			
			-- Mind Flay
			if UnitName("player") == source and spell == GetSpellInfo(15407) then flayTicks = flayTicks + 1 end
			-- Mind Flay (Insanity)
			if UnitName("player") == source and spell == GetSpellInfo(129197) then insanityTicks = insanityTicks + 1 end
		end
		
		if subEvent == "SPELL_AURA_REFRESH" then
			-- Doom was refreshed on an enemy, update our table.
			if UnitName("player") == source and spell == GetSpellInfo(PQ_Doom) then
				if #dotTracker > 0 then
					for i=1,#dotTracker do
						if dotTracker[i].guid == destGUID then
							dotTracker[i].doomPower = mentallyPower(603)
							dotTracker[i].doom_tick_every = doom_tick_every
							
							if UnitBuffID("player",138963) then
								dotTracker[i].crit = true
							else
								dotTracker[i].crit = false
							end
						end
					end
				end
			end
			
			-- Mind Flay
			if UnitName("player") == source and spell == GetSpellInfo(15407) then
				flayTicks = 0
				maxFlayTicks = 4
			end
			
			-- Mind Flay (Insanity)
			if UnitName("player") == source and spell == GetSpellInfo(129197) then
				insanityTicks = 0
				maxInsanityTicks = 4
			end
		end
		
		-- Removed aura events
		if subEvent == "SPELL_AURA_REMOVED" then
			if UnitName("player") == source then
				-- Doom fell of a unit, remove unit from tracker.
				if spell == GetSpellInfo(PQ_Doom) then
					if #dotTracker > 0 then
						for i=1,#dotTracker do
							if dotTracker[i].guid == destGUID then tremove(dotTracker, i) return true end
						end
					end
				end
				
				-- Ignite fell off a unit
				if spell == GetSpellInfo(12654) then  
					IgniteDamage = 0 
				end
				
				-- Mind Flay
				if spell == GetSpellInfo(15407) then flayTicks = 0 maxFlayTicks = 3 end
				
				-- Mind Flay (Insanity)
				if spell == GetSpellInfo(129197) then insanityTicks = 0 maxInsanityTicks = 3 end
				
				-- Living Bomb fell off a target
				if spell == GetSpellInfo(44457) then
					LivingBomb = LivingBomb - 1
				end
				
				-- A proc or temporary buff fell off us
				for i=1,#buffList do
					if spell == GetSpellInfo(buffList[i]) then
						Trinket = Trinket - 1
					end
				end
			end
		end
		
		-- Applied aura events
		if subEvent == "SPELL_AURA_APPLIED" then
			if UnitName("player") == source then
				-- Doom applied to a unit, add unit to tracker
				if spell == GetSpellInfo(PQ_Doom) then
					for i=1,#dotTracker do if dotTracker[i].guid == destGUID then return false end end
					
					if UnitBuffID("player",138963) then
						table.insert(dotTracker, {guid = destGUID, doomPower = mentallyPower(603), doom_tick_every = doom_tick_every, crit = true})
					else
						table.insert(dotTracker, {guid = destGUID, doomPower = mentallyPower(603), doom_tick_every = doom_tick_every, crit = false})
					end
				end
				
				-- Living Bomb applied to any target
				if spell == GetSpellInfo(44457) then
					LivingBomb = LivingBomb + 1
				end
				
				-- A proc or temporary buff applied on us
				for i=1,#buffList do
					if spell == GetSpellInfo(buffList[i]) then
						Trinket = Trinket + 1
					end
				end
			end
		end
		
		-- Damage events
		if subEvent == "SPELL_DAMAGE" then
			if UnitName("player") == source and destination == UnitName("target") then
				-- Pyroblast
				if spell == GetSpellInfo(PQ_Pyro) then
					PyroDamage = damage
					if critical == 1 then pyroCrit = 1 else pyroCrit = 0 end
				end
				-- Fireball
				if spell == GetSpellInfo(PQ_Fireball) then
					FireballDamage = damage
					if critical == 1 then fireballCrit = 1 else fireballCrit = 0 end
				end
				-- Inferno Blast
				if spell == GetSpellInfo(PQ_IBlast) then
					InfernoDamage = damage
					if critical == 1 then infernoCrit = 1 else infernoCrit = 0 end
				end
			end
		end
	end
end

-- Function to check if buff.duration > spell.cast_time
Hysteria_CastCheck = nil
function Hysteria_CastCheck(spell, buff)
	-- Someone forgot to input something, return false by default.
	if buff == nil then return false end
	if spell == nil then return false end
	
	-- Variables and functions we need to make this work.
	local PQ_Round = PQ_Round
	local buffName,_,_,_,_,_,buffTime = UnitBuffID("player",buff)
	
	if buffName then
		-- It's an instant spell, return true no matter what.
		if select(7,GetSpellInfo(spell)) == 0 then return true end
		
		-- Check the cast time
		if buffTime - GetTime() > PQ_Round(select(7,GetSpellInfo(spell))/1000,2) then return true
			else return false end
	end
	return false
end

-- Function to check if buff.cooldown > spell.cast_time
Hysteria_CooldownCast = nil
function Hysteria_CooldownCast(spell, cooldown)
	-- Someone forgot to input something, return false by default.
	if spell == nil then return false end
	if cooldown == nil then return false end
	
	-- Variables and functions we need to make this work.
	local PQ_Round = PQ_Round
	local spellCD = GetSpellCooldown(cooldown) + select(2,GetSpellCooldown(cooldown)) - GetTime()
	
	-- Validate the cooldown check
	if PQR_SpellAvailable(cooldown) or spellCD <= 0 then spellCD = 0 end
	
	if spellCD > 0 then
		-- It's an instant spell, return true no matter what.
		if select(7,GetSpellInfo(spell)) == 0 then return true end
		
		-- Check the cast time
		if spellCD > PQ_Round(select(7,GetSpellInfo(spell))/1000,2) then return true
			else return false end
	end
	return false
end

-- DoT Mind Control Function
isMindControledUnit = nil
function isMindControledUnit(unit)
	if IsInRaid() then group = "raid"
		elseif IsInGroup() then group = "party"
	else return true end
		
	-- Stop dots on MCed raid members
	for i=1,GetNumGroupMembers() do
		local member = group..i
		if not UnitCanAttack("player",unit) then return true
		else
			if UnitName(unit) == member then return false end
		end
		return true
	end
end

-- Returns the number of items currently equipped from the given table.
itemCheck = nil
function itemCheck(tbl)
	local itemCount = 0
	for i=1,#tbl do
		if IsEquippedItem(tbl[i]) then
			itemCount = itemCount + 1
		end
	end
	return itemCount
end

-- Aura Information Function
PQ_AuraInfo = nil
function PQ_AuraInfo(i,unit)
	if i == 1 then
		for x = 1, #buffs.stat do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.stat[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 2 then
		for x = 1, #buffs.stamina do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.stamina[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 3 then
		for x = 1, #buffs.atkpwr do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.atkpwr[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 4 then
		for x = 1, #buffs.atkspeed do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.atkspeed[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 5 then
		for x = 1, #buffs.spllpwr do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.spllpwr[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 6 then
		for x = 1, #buffs.spllhaste do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.spllhaste[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 7 then
		for x = 1, #buffs.crit do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.crit[x])))
			if texture then
				return name, _, texture
			end
		end
	elseif i == 8 then
		for x = 1, #buffs.mastery do
			local name, _, texture = UnitBuff(unit, (GetSpellInfo(buffs.mastery[x])))
			if texture then
				return name, _, texture
			end
		end
	else 
		return nil, nil, nil
	end
end

-- Check Temporary Buffs Function
PQ_CheckTempBuffs = nil
function PQ_CheckTempBuffs(t)
	for i=1,#t do
		if t[i].check == true and UnitBuffID("player",t[i].spellID) then
			t[i].hasBuff = true
			t[i].endTime = select(7,UnitBuffID("player",t[i].spellID))
		else
			t[i].hasBuff = false
			t[i].endTime = nil
		end
	end
end

-- Get Time Left on Buffs Function
PQ_GetTimeLeft = nil
function PQ_GetTimeLeft(t, spellID)
	for i=1,#t do
		if t[i].spellID == spellID and t[i].hasBuff == true then
			return t[i].endTime - GetTime()
		end
	end
end

-- Heroism check Function
PQ_HasHero = nil
function PQ_HasHero()
	local heroism = {PQ_BloodLust, PQ_Heroism, PQ_TimeWarp, PQ_Hysteria}
	
	for i=1,#heroism do
		if UnitBuffID("player",heroism[i]) then return true, heroism[i] end
	end
	return false
end

-- Rounding Function
PQ_Round = nil
function PQ_Round(number, decimal)
	local multiplier = 10^(decimal or 0)
	return math.floor(number * multiplier + 0.5) / multiplier
end
PQ_PowerRound = nil
function PQ_PowerRound(num) return math.floor(num+.5) end

-- Smart channel cancel Function
smartCancel = nil
function smartCancel()
	-- Don't cancel Mind Sear
	if UnitChannelInfo("player") == GetSpellInfo(PQ_MSear) then return false end
	
	-- Not smart cancelling Mind Flay, default.
	if not PQI_MentallyShadow_MindFlay_enable then
		if UnitChannelInfo("player") == GetSpellInfo(PQ_MF) then return false end
	end
	
	-- Not smart cancelling Mind Flay (Insanity), default.
	if not PQI_MentallyShadow_MindFlayInsanity_enable then
		if UnitChannelInfo("player") == GetSpellInfo(PQ_MFI) then return false end
	end
	
	-- Mind Flay failsafe.
	if PQI_MentallyShadow_MindFlay_enable then
		if PQI_MentallyShadow_MindFlay_value > 2 then
			if UnitChannelInfo("player") == GetSpellInfo(PQ_MF) and flayTicks < maxFlayTicks - 1 then return false end
		else
			if UnitChannelInfo("player") == GetSpellInfo(PQ_MF) and flayTicks < PQI_MentallyShadow_MindFlay_value then return false end
		end
	end
	
	-- Mind Flay Insanity failsafe.
	if PQI_MentallyShadow_MindFlayInsanity_enable then
		if PQI_MentallyShadow_MindFlayInsanity_value > 2 then
			if UnitChannelInfo("player") == GetSpellInfo(PQ_MFI) and insanityTicks < maxInsanityTicks - 1 then return false end
		else
			if UnitChannelInfo("player") == GetSpellInfo(PQ_MFI) and insanityTicks < PQI_MentallyShadow_MindFlayInsanity_value then return false end
		end
	end
	
	return true
end

-- Boss Unit Function
SpecialUnit = nil
function SpecialUnit()
	local PQ_BossUnits = PQ_BossUnits
	
	if UnitExists("target") then
		local npcID = tonumber(UnitGUID("target"):sub(6,10), 16)
		
		-- Dungeons & Raids
		if UnitLevel("target") == -1 then return true else
			for i=1,#PQ_BossUnits do
				if PQ_BossUnits[i] == npcID then return true end
			end
			return false
		end
	else return false end
end

-- Time 2 Die
T2D = nil
function T2D(unit)
	-- If no target is given, return false.
	if unit == nil then return false end
	
	if UnitExists(unit) then
		-- Target present; Set initial values.
		if (guid ~= UnitGUID(unit)) or (guid == UnitGUID(unit) and UnitHealth(unit) == _firstLifeMax) then
			guid = UnitGUID(unit)
			_firstLife = UnitHealth(unit)
			_firstLifeMax = UnitHealthMax(unit)
			_firstTime = GetTime()
		end
		
		-- Fetch current values.
		_currentLife = UnitHealth(unit)
		_currentTime = GetTime()
		timeDiff = _currentTime - _firstTime
		hpDiff = _firstLife - _currentLife
		
		-- Calculate time to die.
		if hpDiff > 0 then
			fullTime = timeDiff*_firstLifeMax/hpDiff
			pastFirstTime = (_firstLifeMax - _firstLife)*timeDiff/hpDiff
			calcTime = _firstTime - pastFirstTime + fullTime - _currentTime
			if calcTime < 1 then calcTime = 1 end
			timeToDie = calcTime
		end
		
		-- New target; reset settings.
		if hpDiff <= 0 then
			guid = UnitGUID(unit)
			_firstLife = UnitHealth(unit)
			_firstLifeMax = UnitHealth(unit)
			_firstTime = GetTime()
		end
	            
		-- Training Dummy's are bad
		if UnitHealthMax(unit) == 1 then timeToDie = 99 end
		
		-- Initialize
		if not timeToDie then timeToDie = 100 end
		
		return timeToDie
	end
end

-- Target Validation Function
TargetValidation = nil
function TargetValidation(unit, spell)
	-- Let's try and detect immunities
	if UnitBuffID(unit,116994) or UnitBuffID(unit,122540) or UnitBuffID(unit,123250) or UnitBuffID(unit,106062) or UnitBuffID(unit,110945)
		then return false end
	
	-- Cancel spell casts or channels on silences
	if UnitCastingInfo(unit) == GetSpellInfo(138763) or UnitCastingInfo(unit) == GetSpellInfo(138763) then
		if UnitCastingInfo("player") or UnitChannelInfo("player") then RunMacroText("/stopcasting") return false end
		return false
	end
	
	-- Heroic: Twin Consorts (Immune while channeling Nuclear Inferno and Tidal Force)
	if UnitChannelInfo(unit) == GetSpellInfo(137531) or UnitChannelInfo(unit) == GetSpellInfo(137491) or UnitCastingInfo(unit) == GetSpellInfo(138763) or UnitCastingInfo(unit) == GetSpellInfo(138763)
		then return false end
	
	if UnitExists(unit)
		and IsPlayerSpell(spell)
		and UnitCanAttack("player", unit) == 1
		and not UnitIsDeadOrGhost(unit)
		and not PQR_IsOutOfSight(unit, 1) then
			if IsSpellKnown(spell) then
				if PQR_SpellAvailable(spell) then
					if IsSpellInRange(GetSpellInfo(spell), unit) == 1 then return true else return false end
				else
					if spell == 8092 or spell == 32379 then
						local spellCD = select(2,GetSpellCooldown(spell)) + GetSpellCooldown(spell) - GetTime()
						if spellCD <= 0 then spellCD = 0 end
						if spellCD <= 0.5 then return true end
					end
					return false
				end
			else
				if select(2, GetSpellCooldown(spell)) == 0 then return true end
			end
	end
end

------------------------------------------------------------
-- Class Configurations
------------------------
if select(2, UnitClass("player")) == "DRUID" then
	PQR_WriteToChat("|cffFFBE69Loading |cffC27C0CDruid|cffFFBE69 Tables ...|cffffffff")
	
	-- Balance Skill ID's
	PQ_InsectSwarm		= 5570		-- Insect Swarm
	PQ_Moonfire			= 8921		-- Moonfire / Sunfire
	PQ_Sunfire			= 93402		-- Sunfire
	PQ_Starsurge		= 78674		-- Starsurge
	PQ_Wrath			= 5176		-- Wrath
	PQ_Starfire			= 2912		-- Starfire
	
	-- AoE Skill ID's
	PQ_Hurricane		= 16914		-- Hurricane
	PQ_Typhoon			= 50516		-- Typhoon
	PQ_WildMushroom		= 88747		-- Wild Mushroom
	PQ_Starfall			= 48505 	-- Starfall
	PQ_SBeam			= 78675		-- Solar Beam
	PQ_Astorm			= 106996	-- Astral Storm (Channeled)
	
	-- DoT ID's
	PQ_Sunfire			= 93402		-- Sunfire DoT
	
	-- Cooldown & Buff ID's
	PQ_AC				= 127663	-- Astral Communion
	PQ_CAlign			= 112071	-- Celestial Alignment
	PQ_WCharge			= 102383	-- Wild Charge
	PQ_Cenarion			= 102351	-- Cenarion Ward
	PQ_Innervate		= 29166		-- Innervate
	PQ_MotW				= 1126		-- Mark of the Wild Skill
	PQ_Hibernate		= 2637		-- Hibernate
	PQ_Tranquility		= 740		-- Tranquility
	PQ_FoN				= 33831		-- Forces of Nature
	
	PQ_MoTW2			= 79061		-- Mark of the Wild Buff
	PQ_Solar			= 48517		-- Solar Eclipse
	PQ_Lunar			= 48518		-- Lunar Eclipse
	
	-- Druid Forms
	PQ_Moonkin			= 24858		-- Moonkin Form
	PQ_Moonkin2			= 1020560	-- Incarnation: Chosen of Elune
	
	-- Spell Table
	Hysteria_Spell = {
		[PQ_InsectSwarm]	= {check = true, known = IsPlayerSpell(PQ_InsectSwarm)},
		[PQ_Moonfire]		= {check = true, known = IsPlayerSpell(PQ_Moonfire)},
		[PQ_Starsurge]		= {check = true, known = IsPlayerSpell(PQ_Starsurge)},
		[PQ_Wrath]			= {check = true, known = IsPlayerSpell(PQ_Wrath)},
		[PQ_Starfire]		= {check = true, known = IsPlayerSpell(PQ_Starfire)},
		[PQ_Hurricane]		= {check = true, known = IsPlayerSpell(PQ_Hurricane)},
		[PQ_Typhoon]		= {check = true, known = IsPlayerSpell(PQ_Typhoon)},
		[PQ_WildMushroom]	= {check = true, known = IsPlayerSpell(PQ_WildMushroom)},
		[PQ_Starfall]		= {check = true, known = IsPlayerSpell(PQ_Starfall)},
		[PQ_SBeam]			= {check = true, known = IsPlayerSpell(PQ_SBeam)},
		[PQ_Astorm]			= {check = true, known = IsPlayerSpell(PQ_Astorm)},
		[PQ_AC]				= {check = true, known = IsPlayerSpell(PQ_AC)},
		[PQ_CAlign]			= {check = true, known = IsPlayerSpell(PQ_CAlign)},
		[PQ_WCharge]		= {check = true, known = IsPlayerSpell(PQ_WCharge)},
		[PQ_Cenarion]		= {check = true, known = IsPlayerSpell(PQ_Cenarion)},
		[PQ_Innervate]		= {check = true, known = IsPlayerSpell(PQ_Innervate)},
		[PQ_MotW]			= {check = true, known = IsPlayerSpell(PQ_MotW)},
		[PQ_Hibernate]		= {check = true, known = IsPlayerSpell(PQ_Hibernate)},
		[PQ_Tranquility]	= {check = true, known = IsPlayerSpell(PQ_Tranquility)},
		[PQ_FoN]			= {check = true, known = IsPlayerSpell(PQ_FoN)},
		[PQ_Moonkin]		= {check = true, known = IsPlayerSpell(PQ_Moonkin)},
		[PQ_Moonkin2]		= {check = true, known = IsPlayerSpell(PQ_Moonkin2)}
	}
elseif select(2, UnitClass("player")) == "MAGE" then
	PQR_WriteToChat("|cffFFBE69Loading |cff69CCF0Mage|cffFFBE69 Tables ...|cffffffff")
	
	-- PQInterface Settings
	local config = {
		name	= "Mage",
		author	= "Mentally",
		abilities	= {
			{ 	name	= "Healthstone",
				enable	= true,
				widget	= { type = "numBox",
					value	= 50,
					step	= 5,
					tooltip	= "Automatically use Healthstone at set Health Value",
				},
			},
			{ 	name	= "Mana Gem",
				enable	= true,
				widget	= { type = "numBox",
					value	= 85,
					step	= 5,
					tooltip	= "Automatically use Mana Gem at set Mana Value",
				},
			},
			{ 	name	= "Raid Buffing",
				tooltip	= "Automatically buff raid members when no multiplier buff is available",
				enable	= true,
				newSection = true,
			},
			{ 	name	= "Pet Management",
				tooltip	= "Automatically summon and manage your Water Elemental.",
				enable	= true,
			},
			{ 	name	= "Combat Detection",
				tooltip	= "Only allow buffing and summoning of pet while not in combat.",
				enable	= true,
			},
			{ 	name	= "Auto Potion",
				tooltip	= "Automatically use your DPS potion during Heroism",
				enable	= true,
				newSection = true,
			},
			{ 	name	= "Auto Racials",
				tooltip	= "Automatically use your Racial & Profession abilities",
				enable	= true,
			},
			{ 	name	= "Automatic Frost Mode",
				tooltip	= "This mode overrides settings for your major cooldowns and allows the profile to try and determine the best situational use for these abilities.",
				enable	= true,
				newSection = true,
			},
			{ 	name	= "Automatic Fire Mode",
				tooltip	= "This mode overrides settings for your major cooldowns and allows the profile to try and determine the best situational use for these abilities.",
				enable	= true,
			},
			{ 	name	= "Automatic Mirror Image",
				tooltip	= "Automatically use Mirror Image.",
				enable	= true,
			},
			{ 	name	= "Boss Only Cooldowns",
				tooltip	= "Only use cooldowns on Boss and Special units.",
				enable	= true,
			},
			{ 	name	= "Mouseover Dotting",
				tooltip	= "Cast DoTs on Mouseover.",
				enable	= true,
				newSection = true,
			},
			{ 	name	= "Focus Dotting",
				tooltip	= "Cast DoTs on Focus.",
				enable	= true,
			},
		},
		hotkeys		= {
			{	name	= "Pause Rotation",
				enable	= true,
				hotkeys	= {'rc', 'ra'},
			},
			{	name	= "Toggle Cooldown Mode",
				enable	= false,
				hotkeys	= {'rs'},
			},
			{	name	= "Level 30 Talent",
				enable	= true,
				hotkeys	= {'rc'},
			},
			{	name	= "Level 45 Talent",
				enable	= true,
				hotkeys	= {'rs'},
			},
			{	name	= "Level 90 Talent",
				enable	= true,
				hotkeys	= {'ra'},
			},
			{	name	= "Combustion",
				enable	= false,
				hotkeys	= {'ls'},
			},
			{	name	= "Icy Veins",
				enable	= false,
				hotkeys	= {'ls'},
			},
			{	name	= "Alter Time",
				enable	= false,
				hotkeys	= {'la'},
			},
			{	name	= "Pet Freeze (Mouseover)",
				enable	= true,
				hotkeys	= {'rs'},
			},
			{	name	= "Flamestrike (Mouseover)",
				enable	= true,
				hotkeys	= {'la'},
			},
		},
	}
	HYSTERIA_MAGE = PQI:AddRotation(config)
	
	-- Skills
	PQ_Frostbolt	= 116		-- Frostbolt
	PQ_FFB			= 44614		-- Frostfire Bolt
	PQ_IL			= 30455		-- Ice Lance
	PQ_FO			= 84714		-- Frozen Orb
	PQ_CoC			= 120		-- Cone of Cold
	PQ_Pyro			= 11366		-- Pyroblast
	PQ_IBlast		= 108853	-- Inferno Blast
	PQ_FBlast		= 2136		-- Fire Blast
	PQ_FS			= 2120		-- Flamestrike
	PQ_Fireball		= 133		-- Fireball
	PQ_Blizzard		= 10		-- Blizzard
	PQ_Freeze		= 33395		-- Pet: Freeze
	
	-- Cooldowns
	PQ_IB			= 45438		-- Ice Block
	PQ_MI			= 55342		-- Mirror Image
	PQ_IV			= 12472		-- Icy Veins (Unglyphed)
	PQ_Evo			= 12051		-- Evocation
	PQ_Comb			= 11129		-- Combustion
	PQ_Decurse		= 475		-- Remove Curse
	PQ_Counterspell	= 2139		-- Counterspell
	
	-- Buffs
	PQ_WElm			= 31687		-- Summon: Water Elemental
	PQ_MA			= 30482		-- Molten Armor
	PQ_MAA			= 6117		-- Mage Armor
	PQ_ABril		= 1459		-- Arcane Brilliance
	PQ_DBril		= 61316		-- Dalaran Brilliance
	PQ_FA			= 7302		-- Frost Armor
	PQ_InvoBuff		= 116257	-- Invocation Buff
	PQ_AT			= 108978	-- Alter Time
	PQ_ATB			= 110909	-- Alter Time Buff
	
	-- Procs
	PQ_BrainF		= 57761		-- Brain Freeze
	PQ_FoF			= 44544		-- Fingers of Frost
	PQ_HU			= 48107		-- Heating Up
	PQ_PY			= 48108		-- Pyroblast!
	
	-- Talents
	PQ_POM			= 12043		-- Presence of Mind
	PQ_Scorch		= 2948		-- Scorch
	PQ_RoF			= 113724	-- Ring of Frost
	
	PQ_Temporal		= 115610	-- Temporal Shield
	PQ_Barrier		= 11426		-- Ice Barrier
	
	PQ_IW			= 111264	-- Ice Ward
	PQ_FJ			= 102051	-- Frost Jaw
	PQ_GI			= 110959	-- Greater Invisibility
	
	PQ_CS			= 11958		-- Cold Snap
	PQ_NT			= 114923	-- Nether Tempest
	PQ_LB			= 44457		-- Living Bomb
	PQ_FrostBomb	= 112948	-- Frost Bomb
	PQ_Invo			= 114003	-- Invocation
	PQ_RoP			= 116011	-- Rune of Power
	PQ_Ward			= 1463		-- Incanter's Ward
	
	-- Spell Table
	Hysteria_Spell = {
		[PQ_GI]			= {check = true, known = IsPlayerSpell(PQ_GI)},
		[PQ_IW]			= {check = true, known = IsPlayerSpell(PQ_IW)},
		[PQ_AT]			= {check = true, known = IsPlayerSpell(PQ_AT)},
		[PQ_IL]			= {check = true, known = IsPlayerSpell(PQ_IL)},
		[PQ_FO]			= {check = true, known = IsPlayerSpell(PQ_FO)},
		[PQ_MA]			= {check = true, known = IsPlayerSpell(PQ_MA)},
		[PQ_LB]			= {check = true, known = IsPlayerSpell(PQ_LB)},
		[PQ_FS]			= {check = true, known = IsPlayerSpell(PQ_FS)},
		[PQ_NT]			= {check = true, known = IsPlayerSpell(PQ_NT)},
		[PQ_FJ]			= {check = true, known = IsPlayerSpell(PQ_FJ)},
		[PQ_CS]			= {check = true, known = IsPlayerSpell(PQ_CS)},
		[PQ_IB]			= {check = true, known = IsPlayerSpell(PQ_IB)},
		[PQ_MI]			= {check = true, known = IsPlayerSpell(PQ_MI)},
		[PQ_IV]			= {check = true, known = IsPlayerSpell(PQ_IV)},
		[PQ_FA]			= {check = true, known = IsPlayerSpell(PQ_FA)},
		[PQ_RoP]		= {check = true, known = IsPlayerSpell(PQ_RoP)},
		[PQ_RoF]		= {check = true, known = IsPlayerSpell(PQ_RoF)},
		[PQ_FFB]		= {check = true, known = IsPlayerSpell(PQ_FFB)},
		[PQ_MAA]		= {check = true, known = IsPlayerSpell(PQ_MAA)},
		[PQ_Evo]		= {check = true, known = IsPlayerSpell(PQ_Evo)},
		[PQ_CoC]		= {check = true, known = IsPlayerSpell(PQ_CoC)},
		[PQ_POM]		= {check = true, known = IsPlayerSpell(PQ_POM)},
		[PQ_Ward]		= {check = true, known = IsPlayerSpell(PQ_Ward)},
		[PQ_Invo]		= {check = true, known = IsPlayerSpell(PQ_Invo)},
		[PQ_WElm]		= {check = true, known = IsPlayerSpell(PQ_WElm)},
		[PQ_Comb]		= {check = true, known = IsPlayerSpell(PQ_Comb)},
		[PQ_Pyro]		= {check = true, known = IsPlayerSpell(PQ_Pyro)},
		[PQ_ABril]		= {check = true, known = IsPlayerSpell(PQ_ABril)},
		[PQ_DBril]		= {check = true, known = IsPlayerSpell(PQ_DBril)},
		[PQ_Freeze]		= {check = true, known = IsPlayerSpell(PQ_Freeze)},
		[PQ_IBlast]		= {check = true, known = IsPlayerSpell(PQ_IBlast)},
		[PQ_Scorch]		= {check = true, known = IsPlayerSpell(PQ_Scorch)},
		[PQ_Barrier]	= {check = true, known = IsPlayerSpell(PQ_Barrier)},
		[PQ_Fireball]	= {check = true, known = IsPlayerSpell(PQ_Fireball)},
		[PQ_Blizzard]	= {check = true, known = IsPlayerSpell(PQ_Blizzard)},
		[PQ_Temporal]	= {check = true, known = IsPlayerSpell(PQ_Temporal)},
		[PQ_Frostbolt]	= {check = true, known = IsPlayerSpell(PQ_Frostbolt)},
		[PQ_FrostBomb]	= {check = true, known = IsPlayerSpell(PQ_FrostBomb)}
	}
elseif select(2, UnitClass("player")) == "PRIEST" then
	PQR_WriteToChat("|cffFFBE69Loading |cffffffffPriest|cffFFBE69 Tables ...|cffffffff")
	
	-- PQInterface Settings
	local config = {
		name	= "Shadow",
		author	= "Mentally",
		abilities	= {
			{ 	name	= "Healthstone",
				enable	= true,
				widget	= { type = "numBox",
					value	= 50,
					step	= 5,
					tooltip	= "Set automatic Healthstone usage.",
				},
			},
			{ 	name	= "Desperate Prayer",
				enable	= true,
				widget	= { type = "numBox",
					value	= 50,
					step	= 5,
					tooltip	= "Set automatic Desperate Prayer usage.",
				},
			},
			{ 	name	= "Void Shift",
				enable	= true,
				widget	= { type = "numBox",
					value	= 50,
					step	= 5,
					tooltip	= "Set automatic Void Shift usage.",
				},
			},
			{ 	name	= "Combat Detection",
				tooltip	= "Only allow buffing and summoning of pet while not in combat.",
				enable	= true,
				newSection  = true,
			},
			{ 	name	= "Auto Racials",
				tooltip	= "Automatic Racial usage.",
				enable	= true,
			},
			{ 	name	= "Auto Potion",
				tooltip	= "Automatic Potion usage under Heroism.",
				enable	= true,
			},
			{ 	name	= "Auto Shadowfiend",
				tooltip	= "Automatic Shadowfiend usage.",
				enable	= true,
			},
			{ 	name	= "Auto Power Infusion",
				tooltip	= "Automatic Power Infusion usage.",
				enable	= true,
			},
			{ 	name	= "Auto Level 90 Talent",
				tooltip	= "Automatically casts your selected level 90 talent as appropriately as possible.",
				enable	= true,
			},
			{ 	name	= "Auto Boss Dotting",
				tooltip = "Enabled/Disabled automatic dotting of Boss Units. This is intended to keep dots 100% up all bosses in range while you're doing other things.",
				enable	= true,
				newSection  = true,
			},
			{ 	name	= "Boss Cooldown",
				tooltip = "Enabled/Disabled boss cooldown checks.",
				enable	= true,
			},
			{ 	name	= "Mind Flay",
				enable	= true,
				newSection  = true,
				widget	= { type = "numBox",
					value	= 2,
					step	= 1,
					tooltip	= "Allow spells and abilities to cancel Mind Flay after set ticks.",
				},
			},
			{ 	name	= "Mind Flay (Insanity)",
				enable	= true,
				widget	= { type = "numBox",
					value	= 3,
					step	= 1,
					tooltip	= "Allow spells and abilities to cancel Mind Flay after set ticks.",
				},
			},
		},
		hotkeys = {
			{	name	= "Pause Rotation",
				enable	= true,
				hotkeys	= {'rc', 'ra'},
			},
			{	name	= "Toggle Cooldown Mode",
				enable	= true,
				hotkeys	= {'rs'},
			},
			{	name	= "Dispersion",
				enable	= true,
				hotkeys	= {'ra'},
			},
			{	name	= "Mass Dispel",
				enable	= true,
				hotkeys	= {'la'},
			},
			{	name	= "Mind Sear",
				enable	= true,
				hotkeys	= {'ls'},
			},
			{	name	= "Level 90 Talent",
				enable	= false,
				hotkeys	= {'ls'},
			},
			{	name	= "Level 15 Talent",
				enable	= true,
				hotkeys	= {},
			},
			{	name	= "Void Shift",
				enable	= true,
				hotkeys	= {},
			},
			{	name	= "Vampiric Embrace",
				enable	= true,
				hotkeys	= {},
			},
		},
	}
	HYSTERIA_SHADOW = PQI:AddRotation(config)
	
	-- Skill IDs
	PQ_DP		= 2944			-- Devouring Plague
	PQ_SWD		= 32379			-- Shadow Word: Death
	PQ_MB		= 8092			-- Mind Blast
	PQ_SWP		= 589			-- Shadow Word: Pain
	PQ_VT		= 34914			-- Vampiric Touch
	PQ_MS		= 73510			-- Mind Spike
	PQ_MF		= 15407			-- Mind Flay
	PQ_MFI		= 129197		-- Mind Flay (Insanity)
	PQ_MSear	= 48045			-- Mind Sear
	
	-- Cooldowns
	PQ_SF		= 34433			-- Shadowfiend
	PQ_Disp		= 47585			-- Dispersion
	PQ_DPrayer	= 19236			-- Desperate Prayer
	PQ_Fade		= 586			-- Fade
	PQ_Silence	= 15487			-- Silence
	PQ_Spectral	= 112833		-- Spectral Guise
	PQ_Scream	= 8122			-- Psychic Scream
	PQ_Embrace	= 15286			-- Vampiric Embrace
	
	-- Buffs
	PQ_IF		= 588			-- Inner Fire
	PQ_SForm	= 15473			-- Shadow Form
	PQ_PWF		= 21562			-- Power Word: Fortitude
	PQ_GMS		= 81292			-- Glyph of Mind Spike
	PQ_Shield	= 17			-- Power Word: Shield
	PQ_POM		= 33076			-- Prayer of Mending
	PQ_Renew	= 139			-- Renew
	PQ_Phan		= 108942		-- Phantasm
	PQ_Fear		= 6346			-- Fear Ward
	
	-- Procs
	PQ_SOD		= 87160 		-- Surge of Darkness
	PQ_DI		= 124430		-- Divine Insight
	
	-- Talents
	PQ_PI		= 10060			-- Power Infusion
	PQ_FDCL		= 109186		-- From Darkness, Comes Light
	PQ_Solace	= 129250		-- Power Word: Solace
	PQ_SnI		= 139139		-- Shadow Word: Insanity
	PQ_MBen		= 123040		-- Mindbender
	PQ_Halo		= 120517		-- Halo
	PQ_DarkHalo	= 120644		-- Dark Halo
	PQ_Cascade	= 121135		-- Cascade
	PQ_DCascade = 127632		-- Dark Cascade
	PQ_Star		= 110744		-- Divine Star
	PQ_DStar	= 122121		-- Dark Star
	
	-- Spell Table
	Hysteria_Spell = {
		-- Shadow
		[PQ_DP]			= {check = true, known = IsPlayerSpell(PQ_DP)},
		[PQ_MB]			= {check = true, known = IsPlayerSpell(PQ_MB)},
		[PQ_VT]			= {check = true, known = IsPlayerSpell(PQ_VT)},
		[PQ_MS]			= {check = true, known = IsPlayerSpell(PQ_MS)},
		[PQ_MF]			= {check = true, known = IsPlayerSpell(PQ_MF)},
		[PQ_SF]			= {check = true, known = IsPlayerSpell(PQ_SF)},
		[PQ_IF]			= {check = true, known = IsPlayerSpell(PQ_IF)},
		[PQ_SWD]		= {check = true, known = IsPlayerSpell(PQ_SWD)},
		[PQ_SWP]		= {check = true, known = IsPlayerSpell(PQ_SWP)},
		[PQ_PWF]		= {check = true, known = IsPlayerSpell(PQ_PWF)},
		[PQ_Star]		= {check = true, known = IsPlayerSpell(PQ_Star)},
		[PQ_MBen]		= {check = true, known = IsPlayerSpell(PQ_MBen)},
		[PQ_Disp]		= {check = true, known = IsPlayerSpell(PQ_Disp)},
		[PQ_FDCL]		= {check = true, known = IsPlayerSpell(PQ_FDCL)},
		[PQ_Halo]		= {check = true, known = IsPlayerSpell(PQ_Halo)},
		[PQ_MSear]		= {check = true, known = IsPlayerSpell(PQ_MSear)},
		[PQ_SForm]		= {check = true, known = IsPlayerSpell(PQ_SForm)},
		[PQ_Solace]		= {check = true, known = IsPlayerSpell(PQ_Solace)},
		[PQ_DPrayer]	= {check = true, known = IsPlayerSpell(PQ_DPrayer)},
		[PQ_Cascade]	= {check = true, known = IsPlayerSpell(PQ_Cascade)}
	}
elseif select(2,UnitClass("player")) == "WARLOCK" then
	PQR_WriteToChat("|cffFFBE69Loading |cff9482C9Warlock |cffFFBE69Tables ...|cffffffff")
	
	-- PQInterface Settings
	local Defensive = {
		name	= "Defensive Settings",
		author	= "Mentally",
		abilities = {
			{ 	name	= "Soulstone",
				tooltip = "When enabled; Allows you to select how you want Soulstone usage to be.",
				enable	= true,
				widget	= { type = "select",
					tooltip = "Select Soulstone logic. Use on yourself, Raid or Party Members, or only on Tanks/Healers (Requires Roles to be set!)",
					values	= {
						"Self",
						"Raid/Party",
						"Tank/Healer",
					},
					width	= 100,
				},
			},
			{ 	name	= "Burning Rush",
				tooltip = "When enabled; Allows the profile to automatically use Burning Rush to increase your run-speed while you're moving!",
				enable	= false,
			},
			{ 	name	= "Soulshatter",
				tooltip = "When enabled; Allows the profile to automatically dump threat when you've pulled aggro.",
				enable	= false,
			},
			{ 	name	= "Healthstone",
				tooltip = "When enabled; Allows you to control automatic usage of healthstone at set health %.",
				enable	= true,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Healthstone to be used at.",
					value	= 50,
					step	= 5,
				},
			},
			{ 	name	= "Dark Regeneration",
				tooltip = "When enabled; Allows you to control automatic usage of Dark Regeneration at set health %.",
				enable	= true,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Dark Regeneration to be used at.",
					value	= 50,
					step	= 5,
				},
			},
			{ 	name	= "Mortal Coil",
				tooltip = "When enabled; Allows you to control atuomatic usage of Dark Regeneration at set health %. (Disables Level 30 keybind when enabled!)",
				enable	= false,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Mortal Coil to be used at.",
					value	= 50,
					step	= 5,
				},
			},
			{ 	name	= "Health Funnel",
				tooltip = "When enabled; Allows you to control atuomatic usage of Pet Healing at set health %. Will only be used in Solo profile.",
				enable	= true,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Health Funnel to be channeled at.",
					value	= 45,
					step	= 5,
				},
			},
			{ 	name	= "Health Funnel Max",
				tooltip = "When enabled; Allows you to control at which health % Health Funnel will stop healing your Pet. Will only be used in Solo profile.",
				enable	= true,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Health Funnel to be cancelled at.",
					value	= 90,
					step	= 5,
				},
			},
			{ 	name	= "Drain Life",
				tooltip = "When enabled; Allows you to control atuomatic usage of self healing at set health %. Will only be used in Solo profile.",
				enable	= true,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Drain Life to be channeled at.",
					value	= 35,
					step	= 5,
				},
			},
			{ 	name	= "Drain Life Max",
				tooltip = "When enabled; Allows you to control when the profile will stop using Life Drain to heal itself. Will only be used in Solo profile.",
				enable	= true,
				widget	= { type = "numBox",
					tooltip = "Set the health % value you want Drain Life to be cancelled at.",
					value	= 75,
					step	= 5,
				},
			},
			{ 	name	= "Raid Buffing",
				tooltip = "When enabled; Will automatically try to buff your raid or party.",
				enable	= true,
			},
			{ 	name	= "Raid Buffing",
				tooltip = "When enabled; Will automatically try to buff your raid or party.",
				enable	= true,
			},
		},
		hotkeys = {
			{	name	= "Pause Rotation",
				enable	= false,
				hotkeys	= {},
			},
			{	name	= "Level 30 Talent",
				enable	= true,
				hotkeys	= {'lc', 'la'},
			},
			{	name	= "Level 45 Talent",
				enable	= true,
				hotkeys	= {'rs'},
			},
			{	name	= "Level 90 Talent",
				enable	= false,
				hotkeys	= {},
			},
			{	name	= "Mouseover Fear",
				enable	= false,
				hotkeys	= {},
			},
			{	name	= "Demonic Teleport",
				enable	= false,
				hotkeys	= {},
			},
		},
	}
	local Offensive = {
		name	= "Offensive Settings",
		author	= "Mentally",
		abilities = {
			{ 	name	= "Combat Detection",
			    tooltip = "Toggle the profile to pause automatically when not engaged in combat.",
				enable	= true,
			},
			{ 	name	= "Auto Potion",
			    tooltip = "Toggle the use of Potion of the Jade Serpent under the effects of Bloodlust/Heroism/Time Warp/Ancient Hysteria.",
				enable	= true,
				newSection  = true,
			},
			{ 	name	= "Auto Racials",
			    tooltip = "Toggle the use of Racials.",
				enable	= true,
			},
			{ 	name	= "Auto Imp Swarm",
			    tooltip = "Toggle the use of automatic Imp Swarm during Dark Soul or high haste procs.",
				enable	= true,
			},
			{ 	name	= "Auto Carrion Swarm",
			    tooltip = "Toggle the use of automatic Carrion Swarm during the AoE rotation.",
				enable	= true,
			},
			{ 	name	= "Auto Doomguard",
				tooltip = "Toggle the profile to automatically use Doomguard/Terrorguard at the best possible time.",
				enable	= true,
			},
			{ 	name	= "Frag Belt",
			    tooltip = "Toggle the use of automatic Frag Belt during Metamorphosis (Mouseover).",
				enable	= true,
			},
			{ 	name	= "Boss Cooldown",
			    tooltip = "Toggle the use of cooldowns on boss targets only.",
				enable	= true,
				newSection  = true,
			},
			{ 	name	= "Focus Dotting",
			    tooltip = "Toggle Automatic dotting of the focus target.",
				enable	= true,
			},
			{ 	name	= "Auto Boss Dotting",
			    tooltip = "Toggle the Automatic dotting of all feasible boss targets you're currently engaged with.",
				enable	= true,
			},
			{ 	name	= "Mouseover Dotting",
			    tooltip = "Toggle Automatic dotting of the mouseover target.",
				enable	= true,
			},
			{ 	name	= "Summon Pet",
			    tooltip = "Select the pet that you would like the profile to summon.",
				enable	= true,
				newSection  = true,
				widget	= { type = "select",
					tooltip = "Select the pet that you would like the profile to summon.",
					values	= {
						"Imp",
						"Voidwalker",
						"Felhunter",
						"Succubus",
						"Felguard",
					},
					width	= 100,
				},
			},
			{ 	name	= "Grimoire Pet",
			    tooltip = "Select the Grimoire of Service pet you would like the profile to use.",
				enable	= true,
				widget	= { type = "select",
					tooltip = "Select the Grimoire of Service pet you would like the profile to use.",
					values	= {
						"Imp",
						"Voidwalker",
						"Felhunter",
						"Succubus",
						"Felguard",
					},
					width	= 100,
				},
			},
			{ 	name	= "AoE Selection",
			    tooltip = "Select between Hand of Gul'dan and Chaos Wave during the AoE rotation (Hand of Gul'dan during cleave/long lasting AoE | Chaos Wave during bursty AoE situations such as Lei Shen's ball lightnings).",
				enable	= true,
				newSection  = true,
				widget	= { type = "select",
					values	= {
						"Chaos Wave",
						"Hand of Gul'dan",
					},
					width	= 100,
				},
			},
		},
		hotkeys = {
			{	name	= "Dark Soul",
			    tooltip = "Select the keybind for the Dark Soul: Knowledge ability.",
				enable	= true,
				hotkeys	= {'ls'},
			},
			{	name	= "Toggle Hold Ability",
			    tooltip = "Select the keybind for the usage of holding AoE spells(Hand of Gul'dan/Chaos Wave/Grimoire of Service), good for fights such as Heroic Durumu's ice walls and Lei Shen's ball lightnings.",
				enable	= false,
				hotkeys	= {},
			},
			{	name	= "Toggle Hold Cooldown",
			    tooltip = "Select the keybind for the usage of holding cooldowns.",
				enable	= false,
				hotkeys	= {},
			},
		},
	}
	HYSTERIA_DEMO_DEF = PQI:AddRotation(Defensive)
	HYSTERIA_DEMO_OFF = PQI:AddRotation(Offensive)
	
	-- Abilities
	-- Affliction Specific
	PQ_Cor			= 172		-- Corruption
	PQ_AG			= 980		-- Agony
	PQ_DS			= 1120		-- Drain Soul
	PQ_UA			= 30108		-- Unstable Affliction
	PQ_Haunt		= 48181		-- Haunt
	PQ_SB			= 74434		-- Soulburn
	PQ_SS			= 86121		-- Soul Swap
	PQ_SSE			= 86213		-- Soul Swap: Exhale
	PQ_MG			= 103103	-- Malefic Grasp

	-- Demonology Specific
	PQ_Doom			= 603		-- Metamorphosis: Doom
	PQ_ShadowBolt	= 686		-- Shadow Bolt
	PQ_Hellfire		= 1949		-- Hellfire
	PQ_SoulFire		= 6353		-- Soul Fire
	PQ_Meta			= 103958	-- Metamorphosis
	PQ_ToC			= 103964	-- Metamorphosis: Touch of Chaos
	PQ_Swarm		= 103967	-- Carrion Swarm
	PQ_ImmoAura		= 104025	-- Metamorphosis: Immolation Aura
	PQ_GulDan		= 105174	-- Hand of Gul'dan
	PQ_ChaosWave	= 124916	-- Chaos Wave
	
	-- Available to all Specs
	PQ_DL			= 689		-- Drain Life
	PQ_HF			= 755		-- Health Funnel
	PQ_Soulstone	= 20707		-- Soulstone
	PQ_Shatter		= 29858		-- Soulshatter
	PQ_FelFlame		= 77799		-- Fel Flame
	
	-- Destruction
	PQ_IM			= 348		-- Immolate
	PQ_Shadowburn	= 17877		-- Shadowburn
	PQ_IN			= 29722		-- Incinerate
	PQ_CF			= 17962		-- Conflagrate
	PQ_Havoc		= 80240		-- Take a wild guess...
	PQ_RF			= 104232	-- Rain of Fire
	PQ_FB			= 108683	-- Fire and Brimstone
	PQ_CB			= 116858	-- Chaos Bolt
	
	-- Spec Cooldowns
	PQ_SIF			= 1122		-- Summon Infernal
	PQ_SDM			= 18540		-- Summon Doomguard
	PQ_UR			= 104773	-- Unending Resolve
	PQ_DSI			= 113858	-- Dark Soul: Instability
	PQ_DSM			= 113860	-- Dark Soul: Misery
	PQ_DSK			= 113861	-- Dark Soul: Knowledge
	PQ_SAY			= 112921	-- Summon Abyssal
	PQ_STG			= 112927	-- Summon Terrorguard
	
	-- Buffs
	PQ_ST			= 17941		-- Shadow Trance
	PQ_SSE2			= 86211		-- Soul Swap: Exhale
	PQ_DI			= 109773	-- Dark Intent
	PQ_MCore		= 122351	-- Molten Core
	PQ_BD			= 117896	-- Backdraft
	
	-- Hand of Gul'dan DoT component
	PQ_SFlame		= 47960		-- Shadowflame
	
	-- Magic Vulnerability Debuffs
	PQ_COTE			= 1490		-- Curse of the Elements
	PQ_MP			= 58410		-- Master Poisoner
	PQ_FB			= 34889		-- Fire Breath
	PQ_LB			= 24844		-- Lightning Breath
	PQ_AOTE			= 116202	-- Aura of the Elements
	
	-- Talents
	PQ_DR			= 108359	-- Dark Regeneration
	PQ_SL			= 108370	-- Soul Leech
	PQ_HL			= 108371	-- Harvest Life
	PQ_HOT			= 5484		-- Howl of Terror
	PQ_MC			= 6789		-- Mortal Coil
	PQ_SF			= 30283		-- Shadowfury
	PQ_Soul			= 108415	-- Soul Link
	PQ_SP			= 108416	-- Sacrificial Pact
	PQ_DB			= 110913	-- Dark Bargain
	PQ_BF			= 111397	-- Blood Fear
	PQ_BR			= 111400	-- Burning Rush
	PQ_UW			= 108482	-- Unbound Will
	PQ_Supremacy	= 108499	-- Grimoire of Supremacy
	PQ_Service		= 108501	-- Grimoire of Service
	PQ_Sacrifice	= 108503	-- Grimoire of Sacrifice
	PQ_AV			= 108505	-- Archimonde's Vengeance
	PQ_KC			= 137587	-- Kil'jaeden's Cunning
	PQ_MF			= 108508	-- Mannoroth's Fury
	
	-- Pets
	PQ_Imp			= 688		-- Summon Imp
	PQ_Voidwalker	= 697		-- Summon Voidwalker
	PQ_Succubus		= 712		-- Summon Succubus
	PQ_Felhunter	= 691		-- Summon Felhunter
	PQ_Felguard		= 30146		-- Summon Felguard
	
	-- Grimoire of Service Summons
	PQ_GImp			= 111859	-- Grimoire: Imp
	PQ_GVoidwalker	= 111895	-- Grimoire: Voidwalker
	PQ_GSuccubus	= 111896	-- Grimoire: Succubus
	PQ_GFelhunter	= 111897	-- Grimoire: Felhunter
	PQ_GFelguard	= 111898	-- Grimoire: Felguard
	
	Hysteria_Spell = {
		[PQ_AG]			= {check = true, known = IsPlayerSpell(PQ_AG)},
		[PQ_UA]			= {check = true, known = IsPlayerSpell(PQ_UA)},
		[PQ_MG]			= {check = true, known = IsPlayerSpell(PQ_MG)},
		[PQ_DS]			= {check = true, known = IsPlayerSpell(PQ_DS)},
		[PQ_SB]			= {check = true, known = IsPlayerSpell(PQ_SB)},
		[PQ_SS]			= {check = true, known = IsPlayerSpell(PQ_SS)},
		[PQ_DL]			= {check = true, known = IsPlayerSpell(PQ_DL)},
		[PQ_HF]			= {check = true, known = IsPlayerSpell(PQ_HF)},
		[PQ_UR]			= {check = true, known = IsPlayerSpell(PQ_UR)},
		[PQ_DR]			= {check = true, known = IsPlayerSpell(PQ_DR)},
		[PQ_SL]			= {check = true, known = IsPlayerSpell(PQ_SL)},
		[PQ_HL]			= {check = true, known = IsPlayerSpell(PQ_HL)},		
		[PQ_MC]			= {check = true, known = IsPlayerSpell(PQ_MC)},
		[PQ_SF]			= {check = true, known = IsPlayerSpell(PQ_SF)},
		[PQ_SP]			= {check = true, known = IsPlayerSpell(PQ_SP)},
		[PQ_DB]			= {check = true, known = IsPlayerSpell(PQ_DB)},
		[PQ_BF]			= {check = true, known = IsPlayerSpell(PQ_BF)},
		[PQ_BR]			= {check = true, known = IsPlayerSpell(PQ_BR)},
		[PQ_UW]			= {check = true, known = IsPlayerSpell(PQ_UW)},
		[PQ_AV]			= {check = true, known = IsPlayerSpell(PQ_AV)},
		[PQ_KC]			= {check = true, known = IsPlayerSpell(PQ_KC)},
		[PQ_MF]			= {check = true, known = IsPlayerSpell(PQ_MF)},
		[PQ_DI]			= {check = true, known = IsPlayerSpell(PQ_DI)},
		[PQ_ToC]		= {check = true, known = IsPlayerSpell(PQ_ToC)},
		[PQ_Cor]		= {check = true, known = IsPlayerSpell(PQ_Cor)},
		[PQ_HOT]		= {check = true, known = IsPlayerSpell(PQ_HOT)},
		[PQ_DSM]		= {check = true, known = IsPlayerSpell(PQ_DSM)},
		[PQ_SDM]		= {check = true, known = IsPlayerSpell(PQ_SDM)},
		[PQ_SIF]		= {check = true, known = IsPlayerSpell(PQ_SIF)},
		[PQ_COTE]		= {check = true, known = IsPlayerSpell(PQ_COTE)},
		[PQ_Meta]		= {check = true, known = IsPlayerSpell(PQ_Meta)},
		[PQ_Doom]		= {check = true, known = IsPlayerSpell(PQ_Doom)},
		[PQ_Soul]		= {check = true, known = IsPlayerSpell(PQ_Soul)},
		[PQ_Haunt]		= {check = true, known = IsPlayerSpell(PQ_Haunt)},
		[PQ_GulDan]		= {check = true, known = IsPlayerSpell(PQ_GulDan)},
		[PQ_Service]	= {check = true, known = IsPlayerSpell(PQ_Service)},
		[PQ_Shatter]	= {check = true, known = IsPlayerSpell(PQ_Shatter)},
		[PQ_Hellfire]	= {check = true, known = IsPlayerSpell(PQ_Hellfire)},
		[PQ_FelFlame]	= {check = true, known = IsPlayerSpell(PQ_FelFlame)},
		[PQ_SoulFire]	= {check = true, known = IsPlayerSpell(PQ_SoulFire)},
		[PQ_Supremacy]	= {check = true, known = IsPlayerSpell(PQ_Supremacy)},
		[PQ_Sacrifice]	= {check = true, known = IsPlayerSpell(PQ_Sacrifice)},
		[PQ_ShadowBolt]	= {check = true, known = IsPlayerSpell(PQ_ShadowBolt)}
	}
end