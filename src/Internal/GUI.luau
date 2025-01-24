--[[
	@details
	Returns all GuiObject(s) in the PlayerGui

	@file GUI.luau (Scrypt)
    @client
    @author zblox164
    @version 0.0.43-alpha
    @since 2024-12-17
--]]

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()


-- Types
type GUI = {[string]: {[string]: GuiObject} | {Root: ScreenGui}}
type GUINamespace = typeof(setmetatable({}, {}))
type Result<T> = {Success: boolean, Value: T?, Error: string?}

-- Constants
local IGNORED_GUIS = table.freeze({"Freecam", "BubbleChat", "Chat"})

-- Function to wait for PlayerGui to be populated
local function WaitForPlayerGui(): PlayerGui
	local PlayerGui = Scrypt.LocalPlayer:WaitForChild("PlayerGui")

	for _, ScreenUI in ipairs(Scrypt.Services.StarterGui:GetChildren()) do
		if not ScreenUI:IsA("ScreenGui") then continue end
		PlayerGui:WaitForChild(ScreenUI.Name)
	end

	return PlayerGui:: PlayerGui
end

-- Validate element
local function ValidateGUIElement(element: Instance): Result<boolean>
    return {
        Success = not table.find(IGNORED_GUIS, element.Name),
        Value = element:IsA("ScreenGui") or element:IsA("GuiObject")
    }
end

-- Create GUI data
local function CreateGUIData(element: Instance, parent: Instance?): {[string]: any}
    if element:IsA("ScreenGui") then
        return {[element.Name] = {Root = element}}
    end

    return {[parent.Name] = {[element.Name] = element}}
end

local function MergeGUIData(existingGUIData: GUI, newGUIData: {[string]: any}): GUI
    local mergedGUIData = table.clone(existingGUIData)

    for screenName, screenContent in pairs(newGUIData) do
        mergedGUIData[screenName] = table.clone(mergedGUIData[screenName] or {})

        for elementName, guiObject in pairs(screenContent) do
            mergedGUIData[screenName][elementName] = guiObject
        end
    end

    return mergedGUIData
end

-- Scan UI elements
local function ScanUI(element: GuiObject | PlayerGui, parent: Instance?): GUI
    local result = {}

    for _, child in ipairs(element:GetChildren()) do
        local validation = ValidateGUIElement(child)
        if not validation.Success or not validation.Value then continue end

        local guiData = CreateGUIData(child, parent)
        result = MergeGUIData(result, guiData)

        if child:IsA("ScreenGui") or child:IsA("GuiObject") then
            result = MergeGUIData(result, ScanUI(child, child))
        end
    end

    return result
end

local function CreateProtectedInterface(raw: GUI): GUINamespace
    local protected = {}
    local metaTable = {
        __index = function(_, key: string)
            if raw[key] then
                return table.freeze(table.clone(raw[key]))
            end
            warn(string.format("[Scrypt] Invalid GUI access: '%s'", tostring(key)))
            return nil
        end,
        __newindex = function()
            warn("[Scrypt] Cannot modify GUI namespace")
            return nil
        end,
        __metatable = "Locked"
    }
    return setmetatable(protected, metaTable)
end

-- Initialize
local RawGUI = ScanUI(WaitForPlayerGui())
local ProtectedInterface = CreateProtectedInterface(RawGUI)

-- Monitor changes
WaitForPlayerGui().ChildAdded:Connect(function(element: Instance)
    if element:IsA("ScreenGui") and not table.find(IGNORED_GUIS, element.Name) then
        RawGUI = MergeGUIData(RawGUI, ScanUI(element))
    end
end)

return ProtectedInterface:: GUINamespace