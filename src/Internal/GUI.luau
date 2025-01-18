--[[
	@details
	Returns all GuiObject(s) in the PlayerGui

	@file GUI.lua (Scrypt)
    @client
    @author zblox164
    @version 0.0.42-alpha
    @since 2024-12-17
--]]

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

type GUI = {[string]: {[string]: GuiObject}}

local GUI = {}:: GUI

-- Variables
local IgnoredGUIS = {"Freecam", "BubbleChat", "Chat"}
local PlayerGui: PlayerGui

-- Function to wait for PlayerGui to be populated
local function WaitForPlayerGui(): PlayerGui	
	local PlayerGui = Scrypt.LocalPlayer:WaitForChild("PlayerGui")

	for _, ScreenUI in ipairs(Scrypt.Services.StarterGui:GetChildren():: {GuiObject}) do
		if not ScreenUI:IsA("ScreenGui") then continue end
		PlayerGui:WaitForChild(ScreenUI.Name)
	end

	return PlayerGui:: PlayerGui
end

-- Scan The GUI To Add The Index To It
local function ScanUI(Element: GuiObject | PlayerGui, Parent: Instance?)
	-- Loops Through All The GUI Instances
	for _, Child in ipairs(Element:GetChildren()) do
		-- If The Child Is A ScreenGui and Its Name Is Not In The ignoredGUIS, Add It To The table
		if Child.ClassName == "ScreenGui" and (not table.find(IgnoredGUIS, Child.Name)) then
			GUI[Child.Name] = {Gui = Child}
			ScanUI(Child, Child)
		elseif Child:IsA("GuiObject") and Parent then		
			local Exists = GUI[Parent.Name][Child.Name]
			if Exists then continue end

			-- Continue Scanning The Child's Children Recursively.
			GUI[Parent.Name][Child.Name] = Child
			ScanUI(Child:: GuiObject, Parent)
		end 
	end
end

-- Runs The Function When The Player Joins
PlayerGui = WaitForPlayerGui()
ScanUI(PlayerGui)

-- Loops Through Any UIS Added And Adds It to The GUI Module
PlayerGui.ChildAdded:Connect(function(Element: Instance)
	if Element.ClassName ~= "ScreenGui" then return end
	if table.find(IgnoredGUIS, Element.Name) then return end

	GUI[Element.Name] = {Gui = Element}	
	ScanUI(Element, Element)
end)

return GUI