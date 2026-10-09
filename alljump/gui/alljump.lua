local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	hrp = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)

local checkpoints = {} 
local globalOpacity = 0.5
local COLOR = Color3.new(1, 1, 1)

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheckpointMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 150)
mainFrame.Position = UDim2.new(0, 15, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "alljump menu"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 0, 25)
counterLabel.Position = UDim2.new(0, 0, 0, 30)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "checkpoint: 0 / 0"
counterLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
counterLabel.Font = Enum.Font.SourceSans
counterLabel.TextSize = 16
counterLabel.Parent = mainFrame

local opacityLabel = Instance.new("TextLabel")
opacityLabel.Size = UDim2.new(0, 110, 0, 30)
opacityLabel.Position = UDim2.new(0, 10, 0, 65)
opacityLabel.BackgroundTransparency = 1
opacityLabel.Text = "opacity (0-1):"
opacityLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
opacityLabel.TextXAlignment = Enum.TextXAlignment.Left
opacityLabel.Font = Enum.Font.SourceSans
opacityLabel.TextSize = 14
opacityLabel.Parent = mainFrame

local opacityInput = Instance.new("TextBox")
opacityInput.Size = UDim2.new(0, 100, 0, 25)
opacityInput.Position = UDim2.new(0, 130, 0, 67)
opacityInput.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
opacityInput.TextColor3 = Color3.new(1, 1, 1)
opacityInput.Text = tostring(globalOpacity)
opacityInput.Font = Enum.Font.SourceSansBold
opacityInput.TextSize = 14
opacityInput.BorderSizePixel = 0
opacityInput.Parent = mainFrame

local opacityCorner = Instance.new("UICorner")
opacityCorner.CornerRadius = UDim.new(0, 4)
opacityCorner.Parent = opacityInput

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(0, 110, 0, 30)
jumpLabel.Position = UDim2.new(0, 10, 0, 105)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "goto checkpoint:"
jumpLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Font = Enum.Font.SourceSans
jumpLabel.TextSize = 14
jumpLabel.Parent = mainFrame

local jumpInput = Instance.new("TextBox")
jumpInput.Size = UDim2.new(0, 100, 0, 25)
jumpInput.Position = UDim2.new(0, 130, 0, 107)
jumpInput.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
jumpInput.TextColor3 = Color3.new(0.2, 0.8, 1)
jumpInput.Text = ""
jumpInput.PlaceholderText = "Enter index..."
jumpInput.Font = Enum.Font.SourceSansBold
jumpInput.TextSize = 14
jumpInput.BorderSizePixel = 0
jumpInput.Parent = mainFrame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 4)
jumpCorner.Parent = jumpInput

local function updateCounterUI()
	if #checkpoints == 0 then
		counterLabel.Text = "checkpoint: 0 / 0"
	else
		counterLabel.Text = "checkpoint: " .. #checkpoints .. " / " .. #checkpoints
	end
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

local function teleportToCheckpointIndex(idx)
	if idx and checkpoints[idx] and hrp and humanoid then
		local target = checkpoints[idx]
		hrp.CFrame = target.position
		humanoid:ChangeState(target.state)
		hrp.AssemblyLinearVelocity = target.velocity
		
		counterLabel.Text = "checkpoint: " .. idx .. " / " .. #checkpoints
	end
end

opacityInput.FocusLost:Connect(function(enterPressed)
	local num = tonumber(opacityInput.Text)
	if num then
		globalOpacity = math.clamp(num, 0, 1)
		opacityInput.Text = tostring(globalOpacity)
		
		for _, cp in ipairs(checkpoints) do
			if cp.visual then
				cp.visual.Transparency = globalOpacity
			end
		end
	else
		opacityInput.Text = tostring(globalOpacity) end
end)

jumpInput.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	local targetIndex = tonumber(jumpInput.Text)
	if targetIndex then
		targetIndex = math.floor(targetIndex)
		if targetIndex >= 1 and targetIndex <= #checkpoints then
			teleportToCheckpointIndex(targetIndex)
		end
	end
	jumpInput.Text = ""
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.RightAlt then
		mainFrame.Visible = not mainFrame.Visible
		return
	end

	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		if not hrp or not humanoid then return end
		
		local targetSize, targetCFrame = getTorsoSizeAndCFrame()
		
		local part = Instance.new("Part")
		part.Size = targetSize
		part.CFrame = targetCFrame
		part.Color = COLOR
		part.Transparency = globalOpacity 
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Parent = workspace
		
		table.insert(checkpoints, {
			position = targetCFrame,
			velocity = hrp.AssemblyLinearVelocity,
			state = humanoid:GetState(),
			visual = part
		})
		
		updateCounterUI()
		
	elseif input.KeyCode == Enum.KeyCode.R then
		if #checkpoints > 0 then
			teleportToCheckpointIndex(#checkpoints)
		end
		
	elseif input.KeyCode == Enum.KeyCode.V then
		if #checkpoints > 0 then
			local lastCheckpoint = table.remove(checkpoints, #checkpoints)
			if lastCheckpoint.visual then
				lastCheckpoint.visual:Destroy()
			end
			updateCounterUI()
		end
	end
end)
