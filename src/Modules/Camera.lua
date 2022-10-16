local Camera = {}
Camera.__index = Camera

local CCamera = workspace.CurrentCamera
CCamera.CameraType = Enum.CameraType.Scriptable

function Camera.new()
	local self = {}

	CCamera.CameraType = Enum.CameraType.Scriptable

	setmetatable(self, Camera)

	return self
end

function Camera:MoveTo(Vector3: Vector3)
	CCamera.CFrame = CFrame.new(Vector3)
end

function Camera:LookTowards(Vector3: Vector3)
	CCamera.CFrame = CFrame.lookAt(CCamera.CFrame.Position, Vector3)
end

function Camera:SetFOV(FOV: number)
	CCamera.FieldOfView = FOV
end

return Camera