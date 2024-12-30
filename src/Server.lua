--!strict
--[[
	@details
	Contains all functions and properties that are shared to the server

	@file Server.lua (Scrypt)
    @server
    @author zblox164
    @version 0.0.3-alpha
    @since 2024-12-17
--]]

--[=[
	@class ScryptServer
	@server
]=]

--[=[
	@interface Service
	.[Name] string
	.[Service] any
	@within ScryptServer
]=]

--[=[
	@prop Services {[string]: any}
	@within ScryptServer

	Returns all loaded Services.

	:::info
	Services are lazily loaded so just because a Service
	isn't contained within the Services table does not mean
	it cannot be accessed.
	:::
]=]

--[=[
	@prop RegExp RegularExpressionClass
	@within ScryptServer
	Regular expressions module published by Roblox. See more information in RegEx.lua.
]=]


--[=[
	@prop Promise PromiseClass
	@within ScryptServer
	Promise module created by evaera. 
]=]

--[=[
	@prop ServicesRBX {[Name]: Instance}
	@within ScryptServer
	Contains a dictionary of Roblox services.
]=]


--[=[
	@prop ServerNetwork ServerNetwork
	@within ScryptServer

	Returns the ServerNetwork class.
]=]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ScryptServer = {}
ScryptServer.Services = {}:: {[string]: any}
ScryptServer.Controllers = {}:: {[string]: any}
ScryptServer.Shared = {}
ScryptServer.LocalPlayer = newproxy():: Player -- For better Intellisense on the client

-- Modules
local Function = require(script.Parent.Internal.Function)
local RBXServices = require(script.Parent.Internal.RBXServices)
local Signal = require(script.Parent.Internal.Signal)
local Promise = require(script.Parent.Internal.Promise)
local Symbol = require(script.Parent.Internal.Symbol)
local RegularExpressions = require(script.Parent.Internal.LuauRegExp)
local Loaded = Signal.New("Loaded", true)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

-- For better Intellisense
local function ManualLoadModules()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- Internals
	-- local ArrayFunctions = require(ReplicatedStorage.Shared.Libraries.Array)
	-- ScryptServer.Shared.Array = ArrayFunctions

	-- local MathFunctions = require(ReplicatedStorage.Shared.Libraries.Math)
	-- ScryptServer.Shared.Math = MathFunctions

	-- local StringFunctions = require(ReplicatedStorage.Shared.Libraries.String)
	-- ScryptServer.Shared.String = StringFunctions

	-- local Utilities = require(ReplicatedStorage.Shared.Libraries.Utilities)
	-- ScryptServer.Shared.Utilities = Utilities

	-- Custom Modules
end

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

local function LoadSharedModules()
	local SharedFolder = RBXServices.ReplicatedStorage:WaitForChild("Shared")
	local Libraries = FindModules(SharedFolder:WaitForChild("Libraries"), {})
	local SharedAndLibraries = FindModules(RBXServices.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"), Libraries)

	return SharedAndLibraries
end

local function SetupBuiltInFeatures()
	ScryptServer.Promise = Promise
	ScryptServer.Symbol = Symbol
	ScryptServer.RegExp = RegularExpressions
	
	local Network = require(script.Parent.Internal.Network)
	ScryptServer.ServerNetwork = Network
	ScryptServer.ServerNetwork.Init()

	ScryptServer.ClientNetwork = {}:: ClientNetwork
	table.freeze(ScryptServer.ClientNetwork)

	--[=[
		Creates and returns a Signal. This is an implementation of BindableEvents.
		:::info What is IsPrivate?
		IsPrivate is an optional argument that toggles whether you want
		the event to be used in other scripts. By default this is set to false.
		:::

		@within ScryptServer
		@param Name string
		@param IsPrivate boolean?
		@return Signal
		@server
	]=]
	ScryptServer.CreateSignal = function(Name: string, IsPrivate: boolean?): Signal
		return Signal.New(Name, IsPrivate)
	end

	--[=[
		Creates and returns a Function. This is an implementation of BindableFunctions.
		:::info What is IsPrivate?
		IsPrivate is an optional argument that toggles whether you want
		the function to be used in other scripts. By default this is set to false.
		:::

		@within ScryptServer
		@param Name string
		@param IsPrivate boolean?
		@return Function
		@server
	]=]
	ScryptServer.CreateFunction = function(Name: string?, IsPrivate: boolean?): Function
		return Function.New(Name, IsPrivate)
	end
end

local function GetServices(EnvironmentLocation: Instance?): {[string]: ModuleScript}
	local ServiceList: {[string]: Service} = require(script.Parent.Internal.Services)(EnvironmentLocation or game:GetService("ServerScriptService"):WaitForChild("Services"), {})
	local Modules = {}

	for Name, Service in pairs(ServiceList) do
		Modules[Name] = Service.Service
	end

	return Modules
end

local function LoadDirectAccess()
	-- Built in access
	ManualLoadModules()
	ScryptServer.ServicesRBX = RBXServices
end

local function SetupFeatures(EnvironmentLocation: Instance?, DEBUG: boolean?)	
	local GameModules = GetServices(EnvironmentLocation)
	LazyLoad(GameModules, ScryptServer.Services, DEBUG)
	
	local SharedModules = LoadSharedModules()
	LazyLoad(SharedModules, ScryptServer.Shared, DEBUG)
	
	LoadDirectAccess()
	SetupBuiltInFeatures()
	
	Loaded:Fire()
end

--[=[
	Initializes the framework and loads all shared modules, libraries, and services.
	This function returns an event that fires once everything has been loaded. You can optionally specify
	the location of environment modules. By default, Scrypt assumes ServerScriptService.

	Usage example:
	```lua
	local Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))
	Scrypt.Init():Wait()

	print(Scrypt.ServicesRBX.ReplicatedStorage) -> ReplicatedStorage
	```
	:::caution
	If you are adding libraries, shared modules, or services, you do not have to wait for the framework to load.
	Doing so can cause issues.
	:::

	@param EnvironmentLocation Instance?
	@param DEBUG boolean?
	@return Signal
	@server
]=]
function ScryptServer.Init(EnvironmentLocation: Instance?, DEBUG: boolean?): Signal
	if RBXServices.RunService:IsStudio() then
		task.delay(0, SetupFeatures, EnvironmentLocation, DEBUG)
	else
		task.spawn(SetupFeatures, DEBUG)	
	end
	
	return Loaded
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Types
export type Service = {
	["Name"]: string,
	["Service"]: any
}

export type SharedModule = {[string]: any}

export type Signal = typeof(setmetatable({}:: {
	Connections: {Signal.SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: Signal.SignalImpl))

export type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: Function.FunctionImpl))

export type Packet = number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
export type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

type ClientNetwork = {
    SendPacket: (Name: string, Packet: ClientPacketData) -> (),
    PingServer: (Name: string, IsReliable: boolean) -> (),
    RequestPacket: (Name: string, Packet: ClientPacketData) -> Packet,
    EmptyRequest: (Name: string) -> Packet,
    ListenForPacket: (Name: string, IsReliable: boolean, Callback: (...ClientPacketData) -> ()) -> RBXScriptConnection,
    Init: () -> Folder,
}

return ScryptServer