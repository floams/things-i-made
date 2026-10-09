local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local alljump = getgenv().alljump
assert(alljump, "[alljump] getgenv().alljump config table not found")

alljump.checkpoints      = alljump.checkpoints or {}
alljump.opacity          = alljump.opacity or 0.5
alljump.savecheckpoint   = alljump.savecheckpoint or "F"
alljump.removecheckpoint = alljump.removecheckpoint or "V"
alljump.gotocheckpoint   = alljump.gotocheckpoint or "R"

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	hrp = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlljumpCounterGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(0, 60, 0, 40)
counterLabel.Position = UDim2.new(1, -70, 0, 10)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "0"
counterLabel.TextColor3 = Color3.new(1, 1, 1)
counterLabel.TextStrokeTransparency = 0
counterLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
counterLabel.Font = Enum.Font.SourceSansBold
counterLabel.TextSize = 28
counterLabel.TextXAlignment = Enum.TextXAlignment.Right
counterLabel.Parent = screenGui

local function updateCounter()
	counterLabel.Text = tostring(#alljump.checkpoints)
end

local function getTorsoSizeAndCFrame()
	if not character or not hrp then return Vector3.new(2, 2, 1), CFrame.new() end

	local r6Torso = character:FindFirstChild("Torso")
	if r6Torso and r6Torso:IsA("BasePart") then
		return r6Torso.Size, hrp.CFrame
	end

	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")

	if upperTorso and lowerTorso and upperTorso:IsA("BasePart") and lowerTorso:IsA("BasePart") then
		local combinedHeight = upperTorso.Size.Y + lowerTorso.Size.Y
		return Vector3.new(upperTorso.Size.X, combinedHeight, upperTorso.Size.Z), hrp.CFrame
	elseif upperTorso and upperTorso:IsA("BasePart") then
		return upperTorso.Size, hrp.CFrame
	end

	return Vector3.new(2, 2, 1), hrp.CFrame
end

function alljump.saveCheckpoint()
	if not hrp or not humanoid then return end

	local targetSize, targetCFrame = getTorsoSizeAndCFrame()

	local part = Instance.new("Part")
	part.Size = targetSize
	part.CFrame = targetCFrame
	part.Color = Color3.new(1, 1, 1)
	part.Transparency = alljump.opacity
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = workspace

	table.insert(alljump.checkpoints, {
		position = targetCFrame,
		velocity = hrp.AssemblyLinearVelocity,
		state = humanoid:GetState(),
		visual = part
	})

	updateCounter()
end

function alljump.removeCheckpoint()
	if #alljump.checkpoints > 0 then
		local lastCheckpoint = table.remove(alljump.checkpoints, #alljump.checkpoints)
		if lastCheckpoint.visual then
			lastCheckpoint.visual:Destroy()
		end
		updateCounter()
	end
end

function alljump.gotoCheckpoint(idx)
	idx = idx or #alljump.checkpoints
	if not alljump.checkpoints[idx] then
		print("[alljump] invalid checkpoint index: " .. tostring(idx))
		return
	end
	if not hrp or not humanoid then return end

	local target = alljump.checkpoints[idx]
	hrp.CFrame = target.position
	humanoid:ChangeState(target.state)
	hrp.AssemblyLinearVelocity = target.velocity
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.RightAlt then
		counterLabel.Visible = not counterLabel.Visible
		return
	end

	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode[alljump.savecheckpoint] then
		alljump.saveCheckpoint()
	elseif input.KeyCode == Enum.KeyCode[alljump.removecheckpoint] then
		alljump.removeCheckpoint()
	elseif input.KeyCode == Enum.KeyCode[alljump.gotocheckpoint] then
		alljump.gotoCheckpoint()
	end
end)

updateCounter()

print("[alljump] loaded. F=save, V=remove, R=goto")
print("[alljump] alt = toggle checkpoint count")

-- hello
