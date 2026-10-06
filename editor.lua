pcall(function() if _G.stat_kill_signal then _G.stat_kill_signal() end end)

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local server_string_map = {
    maxhealth = "MaxHealth", health = "Health", walkspeed = "WalkSpeed",
    jumppower = "JumpPower", hipheight = "HipHeight",
    healthdisplaydistance = "HealthDisplayDistance", namedisplaydistance = "NameDisplayDistance",
    sitting = "Sitting", platformstand = "PlatformStand", autorotate = "AutoRotate",
    requiresneck = "RequiresNeck", autojump = "AutoJump"
}
local boolean_stats = {"sitting", "platformstand", "autorotate", "requiresneck", "autojump"}

local active_loop = true
task.spawn(function()
    while active_loop do
        local settings = getgenv().stat_settings
        if not settings then break end
        
        local target_key = tostring(settings["stat"]):lower():gsub("%s+", "")
        local is_bool = table.find(boolean_stats, target_key) ~= nil
        local final_val = is_bool and settings["boolean"] or tonumber(settings["modification"])
        
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum and final_val ~= nil then
            pcall(function()
                local remote_key = server_string_map[target_key]
                if remote_key then
                    local playerGui = localPlayer:WaitForChild("PlayerGui", 2)
                    local statEditor = playerGui and playerGui:FindFirstChild("StatEditor")
                    local event = statEditor and statEditor:FindFirstChild("RemoteEvent")
                    if event then
                        event:FireServer(remote_key, 1, 1, final_val, nil)
                        if firesignal then firesignal(event.OnClientEvent, true) end
                    end
                end
                
                if target_key == "walkspeed" then hum.WalkSpeed = final_val
                elseif target_key == "jumppower" then hum.UseJumpPower = true; hum.JumpPower = final_val
                elseif target_key == "maxhealth" then hum.MaxHealth = final_val
                elseif target_key == "health" then hum.Health = final_val
                elseif target_key == "hipheight" then hum.HipHeight = final_val
                elseif target_key == "healthdisplaydistance" then hum.HealthDisplayDistance = final_val
                elseif target_key == "namedisplaydistance" then hum.NameDisplayDistance = final_val
                elseif target_key == "sitting" then hum.Sitting = final_val
                elseif target_key == "platformstand" then hum.PlatformStand = final_val
                elseif target_key == "autorotate" then hum.AutoRotate = final_val
                elseif target_key == "requiresneck" then hum.RequiresNeck = final_val
                elseif target_key == "autojump" then hum.AutoJump = final_val
                end
            end)
        end
        task.wait(0.2)
    end
end)

_G.stat_kill_signal = function() active_loop = false; _G.stat_kill_signal = nil; getgenv().stat_settings = nil end
