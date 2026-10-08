-- RDF_Info access tables for WotLK 3.3.5a
-- Sourced from AzerothCore dungeon_access_template / dungeon_access_requirements
-- and LFGMgr::InitializeLockedDungeons. Keyed by map + instance difficulty.

RDFInfoAccess = RDFInfoAccess or {}

local Access = RDFInfoAccess

-- LFG dungeon ID -> { mapId, difficulty } from LFGDungeons.dbc 3.3.5
Access.lfg = {
	-- Classic dungeons / raids
	[1] = {43, 0}, [4] = {389, 0}, [6] = {36, 0}, [8] = {33, 0}, [10] = {48, 0},
	[12] = {34, 0}, [14] = {90, 0}, [16] = {47, 0}, [20] = {129, 0}, [22] = {70, 0},
	[24] = {209, 0}, [26] = {349, 0}, [28] = {109, 0}, [30] = {230, 0}, [32] = {229, 0},
	[34] = {429, 0}, [36] = {429, 0}, [38] = {429, 0}, [40] = {329, 0},
	[46] = {249, 0}, [48] = {409, 0}, [50] = {469, 0},
	[159] = {533, 0}, [160] = {509, 0}, [161] = {531, 0},
	[272] = {349, 0}, [273] = {349, 0}, [274] = {329, 0}, [276] = {230, 0},
	-- TBC
	[136] = {543, 0}, [137] = {542, 0}, [138] = {540, 0},
	[140] = {547, 0}, [146] = {546, 0}, [147] = {545, 0},
	[148] = {557, 0}, [149] = {558, 0}, [150] = {556, 0}, [151] = {555, 0},
	[170] = {560, 0}, [171] = {269, 0},
	[172] = {554, 0}, [173] = {553, 0}, [174] = {552, 0},
	[175] = {532, 0}, [176] = {544, 0}, [177] = {565, 0},
	[178] = {558, 1}, [179] = {557, 1}, [180] = {556, 1}, [181] = {555, 1},
	[182] = {269, 1}, [183] = {560, 1},
	[184] = {547, 1}, [185] = {545, 1}, [186] = {546, 1},
	[187] = {542, 1}, [188] = {543, 1}, [189] = {540, 1},
	[190] = {552, 1}, [191] = {553, 1}, [192] = {554, 1},
	[193] = {550, 0}, [194] = {548, 0}, [195] = {534, 0}, [196] = {564, 0},
	[198] = {585, 0}, [199] = {580, 0}, [201] = {585, 1},
	-- WotLK 5-man
	[202] = {574, 0}, [242] = {574, 1},
	[203] = {575, 0}, [205] = {575, 1},
	[204] = {601, 0}, [241] = {601, 1},
	[206] = {578, 0}, [211] = {578, 1},
	[207] = {602, 0}, [212] = {602, 1},
	[208] = {599, 0}, [213] = {599, 1},
	[209] = {595, 0}, [210] = {595, 1},
	[214] = {600, 0}, [215] = {600, 1},
	[216] = {604, 0}, [217] = {604, 1},
	[218] = {619, 0}, [219] = {619, 1},
	[220] = {608, 0}, [221] = {608, 1},
	[225] = {576, 0}, [226] = {576, 1},
	[245] = {650, 0}, [249] = {650, 1},
	[251] = {632, 0}, [252] = {632, 1},
	[253] = {658, 0}, [254] = {658, 1},
	[255] = {668, 0}, [256] = {668, 1},
	-- WotLK raids
	[223] = {616, 0}, [237] = {616, 1},
	[224] = {615, 0}, [238] = {615, 1},
	[227] = {533, 1},
	[239] = {624, 0}, [240] = {624, 1},
	[243] = {603, 0}, [244] = {603, 1},
	[246] = {649, 0}, [247] = {649, 2}, [248] = {649, 1}, [250] = {649, 3},
	[257] = {249, 1},
	[279] = {631, 0}, [280] = {631, 1},
	[293] = {724, 0}, [294] = {724, 1},
	-- Holiday RDF
	[285] = {189, 0}, [286] = {547, 0}, [287] = {230, 0}, [288] = {33, 0},
}

