local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local EffectService = require(ServerStorage:WaitForChild("EffectService"))
local JumpConfig = require(ServerStorage:WaitForChild("JumpConfig"))

local world = Workspace:FindFirstChild("World")

if world == nil then
	warn("[FinishService] Workspace.World が見つからないため、頂上到達演出を開始できません。")
	return
end

local blockoutParts = world:FindFirstChild("Blockout_Parts")

if blockoutParts == nil then
	warn("[FinishService] Workspace.World.Blockout_Parts が見つからないため、頂上到達演出を開始できません。")
	return
end

local finishTargets = {}
local lastCelebrationTimeByKey = {}

local function getBounds(instance)
	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	if instance:IsA("Model") then
		return instance:GetBoundingBox()
	end

	return nil, nil
end

local function addTargetByName(levelName)
	local level = blockoutParts:FindFirstChild(levelName)
	if level == nil then
		warn("[FinishService] Workspace.World.Blockout_Parts." .. levelName .. " が見つかりません。")
		return
	end

	local cframe, size = getBounds(level)
	if cframe == nil or size == nil then
		warn("[FinishService] " .. levelName .. " は Part か Model にしてください。")
		return
	end

	table.insert(finishTargets, {
		Name = levelName,
		Instance = level,
		CFrame = cframe,
		Size = size,
	})
end

for _, levelName in ipairs(JumpConfig.FINISH_LEVEL_NAMES) do
	addTargetByName(levelName)
end

if #finishTargets == 0 then
	warn("[FinishService] 頂上判定に使える Level7 がありません。Blockout_Parts の Level_7 を確認してください。")
	return
end

local function canCelebrate(player, targetName)
	local now = os.clock()
	local key = tostring(player.UserId) .. ":" .. targetName
	local lastTime = lastCelebrationTimeByKey[key] or 0

	if now - lastTime < JumpConfig.FINISH_CELEBRATION_COOLDOWN_SECONDS then
		return false
	end

	lastCelebrationTimeByKey[key] = now
	return true
end

local function getPlayerRootPart(player)
	local character = player.Character
	if character == nil then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid == nil or rootPart == nil or humanoid.Health <= 0 then
		return nil
	end

	return rootPart
end

local function playCelebration(player, target)
	if not canCelebrate(player, target.Name) then
		return
	end

	local rootPart = getPlayerRootPart(player)
	local topPosition = target.CFrame.Position + Vector3.new(0, target.Size.Y * 0.5 + 4, 0)

	if rootPart then
		EffectService.playFinishCelebration(topPosition, JumpConfig.FIREWORK_SOUND_ID, JumpConfig.CHEER_SOUND_ID, rootPart.CFrame)
	else
		EffectService.playFinishCelebration(topPosition, JumpConfig.FIREWORK_SOUND_ID, JumpConfig.CHEER_SOUND_ID)
	end
end

local function isPlayerInsideGoalPart(player, target)
	local character = player.Character
	if character == nil then
		return false
	end

	local parts = Workspace:GetPartBoundsInBox(target.CFrame, target.Size)

	for _, part in ipairs(parts) do
		if part:IsDescendantOf(character) then
			return true
		end
	end

	return false
end

local function isPlayerOnTopOfTarget(player, target)
	local rootPart = getPlayerRootPart(player)
	if rootPart == nil then
		return false
	end

	if string.find(target.Name, "_Goal") then
		return isPlayerInsideGoalPart(player, target)
	end

	local localPosition = target.CFrame:PointToObjectSpace(rootPart.Position)
	local halfSize = target.Size * 0.5
	local horizontalPadding = 3
	local rootHeightAboveTopMin = 1.5
	local rootHeightAboveTopMax = 7

	local isInsideX = math.abs(localPosition.X) <= halfSize.X + horizontalPadding
	local isInsideZ = math.abs(localPosition.Z) <= halfSize.Z + horizontalPadding
	local isRootAboveTop = localPosition.Y >= halfSize.Y + rootHeightAboveTopMin and localPosition.Y <= halfSize.Y + rootHeightAboveTopMax

	return isInsideX and isInsideZ and isRootAboveTop
end

RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		for _, target in ipairs(finishTargets) do
			if isPlayerOnTopOfTarget(player, target) then
				playCelebration(player, target)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local userIdPrefix = tostring(player.UserId) .. ":"

	for key in pairs(lastCelebrationTimeByKey) do
		if string.sub(key, 1, #userIdPrefix) == userIdPrefix then
			lastCelebrationTimeByKey[key] = nil
		end
	end
end)
