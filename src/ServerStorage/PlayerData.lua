local PlayerData = {}

PlayerData.COIN_KEY_NAME = "Coins"
PlayerData.JUMP_KEY_NAME = "Jump"

local playerDataByUserId = {}

local function getPlayerKey(player)
	return tostring(player.UserId)
end

local function defaultPlayerData()
	return {
		[PlayerData.COIN_KEY_NAME] = 0,
		[PlayerData.JUMP_KEY_NAME] = 0,
	}
end

local function getPlayerData(player)
	local playerKey = getPlayerKey(player)

	if playerDataByUserId[playerKey] == nil then
		playerDataByUserId[playerKey] = defaultPlayerData()
	end

	return playerDataByUserId[playerKey]
end

function PlayerData.defaultPlayerData()
	return defaultPlayerData()
end

function PlayerData.getValue(player, key)
	local playerData = getPlayerData(player)
	return playerData[key]
end

function PlayerData.updateValue(player, key, updateFunction)
	local playerData = getPlayerData(player)
	local oldValue = playerData[key] or 0
	local newValue = updateFunction(oldValue)

	playerData[key] = newValue

	return newValue
end

function PlayerData.removePlayer(player)
	playerDataByUserId[getPlayerKey(player)] = nil
end

return PlayerData
