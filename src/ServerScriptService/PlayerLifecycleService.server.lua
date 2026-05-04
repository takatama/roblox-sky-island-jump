local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local PlayerData = require(ServerStorage:WaitForChild("PlayerData"))
local Leaderboard = require(ServerStorage:WaitForChild("Leaderboard"))
local JumpConfig = require(ServerStorage:WaitForChild("JumpConfig"))

local function setHumanoidJumpPower(humanoid, jumpPower)
	pcall(function()
		humanoid.UseJumpPower = true
	end)

	humanoid.JumpPower = jumpPower
end

local function setPlayerValue(player, key, value)
	PlayerData.updateValue(player, key, function()
		return value
	end)
end

local function resetPlayerProgress(player)
	setPlayerValue(player, PlayerData.COIN_KEY_NAME, 0)
	setPlayerValue(player, PlayerData.JUMP_KEY_NAME, JumpConfig.INITIAL_JUMP_POWER)
	Leaderboard.resetStats(player)
end

local function syncLeaderboard(player)
	Leaderboard.setStat(player, PlayerData.COIN_KEY_NAME, PlayerData.getValue(player, PlayerData.COIN_KEY_NAME) or 0)
	Leaderboard.setStat(player, PlayerData.JUMP_KEY_NAME, PlayerData.getValue(player, PlayerData.JUMP_KEY_NAME) or 0)
end

local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local jump = PlayerData.getValue(player, PlayerData.JUMP_KEY_NAME) or JumpConfig.INITIAL_JUMP_POWER

	setHumanoidJumpPower(humanoid, jump)

	humanoid.Died:Connect(function()
		resetPlayerProgress(player)
	end)
end

local function onPlayerAdded(player)
	resetPlayerProgress(player)
	syncLeaderboard(player)

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	PlayerData.removePlayer(player)
end)

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
