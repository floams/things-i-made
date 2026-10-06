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

local defaults = {
    maxhealth = 100, health = 100, walkspeed = 16, jumppower = 50, hipheight = 0,
    healthdisplaydistance = 100, namedisplaydistance = 100, sitting = false,
    platformstand = false, autorotate = true, requiresneck = true, autojump = false
}

local active_loop = true
local last_stat = nil
local last_val = nil

task.spawn(function()
    while active_loop do
        local settings = getgenv().stat_settings
        if settings then
            local current_stat = tostring(settings["stat"]):lower():gsub("%s+", "")
            local is_bool = table.find(boolean_stats, current_stat) ~= nil
            local current_val = is_bool and settings["boolean"] or tonumber(settings["modification"])
            
            if current_stat ~= last_stat or current_val ~= last_val then
                if not is_bool and last_val and current_val and current_val < last_val then
                    pcall(function()
                        local char = localPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local remote_key = server_string_map[current_stat]
                            local base_default = defaults[current_stat] or 0
                            
                            if remote_key then
                                local playerGui = localPlayer:WaitForChild("PlayerGui", 2)
                                local statEditor = playerGui and playerGui:FindFirstChild("StatEditor")
                                local event = statEditor and statEditor:FindFirstChild("RemoteEvent")
                                if event then
                                    -- tell the server to reset to base values first
                                    event:FireServer(remote_key, 1, 1, base_default, nil)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end

                last_stat = current_stat
                last_val = current_val
                
                local remote_key = server_string_map[current_stat]
                if remote_key and current_val ~= nil then
                    pcall(function()
                        local playerGui = localPlayer:WaitForChild("PlayerGui", 2)
                        local statEditor = playerGui and playerGui:FindFirstChild("StatEditor")
                        local event = statEditor and statEditor:FindFirstChild("RemoteEvent")
                        if event then
                            for i = 1, 10 do 
                                event:FireServer(remote_key, 1, 1, current_val, nil) 
                            end
                            if firesignal then firesignal(event.OnClientEvent, true) end
                        end
                    end)
                end
            end
        end
        task.wait(0.3)
    end
end)

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
                if target_key == "walkspeed" then hum.WalkSpeed = final_val
                elseif target_key == "jumppower" then hum.UseJumpPower = true; hum.JumpPower = final_val
                elseif target_key == "maxhealth" then hum.MaxHealth = final_val
                elseif target_key == "health" then hum.Health = final_val
                elseif target_key == "hipheight" then hum.HipHeight = final_val
                elseif target_key == "healthdisplaydistance" then hum.HealthDisplayDistance = final_val
                elseif target_key == "namedisplaydistance" then hum.NameDisplayDistance = final_val
                elseif target_key == "sitting" and hum.Sitting ~= final_val then hum.Sitting = final_val
                elseif target_key == "platformstand" and hum.PlatformStand ~= final_val then hum.PlatformStand = final_val
                elseif target_key == "autorotate" and hum.AutoRotate ~= final_val then hum.AutoRotate = final_val
                elseif target_key == "requiresneck" and hum.RequiresNeck ~= final_val then hum.RequiresNeck = final_val
                elseif target_key == "autojump" and hum.AutoJump ~= final_val then hum.AutoJump = final_val
                end
            end)
        end
        task.wait(0.05)
    end
end)

_G.stat_kill_signal = function() 
    active_loop = false
    pcall(function()
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.UseJumpPower = true
            hum.JumpPower = 50
            hum.MaxHealth = 100
            hum.Health = 100
            hum.HipHeight = 0
            hum.HealthDisplayDistance = 100
            hum.NameDisplayDistance = 100
            hum.Sitting = false
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum.RequiresNeck = true
            hum.AutoJump = false
        end
    end)
    _G.stat_kill_signal = nil
    getgenv().stat_settings = nil 
end
