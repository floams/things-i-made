local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local statEditor = playerGui:WaitForChild("StatEditor")
local Event = statEditor:WaitForChild("RemoteEvent")

local server_string_map = {
    maxhealth = "MaxHealth", health = "Health", walkspeed = "WalkSpeed",
    jumppower = "JumpPower", hipheight = "HipHeight",
    healthdisplaydistance = "HealthDisplayDistance", namedisplaydistance = "NameDisplayDistance",
    sitting = "Sitting", platformstand = "PlatformStand", autorotate = "AutoRotate",
    requiresneck = "RequiresNeck", autojump = "AutoJump"
}
local boolean_stats = {"sitting", "platformstand", "autorotate", "requiresneck", "autojump"}

local settings = getgenv().stat_settings
local current_stat = tostring(settings["stat"]):lower():gsub("%s+", "")
local is_bool = table.find(boolean_stats, current_stat) ~= nil
local final_val = is_bool and settings["boolean"] or tonumber(settings["modification"])
local remote_key = server_string_map[current_stat] or "WalkSpeed"

task.spawn(function()
    Event:FireServer(remote_key, 1, 1, final_val, nil)
end)

if firesignal then
    firesignal(Event.OnClientEvent, true)
end

task.spawn(function()
    while true do
        local settings = getgenv().stat_settings
        if not settings then break end
        
        local target_key = tostring(settings["stat"]):lower():gsub("%s+", "")
        local is_bool = table.find(boolean_stats, target_key) ~= nil
        local loop_val = is_bool and settings["boolean"] or tonumber(settings["modification"])
        
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 3)
        
        if hum and loop_val ~= nil then
            pcall(function()
                if target_key == "walkspeed" and hum.WalkSpeed ~= loop_val then hum.WalkSpeed = loop_val
                elseif target_key == "jumppower" then hum.UseJumpPower = true; if hum.JumpPower ~= loop_val then hum.JumpPower = loop_val end
                elseif target_key == "maxhealth" and hum.MaxHealth ~= loop_val then hum.MaxHealth = loop_val
                elseif target_key == "health" and hum.Health ~= loop_val then hum.Health = loop_val
                elseif target_key == "hipheight" and hum.HipHeight ~= loop_val then hum.HipHeight = loop_val
                elseif target_key == "healthdisplaydistance" and hum.HealthDisplayDistance ~= loop_val then hum.HealthDisplayDistance = loop_val
                elseif target_key == "namedisplaydistance" and hum.NameDisplayDistance ~= loop_val then hum.NameDisplayDistance = loop_val
                elseif target_key == "sitting" and hum.Sitting ~= loop_val then hum.Sitting = loop_val
                elseif target_key == "platformstand" and hum.PlatformStand ~= loop_val then hum.PlatformStand = loop_val
                elseif target_key == "autorotate" and hum.AutoRotate ~= loop_val then hum.AutoRotate = loop_val
                elseif target_key == "requiresneck" and hum.RequiresNeck ~= loop_val then hum.RequiresNeck = loop_val
                elseif target_key == "autojump" and hum.AutoJump ~= loop_val then hum.AutoJump = loop_val
                end
            end)
        end
        task.wait(0.1)
    end
end)
