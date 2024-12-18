--!strict
--[[

     Scrypt Framework [2024 - 2025] 
     
     DO NOT use without permission from the owner.
     Written by: zblox164
     
--]]

--[=[
	@class ScryptClient
	@client
]=]

--[=[
	@interface Controller
	.[Name] string
	.[Controller] any
	@within ScryptClient
]=]

--[=[
	@prop Controllers {[string]: any}
	@within ScryptClient

	Returns all loaded Controllers.

	:::info
	Controllers are lazily loaded so just because a Controller
	isn't contained within the Controllers table does not mean
	it cannot be accessed.
	:::
]=]

--[=[
	@prop RegExp RegularExpressionClass
	@within ScryptClient
	Regular expressions module published by Roblox. See more information in RegEx.lua.
]=]


--[=[
	@prop Promise PromiseClass
	@within ScryptClient
	Promise module created by evaera. 
]=]

--[=[
	@prop LocalPlayer Player
	@within ScryptClient
]=]

--[=[
	@prop ServicesRBX {[Name]: Instance}
	@within ScryptClient
	Contains a dictionary of Roblox services.
]=]


--[=[
	@prop ClientNetwork ClientNetwork
	@within ScryptClient

	Returns the ClientNetwork class.
]=]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ScryptClient = {}
ScryptClient.Controllers = {}:: {[string]: any}
ScryptClient.Shared = {}:: {[string]: any}

-- Modules
local Function = require(script.Parent.Internal.Function)
local RBXServices = require(script.Parent.Internal.RBXServices)
local Signal = require(script.Parent.Internal.Signal)
local Promise = require(script.Parent.Internal.Promise)
local Symbol = require(script.Parent.Internal.Symbol)
local RegularExpressions = require(script.Parent.Internal.LuauRegExp)
local Loaded = Signal.New("Loaded", true)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For better Intellisense
local function ManualLoadModules()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	-- Internals
	-- local ArrayFunctions = require(ReplicatedStorage.Shared.Libraries.Array)
	-- ScryptClient.Shared.Array = ArrayFunctions
	
	-- local MathFunctions = require(ReplicatedStorage.Shared.Libraries.Math)
	-- ScryptClient.Shared.Math = MathFunctions
	
	-- local StringFunctions = require(ReplicatedStorage.Shared.Libraries.String)
	-- ScryptClient.Shared.String = StringFunctions
	
	-- local Utilities = require(ReplicatedStorage.Shared.Libraries.Utilities)
	-- ScryptClient.Shared.Utilities = Utilities
	
	-- Custom Modules
end

-- Loads a module if it meets the criteria
local function LoadModule(Module: ModuleScript, Modules: {[string]: ModuleScript}): {[string]: ModuleScript}
	if Module.ClassName ~= "ModuleScript" then return Modules end

	local ModuleName = tostring(Module)
	if Modules[ModuleName] then 
		error(`{ModuleName} has already been loaded!`) 
	end

	-- Add the module to a new table
	local NewModules = table.clone(Modules)
	NewModules[ModuleName] = Module
	return NewModules
end

-- Recursively finds modules starting from the root
local function FindModules(Root: Instance, Modules: {[string]: ModuleScript}): {[string]: ModuleScript}
	local CurrentModules = table.clone(Modules)

	for _, Node: Instance in ipairs(Root:GetChildren()) do
		if Node:IsA("ModuleScript") and not Node:GetAttribute("ManualLoad") then
			CurrentModules = LoadModule(Node, CurrentModules)
		elseif #Node:GetChildren() > 0 then
			CurrentModules = FindModules(Node, CurrentModules)
		end
	end

	return CurrentModules
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function LazyLoad(ModuleTable: {[string]: ModuleScript}, LazyLoadTable: {[string]: any}, DEBUG: boolean?): {[string]: any}
	local function LoadHelper(ModuleName: string): (boolean, any)
		return pcall(function()
			local require = require
			return require(ModuleTable[ModuleName])
		end)
	end

	local function PrintDebugInfo(Message: string)
		if DEBUG then
			warn(Message)
		end
	end

	-- Setup lazy loading
	setmetatable(LazyLoadTable, {
		__index = function(T, ModuleName: string): any
			local Success, LoadedModule = LoadHelper(ModuleName)

			if not Success then 
				warn(`Failed to load module '{ModuleName}'. Error message: {tostring(LoadedModule)}`)
			else
				T[ModuleName] = LoadedModule
				PrintDebugInfo(`Loaded module: '{ModuleName}'`)
			end

			return LoadedModule
		end
	})
	
	return LazyLoadTable
