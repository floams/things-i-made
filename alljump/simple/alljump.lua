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

	print("[alljump] saved checkpoint #" .. #alljump.checkpoints)
end

function alljump.removeCheckpoint()
	if #alljump.checkpoints > 0 then
		local lastCheckpoint = table.remove(alljump.checkpoints, #alljump.checkpoints)
		if lastCheckpoint.visual then
			lastCheckpoint.visual:Destroy()
		end
		print("[alljump] removed last checkpoint. remaining: " .. #alljump.checkpoints)
	else
		print("[alljump] no checkpoints to remove")
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

	print("[alljump] teleported to checkpoint #" .. idx .. " / " .. #alljump.checkpoints)
end

function alljump.listCheckpoints()
	print("[alljump] you have " .. #alljump.checkpoints .. " checkpoint(s)")
	for i, cp in ipairs(alljump.checkpoints) do
		local pos = cp.position.Position
		print(string.format("  [%d] %.1f, %.1f, %.1f", i, pos.X, pos.Y, pos.Z))
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode[alljump.savecheckpoint] then
		alljump.saveCheckpoint()
	elseif input.KeyCode == Enum.KeyCode[alljump.removecheckpoint] then
		alljump.removeCheckpoint()
	elseif input.KeyCode == Enum.KeyCode[alljump.gotocheckpoint] then
		alljump.gotoCheckpoint()
	end
end)

print("[alljump] loaded. F=save, V=remove, R=goto")
print("[alljump] alljump.listCheckpoints() -> list all")
print("[alljump] alljump.gotoCheckpoint(index) -> teleport to specific")
