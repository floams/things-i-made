local Event = game:GetService("Players").LocalPlayer.PlayerGui.StatEditor.RemoteEvent

Event:FireServer("HealthDisplayDistance", -1, 1, 10, nil)

-- use the glasses first
-- change the first value to how many points you want, but make it negative