end

local function WaitForLocalPlayer(Players: Players): Player
	local Player = Players.LocalPlayer or function()
		while not Players.LocalPlayer do
			task.wait()
		end
		
		return Players.LocalPlayer
	end
	
	return Player:: Player
end

-- Waits for assets to be preloaded
local function WaitForAssets()
	repeat
		task.wait()
	until _G.Preloaded
end

local function LoadSharedModules()
	local SharedFolder = RBXServices.ReplicatedStorage:WaitForChild("Shared")
	local Libraries = FindModules(SharedFolder:WaitForChild("Libraries"), {})
	local SharedAndLibraries = FindModules(RBXServices.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"), Libraries)

	return SharedAndLibraries
end

local function SetupBuiltInFeatures()
	ScryptClient.Promise = Promise
	ScryptClient.Symbol = Symbol
	ScryptClient.RegExp = RegularExpressions
	
	local Network = require(script.Parent.Internal.Network)
	ScryptClient.ClientNetwork = Network
	ScryptClient.ClientNetwork.Init()
	
	--[=[
		Creates and returns a Signal. This is an implementation of BindableEvents.
		:::info What is IsPrivate?
		IsPrivate is an optional argument that toggles whether you want
		the event to be used in other scripts. By default this is set to false.
		:::

		@within ScryptClient
		@param Name string
		@param IsPrivate boolean?
		@return Signal
		@client
	]=]
	ScryptClient.CreateSignal = function(Name: string, IsPrivate: boolean?): Signal
		return Signal.New(Name, IsPrivate)
	end

	--[=[
		Creates and returns a Function. This is an implementation of BindableFunctions.
		:::info What is IsPrivate?
		IsPrivate is an optional argument that toggles whether you want
		the function to be used in other scripts. By default this is set to false.
		:::

		@within ScryptClient
		@param Name string
		@param IsPrivate boolean?
		@return Function
		@client
	]=]
	ScryptClient.CreateFunction = function(Name: string?, IsPrivate: boolean?): Function
		return Function.New(Name, IsPrivate)
	end
end

local function GetGameModules(EnvironmentLocation: Instance?): {[string]: ModuleScript}
	local ControllerList: {[string]: Controller} = require(script.Parent.Internal.Controllers)(EnvironmentLocation or RBXServices.ReplicatedStorage:WaitForChild("Controllers"), {})
	local Modules = {}

	for Name, Controller in pairs(ControllerList) do
		Modules[Name] = Controller.Controller
	end

	return Modules
end

local function LoadDirectAccess()
	-- Built in access
	ManualLoadModules()
	ScryptClient.ServicesRBX = RBXServices
	ScryptClient.LocalPlayer = WaitForLocalPlayer(RBXServices.Players)
	ScryptClient.GUI = {}:: {[string]: {[string]: GuiObject}}
	ScryptClient.GUI = nil:: any	
end

local function SetupFeatures(EnvironmentLocation: Instance?, DEBUG: boolean?)
	WaitForAssets()
	
	local GameModules = GetGameModules(EnvironmentLocation)
	LazyLoad(GameModules, ScryptClient.Controllers, DEBUG)
	
	LoadDirectAccess()
	
	local SharedModules = LoadSharedModules()
	LazyLoad(SharedModules, ScryptClient.Shared, DEBUG)
	
	SetupBuiltInFeatures()
	
	Loaded:Fire()
end

--[=[
	Initializes the framework and loads all shared modules, libraries, and controllers.
	This function returns an event that fires once everything has been loaded. You can optionally specify
	the location of environment modules. By default, Scrypt assumes ReplicatedStorage.
	
	Usage example:
	```lua
	local Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))
	Scrypt.Init():Wait()

	print(Scrypt.LocalPlayer) -> zblox164
	```
	:::caution
	If you are adding libraries, shared modules, or controllers, you do not have to wait for the framework to load.
	Doing so can cause issues.
	:::

	@param EnvironmentLocation Instance?
	@param DEBUG boolean?
	@return Signal
	@client
]=]
function ScryptClient.Init(EnvironmentLocation: Instance?, DEBUG: boolean?): Signal
	task.spawn(SetupFeatures, EnvironmentLocation, DEBUG)	
	return Loaded
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Types
export type Controller = {
	["Name"]: string,
	["Controller"]: any
}

export type Signal = typeof(setmetatable({}:: {
	Connections: {Signal.SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: Signal.SignalImpl))

export type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: Function.FunctionImpl))

return ScryptClient