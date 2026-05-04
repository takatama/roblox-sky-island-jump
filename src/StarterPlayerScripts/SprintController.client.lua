local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local ACTION_NAME = "Sprint"
local WALK_SPEED = 16
local SPRINT_SPEED = 28
local RUN_BUTTON_GAP = 12

local humanoid = nil
local isSprinting = false

local function updateWalkSpeed()
	if humanoid == nil then
		return
	end

	if isSprinting then
		humanoid.WalkSpeed = SPRINT_SPEED
	else
		humanoid.WalkSpeed = WALK_SPEED
	end
end

local function onCharacterAdded(character)
	humanoid = character:WaitForChild("Humanoid")
	isSprinting = false
	updateWalkSpeed()

	humanoid.Died:Connect(function()
		humanoid = nil
		isSprinting = false
	end)
end

local function onSprintAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		isSprinting = true
		updateWalkSpeed()
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		isSprinting = false
		updateWalkSpeed()
	end

	return Enum.ContextActionResult.Sink
end

local function findJumpButton()
	local playerGui = player:WaitForChild("PlayerGui")
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui == nil then
		return nil
	end

	return touchGui:FindFirstChild("JumpButton", true)
end

local function configureSprintButton()
	local button = ContextActionService:GetButton(ACTION_NAME)
	if button == nil then
		return false
	end

	local jumpButton = findJumpButton()
	if jumpButton ~= nil and button.Parent ~= nil then
		local jumpPosition = jumpButton.AbsolutePosition
		local jumpSize = jumpButton.AbsoluteSize
		local parentPosition = button.Parent.AbsolutePosition

		button.Size = UDim2.fromOffset(jumpSize.X, jumpSize.Y)
		button.Position = UDim2.fromOffset(
			jumpPosition.X - parentPosition.X - jumpSize.X - RUN_BUTTON_GAP,
			jumpPosition.Y - parentPosition.Y
		)
	else
		button.Size = UDim2.fromOffset(120, 120)
		button.Position = UDim2.new(1, -264, 1, -132)
	end

	local title = button:FindFirstChild("ActionTitle")
	if title ~= nil and title:IsA("TextLabel") then
		title.Text = "Run"
		title.TextSize = 18
	end

	return jumpButton ~= nil
end

local function configureSprintButtonWhenReady()
	for _ = 1, 30 do
		if configureSprintButton() then
			return
		end

		task.wait(0.1)
	end
end

ContextActionService:BindAction(
	ACTION_NAME,
	onSprintAction,
	true,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.RightShift
)
ContextActionService:SetTitle(ACTION_NAME, "Run")
ContextActionService:SetPosition(ACTION_NAME, UDim2.new(1, -264, 1, -132))
task.defer(configureSprintButtonWhenReady)

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
	onCharacterAdded(player.Character)
end
