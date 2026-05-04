local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local PlayerData = require(ServerStorage:WaitForChild("PlayerData"))
local Leaderboard = require(ServerStorage:WaitForChild("Leaderboard"))
local JumpConfig = require(ServerStorage:WaitForChild("JumpConfig"))
local EffectService = require(ServerStorage:WaitForChild("EffectService"))

local world = Workspace:FindFirstChild("World")
local coinsFolder = if world then world:FindFirstChild("Coins") else nil
local coinCollectedEvent = ReplicatedStorage:FindFirstChild("CoinCollected")

if coinCollectedEvent == nil then
	coinCollectedEvent = Instance.new("RemoteEvent")
	coinCollectedEvent.Name = "CoinCollected"
	coinCollectedEvent.Parent = ReplicatedStorage
end

if coinsFolder == nil then
	warn("[CoinService] Workspace.World.Coins が見つからないため、コイン処理を開始できません。")
	return
end

local connectedCoins = {}
local rotatingCoins = {}

local function setHumanoidJumpPower(humanoid, jumpPower)
	pcall(function()
		humanoid.UseJumpPower = true
	end)

	humanoid.JumpPower = jumpPower
end

local function syncLeaderboard(player)
	Leaderboard.setStat(player, PlayerData.COIN_KEY_NAME, PlayerData.getValue(player, PlayerData.COIN_KEY_NAME) or 0)
	Leaderboard.setStat(player, PlayerData.JUMP_KEY_NAME, PlayerData.getValue(player, PlayerData.JUMP_KEY_NAME) or 0)
end

local function applyJumpPowerToCharacter(player)
	local character = player.Character
	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end

	local jump = PlayerData.getValue(player, PlayerData.JUMP_KEY_NAME) or 0
	setHumanoidJumpPower(humanoid, jump)
end

local function upgradeJumpIfNeeded(player)
	local upgradeCount = 0

	while (PlayerData.getValue(player, PlayerData.COIN_KEY_NAME) or 0) >= JumpConfig.COINS_PER_UPGRADE do
		PlayerData.updateValue(player, PlayerData.COIN_KEY_NAME, function(currentCoins)
			return currentCoins - JumpConfig.COINS_PER_UPGRADE
		end)

		PlayerData.updateValue(player, PlayerData.JUMP_KEY_NAME, function(currentJump)
			return currentJump + JumpConfig.JUMP_POWER_INCREMENT
		end)

		upgradeCount += 1
	end

	applyJumpPowerToCharacter(player)
	syncLeaderboard(player)

	return upgradeCount
end

local function hideCoin(coin)
	coin:SetAttribute("Enabled", false)
	coin.Transparency = 1
	coin.CanCollide = false
	coin.CanTouch = false
end

local function showCoin(coin, originalTransparency, originalCanCollide)
	if coin.Parent == nil then
		return
	end

	coin.Transparency = originalTransparency
	coin.CanCollide = originalCanCollide
	coin.CanTouch = true
	coin:SetAttribute("Enabled", true)
end

local function onCoinTouched(coin, originalTransparency, originalCanCollide, otherPart)
	if coin:GetAttribute("Enabled") == false then
		return
	end

	local character = otherPart.Parent
	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if player == nil then
		return
	end

	hideCoin(coin)

	PlayerData.updateValue(player, PlayerData.COIN_KEY_NAME, function(currentCoins)
		return currentCoins + JumpConfig.COIN_AMOUNT_TO_ADD
	end)
	coinCollectedEvent:FireClient(player, coin.Name)

	local upgradeCount = upgradeJumpIfNeeded(player)
	if upgradeCount > 0 then
		EffectService.playPowerUpEffect(character, JumpConfig.POWER_UP_SOUND_ID, JumpConfig.POWER_UP_EFFECT_SECONDS)
	else
		EffectService.playCoinSound(coin, JumpConfig.COIN_SOUND_ID)
	end

	task.delay(JumpConfig.COIN_RESPAWN_SECONDS, function()
		showCoin(coin, originalTransparency, originalCanCollide)
	end)
end

local function connectCoin(coin)
	if connectedCoins[coin] then
		return
	end

	if not coin:IsA("BasePart") then
		return
	end

	connectedCoins[coin] = true
	rotatingCoins[coin] = true

	local originalTransparency = coin.Transparency
	local originalCanCollide = coin.CanCollide

	if coin:GetAttribute("Enabled") == nil then
		coin:SetAttribute("Enabled", true)
	end

	coin.Touched:Connect(function(otherPart)
		onCoinTouched(coin, originalTransparency, originalCanCollide, otherPart)
	end)
end

for _, coin in coinsFolder:GetChildren() do
	connectCoin(coin)
end

coinsFolder.ChildAdded:Connect(connectCoin)

RunService.Heartbeat:Connect(function(deltaTime)
	local rotation = math.rad(JumpConfig.COIN_ROTATION_DEGREES_PER_SECOND) * deltaTime

	for coin in rotatingCoins do
		if coin.Parent == nil then
			rotatingCoins[coin] = nil
		elseif coin:GetAttribute("Enabled") ~= false then
			coin.CFrame = coin.CFrame * CFrame.Angles(0, rotation, 0)
		end
	end
end)