-- Normalized GetLFGDungeonInfo name -> map (fallback when LFG id is missing)
Access.names = {
	["wailing caverns"] = 43,
	["ragefire chasm"] = 389,
	["deadmines"] = 36,
	["the deadmines"] = 36,
	["shadowfang keep"] = 33,
	["blackfathom deeps"] = 48,
	["stormwind stockade"] = 34,
	["the stockade"] = 34,
	["gnomeregan"] = 90,
	["razorfen kraul"] = 47,
	["razorfen downs"] = 129,
	["uldaman"] = 70,
	["zul'farrak"] = 209,
	["maraudon"] = 349,
	["maraudon - foulspore cavern"] = 349,
	["maraudon - the wicked grotto"] = 349,
	["maraudon - earth song falls"] = 349,
	["sunken temple"] = 109,
	["the temple of atal'hakkar"] = 109,
	["blackrock depths"] = 230,
	["blackrock depths - detention block"] = 230,
	["blackrock depths - upper city"] = 230,
	["lower blackrock spire"] = 229,
	["upper blackrock spire"] = 229,
	["blackrock spire"] = 229,
	["dire maul"] = 429,
	["dire maul - warpwood quarter"] = 429,
	["dire maul - capital gardens"] = 429,
	["dire maul - gordok commons"] = 429,
	["stratholme"] = 329,
	["stratholme - main gate"] = 329,
	["stratholme - service entrance"] = 329,
	["scarlet monastery"] = 189,
	["scholomance"] = 289,
	["zul'gurub"] = 309,
	["onyxia's lair"] = 249,
	["molten core"] = 409,
	["blackwing lair"] = 469,
	["ruins of ahn'qiraj"] = 509,
	["ahn'qiraj ruins"] = 509,
	["ahn'qiraj temple"] = 531,
	["temple of ahn'qiraj"] = 531,
	["naxxramas"] = 533,
	["karazhan"] = 532,
	["magtheridon's lair"] = 544,
	["gruul's lair"] = 565,
	["hellfire ramparts"] = 543,
	["the blood furnace"] = 542,
	["blood furnace"] = 542,
	["the shattered halls"] = 540,
	["shattered halls"] = 540,
	["the slave pens"] = 547,
	["slave pens"] = 547,
	["the underbog"] = 546,
	["underbog"] = 546,
	["the steamvault"] = 545,
	["serpentshrine cavern"] = 548,
	["mana-tombs"] = 557,
	["auchenai crypts"] = 558,
	["sethekk halls"] = 556,
	["shadow labyrinth"] = 555,
	["old hillsbrad foothills"] = 560,
	["the escape from durnholde"] = 560,
	["the black morass"] = 269,
	["opening of the dark portal"] = 269,
	["the mechanar"] = 554,
	["the botanica"] = 553,
	["the arcatraz"] = 552,
	["tempest keep"] = 550,
	["the eye"] = 550,
	["hyjal summit"] = 534,
	["hyjal past"] = 534,
	["the battle for mount hyjal"] = 534,
	["black temple"] = 564,
	["zul'aman"] = 568,
	["magisters' terrace"] = 585,
	["the sunwell"] = 580,
	["sunwell plateau"] = 580,
	["utgarde keep"] = 574,
	["utgarde pinnacle"] = 575,
	["azjol-nerub"] = 601,
	["ahn'kahet: the old kingdom"] = 619,
	["ahn'kahet"] = 619,
	["the nexus"] = 576,
	["the oculus"] = 578,
	["halls of lightning"] = 602,
	["halls of stone"] = 599,
	["the culling of stratholme"] = 595,
	["culling of stratholme"] = 595,
	["drak'tharon keep"] = 600,
	["gundrak"] = 604,
	["violet hold"] = 608,
	["the violet hold"] = 608,
	["the eye of eternity"] = 616,
	["the obsidian sanctum"] = 615,
	["vault of archavon"] = 624,
	["ulduar"] = 603,
	["trial of the champion"] = 650,
	["trial of the crusader"] = 649,
	["trial of the grand crusader"] = 649,
	["the forge of souls"] = 632,
	["forge of souls"] = 632,
	["pit of saron"] = 658,
	["halls of reflection"] = 668,
	["icecrown citadel"] = 631,
	["the ruby sanctum"] = 724,
	["ruby sanctum"] = 724,
	["the headless horseman"] = 189,
	["the frost lord ahune"] = 547,
	["coren direbrew"] = 230,
	["the crown chemical co."] = 33,
}

