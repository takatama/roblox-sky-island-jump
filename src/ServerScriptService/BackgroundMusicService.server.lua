local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local JumpConfig = require(ServerStorage:WaitForChild("JumpConfig"))

local SOUND_NAME = "SkyIslandBackgroundMusic"

local existingSound = SoundService:FindFirstChild(SOUND_NAME)
if existingSound then
	existingSound:Destroy()
end

local backgroundMusic = Instance.new("Sound")
backgroundMusic.Name = SOUND_NAME
backgroundMusic.SoundId = JumpConfig.BACKGROUND_MUSIC_SOUND_ID
backgroundMusic.Volume = JumpConfig.BACKGROUND_MUSIC_VOLUME
backgroundMusic.Looped = true
backgroundMusic.Parent = SoundService
backgroundMusic:Play()
