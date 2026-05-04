local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local EffectService = {}

local function playSound(parent, soundId, volume)
	if soundId == nil or soundId == "" then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 1
	sound.RollOffMaxDistance = 80
	sound.Parent = parent
	sound:Play()

	Debris:AddItem(sound, 5)
end

local function getRootPart(character)
	return character:FindFirstChild("HumanoidRootPart")
end

function EffectService.playCoinSound(coin, soundId)
	playSound(coin, soundId, 0.6)
end

function EffectService.playPowerUpEffect(character, soundId, duration)
	local rootPart = getRootPart(character)
	if rootPart == nil then
		return
	end

	playSound(rootPart, soundId, 1)

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 240, 120)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0
	highlight.Parent = character

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 230, 120)
	light.Brightness = 4
	light.Range = 14
	light.Parent = rootPart

	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 240, 120), Color3.fromRGB(120, 220, 255))
	sparkles.LightEmission = 1
	sparkles.Lifetime = NumberRange.new(0.6, 1)
	sparkles.Rate = 45
	sparkles.Speed = NumberRange.new(2, 5)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.Parent = rootPart

	local effectTime = duration or 2
	Debris:AddItem(highlight, effectTime)
	Debris:AddItem(light, effectTime)
	Debris:AddItem(sparkles, effectTime)
end

local function createFireworkBurst(position, colors, burstIndex)
	local holder = Instance.new("Part")
	holder.Name = "FinishCelebrationEffect"
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.new(1, 1, 1)
	holder.Position = position
	holder.Parent = workspace

	local flash = Instance.new("PointLight")
	flash.Color = colors[((burstIndex - 1) % #colors) + 1]
	flash.Brightness = 18
	flash.Range = 55
	flash.Parent = holder
	Debris:AddItem(flash, 1.5)

	local fireworks = Instance.new("ParticleEmitter")
	fireworks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	fireworks.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 220, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 120)),
	})
	fireworks.LightEmission = 1
	fireworks.Lifetime = NumberRange.new(1.2, 2)
	fireworks.Rate = 0
	fireworks.Speed = NumberRange.new(14, 24)
	fireworks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.8),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	fireworks.SpreadAngle = Vector2.new(180, 180)
	fireworks.Parent = holder
	fireworks:Emit(260)

	for index = 1, 30 do
		local burst = Instance.new("Part")
		burst.Name = "FireworkSpark"
		burst.Anchored = true
		burst.CanCollide = false
		burst.CanTouch = false
		burst.Material = Enum.Material.Neon
		burst.Shape = Enum.PartType.Ball
		burst.Size = Vector3.new(1, 1, 1)
		burst.Color = colors[((index - 1) % #colors) + 1]
		burst.Position = holder.Position
		burst.Parent = workspace

		local angle = (math.pi * 2 / 30) * index
		local height = math.sin(index * 1.7) * 5
		local distance = 12 + (index % 5) * 2
		local goalPosition = holder.Position + Vector3.new(math.cos(angle) * distance, height, math.sin(angle) * distance)
		local tween = TweenService:Create(
			burst,
			TweenInfo.new(1.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = goalPosition,
				Transparency = 1,
				Size = Vector3.new(0.15, 0.15, 0.15),
			}
		)
		tween:Play()

		Debris:AddItem(burst, 1.7)
	end

	Debris:AddItem(holder, 5)
end

local function launchFirework(position, colors, burstIndex, viewCFrame)
	local rightVector = if viewCFrame then viewCFrame.RightVector else Vector3.xAxis
	local forwardVector = if viewCFrame then viewCFrame.LookVector else -Vector3.zAxis
	local sideOffset = rightVector * ((burstIndex - 2) * 8)

	local launchPart = Instance.new("Part")
	launchPart.Name = "FireworkLaunch"
	launchPart.Anchored = true
	launchPart.CanCollide = false
	launchPart.CanTouch = false
	launchPart.Material = Enum.Material.Neon
	launchPart.Shape = Enum.PartType.Ball
	launchPart.Size = Vector3.new(1.2, 1.2, 1.2)
	launchPart.Color = colors[((burstIndex - 1) % #colors) + 1]
	launchPart.Position = position + sideOffset + Vector3.new(0, -4, 0)
	launchPart.Parent = workspace

	local launchLight = Instance.new("PointLight")
	launchLight.Color = launchPart.Color
	launchLight.Brightness = 8
	launchLight.Range = 24
	launchLight.Parent = launchPart

	local burstPosition = position + sideOffset + forwardVector * (burstIndex * 2) + Vector3.new(0, 3 + burstIndex, 0)
	local tween = TweenService:Create(
		launchPart,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = burstPosition,
			Size = Vector3.new(0.5, 0.5, 0.5),
		}
	)
	tween:Play()

	task.delay(0.4, function()
		if launchPart.Parent == nil then
			return
		end

		createFireworkBurst(burstPosition, colors, burstIndex)
		launchPart:Destroy()
	end)

	Debris:AddItem(launchPart, 2)
end

function EffectService.playFinishCelebration(position, fireworkSoundId, cheerSoundId, viewCFrame)
	local basePosition = position + Vector3.new(0, 8, 0)

	if viewCFrame then
		basePosition = viewCFrame.Position + viewCFrame.LookVector * 22 + Vector3.new(0, 6, 0)
	end

	local soundHolder = Instance.new("Part")
	soundHolder.Name = "FinishCelebrationSound"
	soundHolder.Anchored = true
	soundHolder.CanCollide = false
	soundHolder.CanTouch = false
	soundHolder.Transparency = 1
	soundHolder.Size = Vector3.new(1, 1, 1)
	soundHolder.Position = basePosition
	soundHolder.Parent = workspace

	playSound(soundHolder, cheerSoundId, 1)

	local colors = {
		Color3.fromRGB(255, 70, 70),
		Color3.fromRGB(90, 210, 255),
		Color3.fromRGB(255, 235, 90),
		Color3.fromRGB(190, 100, 255),
		Color3.fromRGB(100, 255, 150),
	}

	for burstIndex = 1, 3 do
		task.delay((burstIndex - 1) * 0.55, function()
			playSound(soundHolder, fireworkSoundId, 0.9)
			launchFirework(basePosition, colors, burstIndex, viewCFrame)
		end)
	end

	Debris:AddItem(soundHolder, 6)
end

return EffectService
