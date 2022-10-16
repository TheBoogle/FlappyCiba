local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Ciba = {}
Ciba.__index = Ciba

local Gravity = Vector2.new(0, -50)
local CollideDirections = {
	Top = Vector3.new(0, 1, 0),
	Bottom = Vector3.new(0, -1, 0),
	Front = Vector3.new(-1, 0, 0),
}
local CollideDistance = 2

function Ciba.new()
	local self = {
		Position = Vector2.new(0, 0),
		Velocity = Vector2.new(0, 0),
		Acceleration = Vector2.new(0, 0),
		Size = Vector2.new(3, 4),
		Model = Assets.Ciba:Clone(),
		ApplyGravity = false,
		Dead = false,
		CastParams = RaycastParams.new()
	}

	self.CastParams.FilterType = Enum.RaycastFilterType.Blacklist
	self.CastParams.FilterDescendantsInstances = {self.Model}

	setmetatable(self, Ciba)

	return self
end

function Ciba:Collide()
	-- Check top, bottom, front
	
	for DirName, Direction in CollideDirections do
		local Ray = Ray.new(
			self.Model.PrimaryPart.Position,
			Direction * CollideDistance
		)

		local Result = workspace:Raycast(Ray.Origin, Ray.Direction, self.CastParams)

		--VisualizeRaycast(Ray, Result)

		if Result or self.Position.Y < -35 then
			return true
		end
	end

	return false
end

function Ciba:Jump()
	if self.Position.Y > 35 then return false end
	
	self.ApplyGravity = true
	self.Velocity = Vector2.new(0, 25)
	
	return true
end

function Ciba:Update(DeltaTime: number)
	if self.Dead then return end

	if self:Collide() then self.Dead = true return end

	DeltaTime = DeltaTime or 1 / 60

	if self.ApplyGravity then
		self.Acceleration = self.Acceleration + Gravity
	end

	self.Velocity = self.Velocity + self.Acceleration * DeltaTime
	self.Position = self.Position + self.Velocity * DeltaTime

	-- Position and rotate Ciba based on velocity

	self.Model:PivotTo(
		CFrame.new(self.Position.X, self.Position.Y, 0)
			* CFrame.Angles(0, 0, math.clamp(-self.Velocity.Y / 25, -math.pi / 4, math.pi / 2) + math.pi / 2)
	)

	self.Acceleration = Vector2.zero
end

function Ciba:Reset()
	self.Position = Vector2.new(0, 0)
	self.Velocity = Vector2.new(0, 0)
	self.Acceleration = Vector2.new(0, 0)
	self.ApplyGravity = false
	self.Dead = false
end

return Ciba