Access.itemNames = {
	[30622] = "Flamewrought Key",
	[30637] = "Flamewrought Key",
	[30623] = "Reservoir Key",
	[30633] = "Auchenai Key",
	[30634] = "Warpforged Key",
	[30635] = "Key of Time",
}

Access.questNames = {
	[10285] = "Return to Andormu",
	[10277] = "The Caverns of Time",
	[11492] = "Hard to Kill",
	[24499] = "Echoes of Tortured Souls",
	[24511] = "Echoes of Tortured Souls",
	[24710] = "Deliverance from the Pit",
	[24712] = "Deliverance from the Pit",
	[13188] = "Where Kings Walk",
	[13189] = "Warchief's Blessing",
}

-- Death Knight RDF gate in LFGMgr::InitializeLockedDungeons
Access.dkQuests = {
	alliance = { id = 13188, name = "Where Kings Walk" },
	horde = { id = 13189, name = "Warchief's Blessing" },
}

local byMap = {}
Access.byMap = byMap

local function Slot(mapId, diff)
	if not byMap[mapId] then
		byMap[mapId] = {}
	end
	if not byMap[mapId][diff] then
		byMap[mapId][diff] = { ilvl = 0, items = {}, quests = {}, ach = {} }
	end
	return byMap[mapId][diff]
end

local function Ilvl(mapId, diff, ilvl)
	Slot(mapId, diff).ilvl = ilvl
end

