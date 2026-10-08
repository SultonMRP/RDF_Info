-- RDF Info for WotLK 3.3.5a
-- Cursor tooltip on Dungeon Finder / Raid Browser padlocks.
-- Server lock packets only send a reason code (no quest/item/ilvl). This addon
-- fills in AzerothCore dungeon_access_* requirements.

local PREFIX = "|cff33ccffRDF Info|r"
local Access = RDFInfoAccess

local completedQuests = {}
local hookedButtons = {}

local LOCK_REASON = {
	[1] = "You do not have the required expansion.",
	[2] = "Your level is too low.",
	[3] = "Your level is too high.",
	[4] = "Your average item level is too low.",
	[5] = "Your average item level is too high.",
	[6] = "You are already locked to this instance, or it is disabled.",
	[1001] = "Your level is too low for attunement.",
	[1002] = "Your level is too high for attunement.",
	[1022] = "You have not completed a required quest.",
	[1025] = "You are missing a required item.",
	[1031] = "This seasonal dungeon is not available right now.",
	[1034] = "You are missing a required achievement.",
}

local EXPANSION_NAME = {
	[0] = "Classic",
	[1] = "The Burning Crusade",
	[2] = "Wrath of the Lich King",
}

-- C++ EQUIPMENT_SLOT skips shirt, off-hand, ranged, tabard. Empty slots still count.
local ILVL_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. ": " .. msg)
end

local function IsHeader(id)
	if type(LFGIsIDHeader) == "function" then
		return LFGIsIDHeader(id)
	end
	return (tonumber(id) or 0) < 0
end

local function NormalizeName(name)
	if not name then
		return ""
	end
	name = string.lower(name)
	name = string.gsub(name, " %(heroic%)$", "")
	name = string.gsub(name, " %(10 player%)$", "")
	name = string.gsub(name, " %(25 player%)$", "")
	name = string.gsub(name, " %(10 player, heroic%)$", "")
	name = string.gsub(name, " %(25 player, heroic%)$", "")
	return name
end

local function PlayerFaction()
	local group = UnitFactionGroup("player")
	if group == "Alliance" then
		return 0
	end
	if group == "Horde" then
		return 1
	end
	return 2
end

local function MatchesFaction(reqFaction)
	if not reqFaction or reqFaction == 2 then
		return true
	end
	return reqFaction == PlayerFaction()
end

local function HasQuest(questId)
	if completedQuests[questId] then
		return true
	end
	if type(IsQuestFlaggedCompleted) == "function" then
		return IsQuestFlaggedCompleted(questId) and true or false
	end
	return false
end

local function HasItem(itemId)
	if type(GetItemCount) ~= "function" then
		return false
	end
	return (GetItemCount(itemId) or 0) > 0
end

local function AchievementName(id)
	if type(GetAchievementInfo) == "function" then
		local _, name, _, completed = GetAchievementInfo(id)
		return name, completed and true or false
	end
	return "Achievement " .. tostring(id), false
end

local function ItemName(id)
	if type(GetItemInfo) == "function" then
		local name = GetItemInfo(id)
		if name then
			return name
		end
	end
	return (Access.itemNames and Access.itemNames[id]) or ("item " .. tostring(id))
end

local function QuestName(id)
	return (Access.questNames and Access.questNames[id]) or ("quest " .. tostring(id))
end

local function PlayerIlvl()
	local sum, count = 0, 0
	local level = UnitLevel("player") or 1
	for i = 1, #ILVL_SLOTS do
		local slot = ILVL_SLOTS[i]
		count = count + 1
		local link = GetInventoryItemLink("player", slot)
		if link and type(GetItemInfo) == "function" then
			local _, _, quality, ilvl = GetItemInfo(link)
			if quality == 7 then
				sum = sum + level * 2.33
			elseif ilvl then
				sum = sum + ilvl
			end
		end
	end
	if count == 0 then
		return 0
	end
	return sum / count
end

local function GetDungeonFields(dungeonID)
	if type(GetLFGDungeonInfo) ~= "function" or not dungeonID or IsHeader(dungeonID) then
		return nil
	end
	local name, typeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansion, groupID, texture, difficulty, maxPlayers, description, isHoliday = GetLFGDungeonInfo(dungeonID)
	if not name then
		return nil
	end
	return {
		name = name,
		typeID = typeID,
		minLevel = minLevel,
		maxLevel = maxLevel,
		recLevel = recLevel,
		expansion = expansion,
		groupID = groupID,
		difficulty = difficulty or 0,
		maxPlayers = maxPlayers,
		isHoliday = isHoliday,
	}
