local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Player = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets
local Modules = ReplicatedStorage.Modules

local Pipe = require(Modules.Pipe)
local Ciba = require(Modules.Ciba).new()
local Camera = require(Modules.Camera).new()

local PipeDistance = 50
local PipeHeight = 20
local PipeGap = 72
local MoveSpeed = 18

local CameraDistance = 4000
local LastPipe = 0

local Score = 0
local HScore = Remotes.GetHScore:InvokeServer()

if not HScore then
	warn("No highscore found!")
	HScore = 0
end

local Restarting = false
local Pipes = {}

local UI = Assets.UI:Clone()
UI.Parent = Player.PlayerGui

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

Camera:MoveTo(Vector3.new(900, 0, -CameraDistance))
Camera:SetFOV(1)
Camera:LookTowards(Vector3.new(0, 0, 0))

Ciba.Model.Parent = workspace
Ciba:Update()

Assets.Pipe.Top.Position = Vector3.yAxis * (PipeGap / 2)
Assets.Pipe.Bottom.Position = Vector3.yAxis * -(PipeGap / 2)

local function RestartGame()
	for _, Pipe in pairs(Pipes) do
		Pipe.Model:Destroy()
	end

	Pipes = {}

	Score = 0
	LastPipe = 0

	Ciba:Reset()
end

local function PlaySfx(SoundName: string)
	local realName = "sfx_" .. SoundName:lower()
	
	SoundService:PlayLocalSound(Assets.Sounds[realName])
end

ContextActionService:BindAction("Jump", function(_, State)
	if State == Enum.UserInputState.Begin then
		if Ciba:Jump() then
			PlaySfx("wing")
		end
	end
end, false, Enum.KeyCode.Space, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)

RunService:BindToRenderStep("CibaUpdate", Enum.RenderPriority.Camera.Value, function(DeltaTime)
	if Ciba.Dead and not Restarting then
		PlaySfx("hit")

		Restarting = true

		task.wait(2)
		RestartGame()

		Restarting = false
	end

	if Ciba.Dead then return end

	UI.Score.Text = Score
	UI.HScore.Text = ("Highscore: %d"):format(HScore)

	-- Create pipe every X studs based off of Ciba's position

	for Index, Pipe in Pipes do
		if Pipe.Position.X < Ciba.Position.X - PipeDistance then
			Pipe.Model:Destroy()
			table.remove(Pipes, Index)
		end

		Pipe.Position += Vector2.new(MoveSpeed, 0) * DeltaTime
		Pipe:Update(DeltaTime)

		if Pipe.Position.X >= Ciba.Size.X and not Pipe.Hit and not Ciba.Dead then
			Score += 1

			if Score > HScore then
				HScore = Score
				Remotes.SetHScore:FireServer(HScore)
			end

			PlaySfx("point")
			Pipe.Hit = true
		end
	end

	if LastPipe >= PipeDistance then
		local Pipe = Pipe.new()
		Pipe.Position = Vector2.new(Ciba.Position.X - PipeDistance, math.random(-PipeHeight, PipeHeight))
		Pipe:Update()
		Pipe.Model.Parent = workspace
		

		table.insert(Pipes, Pipe)
		LastPipe = 0
	end

	if Ciba.ApplyGravity and not Ciba.Dead then
		LastPipe += MoveSpeed * DeltaTime
	end

	Ciba:Update(DeltaTime)
end)