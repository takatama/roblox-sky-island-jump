local Leaderboard = {}

local COIN_KEY_NAME = "Coins"
local JUMP_KEY_NAME = "Jump"

local function getOrCreateLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if leaderstats == nil then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	return leaderstats
end

local function getOrCreateStat(player, statName)
	local leaderstats = getOrCreateLeaderstats(player)
	local stat = leaderstats:FindFirstChild(statName)

	if stat == nil then
		stat = Instance.new("IntValue")
		stat.Name = statName
		stat.Parent = leaderstats
	end

	return stat
end

function Leaderboard.setStat(player, statName, value)
	local stat = getOrCreateStat(player, statName)
	stat.Value = value
end

function Leaderboard.resetStats(player)
	Leaderboard.setStat(player, COIN_KEY_NAME, 0)
	Leaderboard.setStat(player, JUMP_KEY_NAME, 0)
end

return Leaderboard