end

local function ResolveMapDiff(dungeonID, info)
	local pair = Access.lfg and Access.lfg[dungeonID]
	if pair then
		return pair[1], pair[2]
	end
	if not info then
		return nil
	end
	local mapId = Access.names and Access.names[NormalizeName(info.name)]
	if mapId then
		return mapId, info.difficulty or 0
	end
	return nil
end

local function GetAccess(dungeonID, info)
	local mapId, diff = ResolveMapDiff(dungeonID, info)
	if not mapId then
		return nil, nil, nil
	end
	local byDiff = Access.byMap and Access.byMap[mapId]
	return (byDiff and byDiff[diff]) or nil, mapId, diff
end

local function FindSavedReset(info)
	if not info or type(GetNumSavedInstances) ~= "function" then
		return nil
	end
	local want = NormalizeName(info.name)
	local isHeroicFive = (info.maxPlayers == 5 and (info.difficulty or 0) > 0)
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, _, _, _, maxPlayers, difficultyName = GetSavedInstanceInfo(i)
		if locked and NormalizeName(name) == want then
			local savedHeroic = difficultyName and string.find(string.lower(difficultyName), "heroic")
			if info.maxPlayers == 5 then
				if (isHeroicFive and savedHeroic) or (not isHeroicFive and not savedHeroic) then
					return reset
				end
			elseif not maxPlayers or maxPlayers == info.maxPlayers then
				local wantHeroic = (info.difficulty or 0) >= 2
				if (wantHeroic and savedHeroic) or (not wantHeroic and not savedHeroic) or (info.difficulty == 1 and maxPlayers == 25) then
					return reset
				end
			end
		end
	end
	return nil
end

local function FormatReset(sec)
	if not sec or sec <= 0 then
		return "soon"
	end
	if type(SecondsToTime) == "function" then
		return SecondsToTime(sec)
	end
	local d = math.floor(sec / 86400)
	local h = math.floor((sec % 86400) / 3600)
	if d > 0 then
		return d .. "d " .. h .. "h"
	end
	return h .. "h"
end

local function AddNeed(tooltip, ok, text)
	if ok then
		tooltip:AddLine("|cff20ff20Met:|r " .. text, 1, 1, 1, true)
	else
		tooltip:AddLine("|cffff3030Need:|r " .. text, 1, 1, 1, true)
	end
end

local function CollectLockReasons(dungeonID)
	local rows = {}
	if type(GetLFDLockPlayerCount) ~= "function" or type(GetLFDLockInfo) ~= "function" then
		return rows
	end
	local n = GetLFDLockPlayerCount() or 0
	for i = 1, n do
		local playerName, lockedReason, subReason1, subReason2 = GetLFDLockInfo(dungeonID, i)
		if lockedReason and lockedReason ~= 0 then
			rows[#rows + 1] = {
				name = playerName,
				reason = lockedReason,
				sub1 = subReason1,
				sub2 = subReason2,
				self = (i == 1),
			}
		end
	end
	return rows
end

local function ReasonText(code)
	return LOCK_REASON[code] or ("You do not meet the requirements (lock " .. tostring(code) .. ").")
end

local function IsDK()
	local _, classFile = UnitClass("player")
	return classFile == "DEATHKNIGHT"
end

local function DKQuest()
	if PlayerFaction() == 0 then
		return Access.dkQuests.alliance
	end
	return Access.dkQuests.horde
end

