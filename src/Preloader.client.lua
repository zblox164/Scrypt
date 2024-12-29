local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local PreloadUIs = {}

for _, UI: string in ipairs(PreloadUIs) do
	StarterGui:WaitForChild(UI)
end

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
for _, UI: GuiObject in ipairs(StarterGui:GetChildren()) do
	PlayerGui:WaitForChild(tostring(UI))
end

_G.Preloaded = true