local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local DataStore = DataStoreService:GetDataStore("Highscore")
local Key = ("uid_%d")

local Remotes = Instance.new("Folder"); Remotes.Name = "Remotes"; Remotes.Parent = ReplicatedStorage

local SetHScore = Instance.new("RemoteEvent"); SetHScore.Name = "SetHScore"; SetHScore.Parent = Remotes
local GetHScore = Instance.new("RemoteFunction"); GetHScore.Name = "GetHScore"; GetHScore.Parent = Remotes

local HScores = {}

Players.PlayerAdded:Connect(function(Player)
	local HScore = DataStore:GetAsync(Key:format(Player.UserId))
	
	HScores[Player] = HScore or 0
end)

Players.PlayerRemoving:Connect(function(Player)
	if HScores[Player] then
		DataStore:SetAsync(Key:format(Player.UserId), HScores[Player])
	end
end)

SetHScore.OnServerEvent:Connect(function(Player, Score)
	HScores[Player] = Score
end)

GetHScore.OnServerInvoke = function(Player)
	local TO = tick() + 3
	repeat
		task.wait()
	until HScores[Player] or tick() > TO
	
	return HScores[Player]
end

game:BindToClose(function()
	task.wait(2)
end)