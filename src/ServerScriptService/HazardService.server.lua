local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local world = Workspace:FindFirstChild("World")
local hazardsFolder = if world then world:FindFirstChild("Hazards") else nil

if hazardsFolder == nil then
	warn("[HazardService] Workspace.World.Hazards が見つからないため、Hazard 処理を開始できません。")
	return
end

local connectedHazards = {}

local function onHazardTouched(otherPart)
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

	humanoid.Health = 0
end

local function connectHazard(hazard)
	if connectedHazards[hazard] then
		return
	end

	if not hazard:IsA("BasePart") then
		return
	end

	connectedHazards[hazard] = true

	hazard.Touched:Connect(onHazardTouched)
end

for _, hazard in hazardsFolder:GetChildren() do
	connectHazard(hazard)
end

hazardsFolder.ChildAdded:Connect(connectHazard)