local function FillRequirements(tooltip, dungeonID, info)
	tooltip:AddLine(" ")
	tooltip:AddLine("Required to enter", 1, 0.82, 0)

	if info then
		local level = UnitLevel("player") or 0
		if info.minLevel and info.minLevel > 0 then
			local maxLevel = info.maxLevel or 0
			local range
			if maxLevel > 0 and maxLevel ~= info.minLevel then
				range = "Level " .. info.minLevel .. "–" .. maxLevel
			else
				range = "Level " .. info.minLevel
			end
			local ok = level >= info.minLevel and (maxLevel == 0 or level <= maxLevel)
			AddNeed(tooltip, ok, range .. " (you are " .. level .. ")")
		end
		if info.expansion and EXPANSION_NAME[info.expansion] then
			local have = (type(GetExpansionLevel) == "function" and GetExpansionLevel()) or 2
			AddNeed(tooltip, have >= info.expansion, "Expansion: " .. EXPANSION_NAME[info.expansion])
		end
		if info.isHoliday then
			tooltip:AddLine("Holiday dungeon — only while the event is active.", 0.8, 0.8, 0.8, true)
		end
	end

	if IsDK() then
		local dk = DKQuest()
		AddNeed(tooltip, HasQuest(dk.id), "Death Knight: complete \"" .. dk.name .. "\" (quest " .. dk.id .. ")")
	end

	local req = GetAccess(dungeonID, info)
	if req then
		if req.ilvl and req.ilvl > 0 then
			local mine = PlayerIlvl()
			local ok = mine + 0.01 >= req.ilvl
			AddNeed(tooltip, ok, string.format("Average item level %d (yours: %d)", req.ilvl, math.floor(mine + 0.5)))
		end
		for i = 1, #req.items do
			local it = req.items[i]
			if MatchesFaction(it.faction) then
				local label = ItemName(it.id)
				if it.leader then
					label = label .. " (party leader)"
				end
				AddNeed(tooltip, HasItem(it.id), "Item: " .. label)
			end
		end
		for i = 1, #req.quests do
			local q = req.quests[i]
			if MatchesFaction(q.faction) then
				local label = q.note
				if not label or label == "" then
					label = "Complete \"" .. QuestName(q.id) .. "\""
				end
				if q.leader then
					label = label .. " (party leader)"
				end
				AddNeed(tooltip, HasQuest(q.id), label)
			end
		end
		for i = 1, #req.ach do
			local a = req.ach[i]
			if MatchesFaction(a.faction) then
				local name, done = AchievementName(a.id)
				local label = "Achievement: " .. (name or a.id)
				if a.leader then
					label = label .. " (party leader)"
				end
				AddNeed(tooltip, done, label)
			end
		end
	end

	if info then
		local reset = FindSavedReset(info)
		if reset then
			tooltip:AddLine("|cffff3030Saved:|r locked to this instance (resets in " .. FormatReset(reset) .. ").", 1, 1, 1, true)
		end
	end
end

local function ShowLockTooltip(owner, dungeonID)
	if not dungeonID then
		return
	end

	GameTooltip:SetOwner(owner, "ANCHOR_CURSOR")
	GameTooltip:ClearLines()

	local info = GetDungeonFields(dungeonID)
	local title = (info and info.name) or "Locked dungeon"
	if IsHeader(dungeonID) then
		title = (info and info.name) or "Locked category"
	end
	GameTooltip:AddLine(title, 1, 0.82, 0)

	if IsHeader(dungeonID) then
		GameTooltip:AddLine("Every entry in this category is locked.", 1, 0.2, 0.2, true)
		GameTooltip:AddLine("Expand it and hover a padlock for the exact requirement.", 0.8, 0.8, 0.8, true)
		GameTooltip:Show()
		return
	end

	local reasons = CollectLockReasons(dungeonID)
	if #reasons > 0 then
		GameTooltip:AddLine("Why you cannot queue", 1, 0.2, 0.2)
		for i = 1, #reasons do
			local row = reasons[i]
			local line = ReasonText(row.reason)
			if not row.self and row.name and row.name ~= "" then
				line = row.name .. ": " .. line
			end
			GameTooltip:AddLine(line, 1, 1, 1, true)
		end
	else
		GameTooltip:AddLine("This dungeon is locked.", 1, 0.2, 0.2)
	end

	FillRequirements(GameTooltip, dungeonID, info)
	GameTooltip:Show()
end

local function ButtonIsLocked(button)
	if not button then
		return false
	end
	if button.lockedIndicator and button.lockedIndicator.IsShown and button.lockedIndicator:IsShown() then
		return true
	end
	local lockTex = button.lockedIndicator or (button.GetName and _G[button:GetName() .. "LockedIndicator"])
	if lockTex and lockTex.IsShown and lockTex:IsShown() then
		return true
	end
	if button.id and LFGLockList and LFGLockList[button.id] then
		return true
	end
	return false
end

