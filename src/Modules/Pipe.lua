local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Pipe = {}
Pipe.__index = Pipe

function Pipe.new()
	local self = {
		Model = Assets.Pipe:Clone(),
		Position = Vector2.new(0, 0),
		Hit = false
	}

	setmetatable(self, Pipe)

	return self
end

function Pipe:Update()
	self.Model:PivotTo(CFrame.new(self.Position.X, self.Position.Y, 0))
end

return Pipe