local function Item(mapId, diff, id, faction, leader)
	local t = Slot(mapId, diff)
	t.items[#t.items + 1] = { id = id, faction = faction or 2, leader = leader and true or false }
end

local function Quest(mapId, diff, id, faction, leader, note)
	local t = Slot(mapId, diff)
	t.quests[#t.quests + 1] = { id = id, faction = faction or 2, leader = leader and true or false, note = note }
end

local function Ach(mapId, diff, id, faction, leader)
	local t = Slot(mapId, diff)
	t.ach[#t.ach + 1] = { id = id, faction = faction or 2, leader = leader and true or false }
end

-- WotLK heroic 5-man item level (dungeon_access_template.min_avg_item_level)
Ilvl(574, 1, 180) -- Utgarde Keep H
Ilvl(575, 1, 180) -- Utgarde Pinnacle H
Ilvl(576, 1, 180) -- Nexus H
Ilvl(578, 1, 180) -- Oculus H
Ilvl(595, 1, 180) -- Culling H
Ilvl(599, 1, 180) -- Halls of Stone H
Ilvl(600, 1, 180) -- Drak'Tharon H
Ilvl(601, 1, 180) -- Azjol-Nerub H
Ilvl(602, 1, 180) -- Halls of Lightning H
Ilvl(604, 1, 180) -- Gundrak H
Ilvl(608, 1, 180) -- Violet Hold H
Ilvl(619, 1, 180) -- Ahn'kahet H
Ilvl(632, 0, 180) -- Forge of Souls N
Ilvl(632, 1, 200) -- Forge of Souls H
Ilvl(650, 0, 180) -- Trial of the Champion N
Ilvl(650, 1, 200) -- Trial of the Champion H
Ilvl(658, 0, 180) -- Pit of Saron N
Ilvl(658, 1, 200) -- Pit of Saron H
Ilvl(668, 0, 180) -- Halls of Reflection N
Ilvl(668, 1, 219) -- Halls of Reflection H

-- Caverns of Time
Quest(269, 0, 10285, 2, false, "You must complete the quest \"Return to Andormu\" before entering the Black Morass.")
Quest(269, 1, 10285, 2, true, "You must complete the quest \"Return to Andormu\" and be level 70 before entering the Heroic difficulty of the Black Morass.")
Item(269, 1, 30635, 2, false)
Quest(560, 0, 10277, 2, false, "You must complete the quest \"The Caverns of Time\" before entering Old Hillsbrad Foothills.")
Quest(560, 1, 10277, 2, false, "You must complete the quest \"The Caverns of Time\" and be level 70 before entering the Heroic difficulty of Old Hillsbrad Foothills.")
Item(560, 1, 30635, 2, false)

-- TBC heroic keys
Item(540, 1, 30622, 0, false) -- Shattered Halls, Alliance
Item(540, 1, 30637, 1, false) -- Horde
Item(542, 1, 30622, 0, false)
Item(542, 1, 30637, 1, false)
Item(543, 1, 30622, 0, false)
Item(543, 1, 30637, 1, false)
Item(545, 1, 30623, 2, false) -- Steamvault
Item(546, 1, 30623, 2, false)
Item(547, 1, 30623, 2, false)
Item(552, 1, 30634, 2, false) -- Arcatraz
Item(553, 1, 30634, 2, false)
Item(554, 1, 30634, 2, false)
Item(555, 1, 30633, 2, false) -- Shadow Labyrinth
Item(556, 1, 30633, 2, false)
Item(557, 1, 30633, 2, false)
Item(558, 1, 30633, 2, false)

-- Magisters' Terrace heroic
Quest(585, 1, 11492, 2, false, "You must complete the quest \"Hard to Kill\" and be level 70 before entering the Heroic difficulty of the Magisters' Terrace.")

-- Frozen Halls attune chain
Quest(658, 0, 24499, 0, false, "You must complete the quest \"Echoes of Tortured Souls\" before entering the Pit of Saron.")
Quest(658, 0, 24511, 1, false, "You must complete the quest \"Echoes of Tortured Souls\" before entering the Pit of Saron.")
Quest(658, 1, 24499, 0, false, "You must complete the quest \"Echoes of Tortured Souls\" and be level 80 before entering the Heroic difficulty of the Pit of Saron.")
Quest(658, 1, 24511, 1, false, "You must complete the quest \"Echoes of Tortured Souls\" and be level 80 before entering the Heroic difficulty of the Pit of Saron.")
Quest(668, 0, 24710, 0, false, "You must complete the quest \"Deliverance from the Pit\" before entering the Halls of Reflection.")
Quest(668, 0, 24712, 1, false, "You must complete the quest \"Deliverance from the Pit\" before entering the Halls of Reflection.")
Quest(668, 1, 24710, 0, false, "You must complete the quest \"Deliverance from the Pit\" and be level 80 before entering the Heroic difficulty of the Halls of Reflection.")
Quest(668, 1, 24712, 1, false, "You must complete the quest \"Deliverance from the Pit\" and be level 80 before entering the Heroic difficulty of the Halls of Reflection.")

-- Raid heroic achievements
Ach(631, 2, 4530, 2, false) -- ICC 10H: Heroic: Storming the Citadel (10)
Ach(631, 3, 4597, 2, false) -- ICC 25H
Ach(649, 2, 3917, 2, false) -- ToGC 10
Ach(649, 3, 3916, 2, false) -- ToGC 25
