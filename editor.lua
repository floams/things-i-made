-- optimized raw execution payload
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

-- state tracking variables to detect changes
local active_loop = true
local last_stat = nil
local last_val = nil

-- loop 1: handles firing server remote events safely (only on setting change)
task.spawn(function()
    while active_loop do
        local settings = getgenv().stat_settings
        if settings then
            local current_stat = tostring(settings["stat"]):lower():gsub("%s+", "")
            local is_bool = table.find(boolean_stats, current_stat) ~= nil
            local current_val = is_bool and settings["boolean"] or tonumber(settings["modification"])
            
            -- only trigger network network requests if a user configurations change is detected
            if current_stat ~= last_stat or current_val ~= last_val then
                last_stat = current_stat
                last_val = current_val
                
                local remote_key = server_string_map[current_stat]
                if remote_key and current_val ~= nil then
                    pcall(function()
                        local playerGui = localPlayer:WaitForChild("PlayerGui", 2)
                        local statEditor = playerGui and playerGui:FindFirstChild("StatEditor")
                        local event = statEditor and statEditor:FindFirstChild("RemoteEvent")
                        if event then
                            -- fire a controlled burst to override server validations safely
                            for i = 1, 10 do 
                                event:FireServer(remote_key, 1, 1, current_val, nil) 
                            end
                            if firesignal then firesignal(event.OnClientEvent, true) end
                        end
                    end)
                end
            end
        end
        task.wait(0.5) -- check for user manual table changes twice a second
    end
end)

-- loop 2: ultra-fast local physics property enforcement
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
                if target_key == "walkspeed" and hum.WalkSpeed ~= final_val then hum.WalkSpeed = final_val
                elseif target_key == "jumppower" then hum.UseJumpPower = true; if hum.JumpPower ~= final_val then hum.JumpPower = final_val end
                elseif target_key == "maxhealth" and hum.MaxHealth ~= final_val then hum.MaxHealth = final_val
                elseif target_key == "health" and hum.Health ~= final_val then hum.Health = final_val
                elseif target_key == "hipheight" and hum.HipHeight ~= final_val then hum.HipHeight = final_val
                elseif target_key == "healthdisplaydistance" and hum.HealthDisplayDistance ~= final_val then hum.HealthDisplayDistance = final_val
                elseif target_key == "namedisplaydistance" and hum.NameDisplayDistance ~= final_val then hum.NameDisplayDistance = final_val
                elseif target_key == "sitting" and hum.Sitting ~= final_val then hum.Sitting = final_val
                elseif target_key == "platformstand" and hum.PlatformStand ~= final_val then hum.PlatformStand = final_val
                elseif target_key == "autorotate" and hum.AutoRotate ~= final_val then hum.AutoRotate = final_val
                elseif target_key == "requiresneck" and hum.RequiresNeck ~= final_val then hum.RequiresNeck = final_val
                elseif target_key == "autojump" and hum.AutoJump ~= final_val then hum.AutoJump = final_val
                end
            end)
        end
        task.wait(0.1) -- keeps physics locked tightly without dropping server performance
    end
end)

_G.stat_kill_signal = function() active_loop = false; _G.stat_kill_signal = nil; getgenv().stat_settings = nil end