local function OnListButtonEnter(self)
	if not self or not ButtonIsLocked(self) then
		return
	end
	ShowLockTooltip(self, self.id)
end

local function OnListButtonLeave()
	GameTooltip:Hide()
end

local function HookListButton(button)
	if not button or hookedButtons[button] then
		return
	end
	hookedButtons[button] = true
	button:HookScript("OnEnter", OnListButtonEnter)
	button:HookScript("OnLeave", OnListButtonLeave)
end

local function HookButtonRange(prefix, count)
	for i = 1, count do
		HookListButton(_G[prefix .. i])
	end
end

local function HookFinderButtons()
	HookButtonRange("LFDQueueFrameSpecificListButton", NUM_LFD_CHOICE_BUTTONS or 15)
	HookButtonRange("LFRQueueFrameSpecificListButton", NUM_LFR_CHOICE_BUTTONS or 14)
end

local function BuildDeclinedMessage(dungeonID)
	local parts = {}
	local reasons = CollectLockReasons(dungeonID)
	for i = 1, #reasons do
		local row = reasons[i]
		local line = ReasonText(row.reason)
		if not row.self and row.name and row.name ~= "" then
			line = row.name .. ": " .. line
		end
		parts[#parts + 1] = line
	end
	local info = GetDungeonFields(dungeonID)
	if info and info.minLevel then
		parts[#parts + 1] = "Requires level " .. info.minLevel
	end
	local req = GetAccess(dungeonID, info)
	if req then
		if req.ilvl and req.ilvl > 0 then
			parts[#parts + 1] = "Requires item level " .. req.ilvl
		end
		for i = 1, #req.quests do
			local q = req.quests[i]
			if MatchesFaction(q.faction) and not HasQuest(q.id) then
				parts[#parts + 1] = q.note or ("Quest: " .. QuestName(q.id))
			end
		end
		for i = 1, #req.items do
			local it = req.items[i]
			if MatchesFaction(it.faction) and not HasItem(it.id) then
				parts[#parts + 1] = "Missing " .. ItemName(it.id)
			end
		end
		for i = 1, #req.ach do
			local a = req.ach[i]
			if MatchesFaction(a.faction) then
				local name, done = AchievementName(a.id)
				if not done then
					parts[#parts + 1] = "Missing achievement: " .. (name or a.id)
				end
			end
		end
	end
	if IsDK() then
		local dk = DKQuest()
		if not HasQuest(dk.id) then
			parts[#parts + 1] = "Death Knight: complete \"" .. dk.name .. "\""
		end
	end
	if #parts == 0 then
		return YOU_MAY_NOT_QUEUE_FOR_THIS or "You may not queue for this."
	end
	return table.concat(parts, "\n")
end

local function RefreshQuestCache()
	if type(QueryQuestsCompleted) == "function" then
		QueryQuestsCompleted()
	end
end

local function WrapStockTooltip()
	if type(LFDQueueFrameDungeonListButton_OnEnter) == "function" then
		LFDQueueFrameDungeonListButton_OnEnter = function(self)
			OnListButtonEnter(self)
		end
	end
	if type(LFDConstructDeclinedMessage) == "function" then
		LFDConstructDeclinedMessage = BuildDeclinedMessage
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("QUEST_QUERY_COMPLETE")
eventFrame:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
eventFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		WrapStockTooltip()
		HookFinderButtons()
		RefreshQuestCache()
		if LFDParentFrame then
			LFDParentFrame:HookScript("OnShow", function()
				HookFinderButtons()
				RefreshQuestCache()
			end)
		end
		if LFRParentFrame then
			LFRParentFrame:HookScript("OnShow", function()
				HookFinderButtons()
				RefreshQuestCache()
			end)
		end
	elseif event == "QUEST_QUERY_COMPLETE" then
		if type(GetQuestsCompleted) == "function" then
			completedQuests = GetQuestsCompleted() or {}
		end
	elseif event == "LFG_LOCK_INFO_RECEIVED" then
		HookFinderButtons()
	end
end)

SLASH_RDFINFO1 = "/rdf"
SLASH_RDFINFO2 = "/rdfinfo"
SlashCmdList.RDFINFO = function()
	Print("Hover a padlock in Dungeon Finder or Raid Browser. The tooltip at the cursor lists why it's locked and what you need to enter.")
end
