--!strict
--[[
	@details
	Contains all functions and properties that are shared to the server

	@file Server.lua (Scrypt)
    @server
    @author zblox164
    @version 0.0.4-alpha
    @since 2024-12-17
--]]

--[=[
	@class ScryptServer
	@server
	:::danger NOTICE
	Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.
	:::
]=]

--[=[
	@interface Service
	.[Name] string
	.[Service] any
	@within ScryptServer
]=]

--[=[
	@type Result<T> {Success: boolean, Value: T?, Error: string?}
	@within ScryptServer
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
	@prop Services {[Name]: Instance}
	@within ScryptServer
	Contains a dictionary of Roblox services.
]=]

--[=[
	@prop Utils {(...any) -> ...any}
	@within ScryptServer
	Returns the Utils module. Contains some basic pure functions.
]=]

--[=[
	@prop ServerNetwork ServerNetwork
	@within ScryptServer

	Returns the ServerNetwork class.
]=]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ScryptServer = {}
local Services = {}:: {[string]: any}
local Shared = {}
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

-- Validates a module
local function ValidateModule(Module: ModuleScript): Result<ModuleScript>
    if not Module:IsA("ModuleScript") then
        return { Success = false, Error = "Invalid module type" }:: Result<ModuleScript>
    end

    return { Success = true, Value = Module }:: Result<ModuleScript>
end

-- Validates if a module is unique
local function ValidateUnique(Name: string, Modules: {[string]: ModuleScript}): Result<string>
    if Modules[Name] then
        return { Success = false, Error = `{Name} has already been loaded!` }:: Result<string>
    end

    return { Success = true, Value = Name }:: Result<string>
end

-- Loads a module if it meets the criteria
local function LoadModule(Module: ModuleScript, Modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    local ModuleValidation = ValidateModule(Module)
    if not ModuleValidation.Success then
        return { Success = false, Error = ModuleValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local ModuleName = tostring(Module)
    local UniqueValidation = ValidateUnique(ModuleName, Modules)
    if not UniqueValidation.Success then
        return { Success = false, Error = UniqueValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local NewModules = table.clone(Modules)
    NewModules[ModuleName] = Module
    return { Success = true, Value = NewModules }:: Result<{[string]: ModuleScript}>
end

local function IsLoadableModule(Node: Instance): boolean
    return Node:IsA("ModuleScript") and not Node:GetAttribute("ManualLoad")
end

-- Pure function to accumulate a table
local function Reduce<T, U>(Table: {T}, Func: (accumulator: U, value: T) -> U, Initial: U): U
	assert(Table, "Table is not valid")
	assert(typeof(Func) == "function", "Function expected as second argument")

	local Result = Initial
	for _, v in ipairs(Table) do
		Result = Func(Result, v)
	end

	return Result
end

local function FindModules(Root: Instance, Modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    return Reduce(Root:GetChildren(), function(accumulator: any, node: Instance)
        if not accumulator.Success then
            return accumulator
        end

        if IsLoadableModule(node) then
            return LoadModule(node :: ModuleScript, accumulator.Value)
        end
        
        if #node:GetChildren() > 0 then
            return FindModules(node, accumulator.Value)
        end
        
        return accumulator
    end, { Success = true, Value = table.clone(Modules) })
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For better Intellisense (add modules here if you want them to be loaded manually)
local function ManualLoadModules()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- Internals
	ScryptServer.Utils = require(ReplicatedStorage:WaitForChild("Scrypt"):WaitForChild("Internal"):WaitForChild("Utils"))
	

	-- Custom Modules
end

-- Function to lazily load modules (only loads when needed)
local function LazyLoad(ModuleTable: {[string]: ModuleScript}, LazyLoadTable: {[string]: any}): {[string]: any}
	local function LoadHelper(ModuleName: string): (boolean, any)
		return pcall(function()
			local require = require
			return require(ModuleTable[ModuleName])
		end)
	end

	-- Setup lazy loading
	setmetatable(LazyLoadTable, {
		__index = function(T, ModuleName: string): any
			local Success, LoadedModule = LoadHelper(ModuleName)

			if not Success then 
				warn(`Failed to load module '{ModuleName}'. Error message: {tostring(LoadedModule)}`)
			else
				T[ModuleName] = LoadedModule
			end

			return LoadedModule
		end
	})

	return LazyLoadTable
end

-- Loads all shared modules
local function LoadSharedModules(): {[string]: ModuleScript}
	local SharedFolder = RBXServices.ReplicatedStorage:WaitForChild("Shared")
	local Libraries = FindModules(SharedFolder:WaitForChild("Libraries"), {})
	
	assert(Libraries.Success, Libraries.Error)
	local SharedAndLibraries = FindModules(RBXServices.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"), Libraries.Value:: {[string]: ModuleScript})

	assert(SharedAndLibraries.Success, SharedAndLibraries.Error)
	return SharedAndLibraries.Value:: {[string]: ModuleScript}
end

-- Loads all built in features
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

-- Function to get all services
local function GetServices(EnvironmentLocation: Instance?): {[string]: ModuleScript}
	local ServiceList: {[string]: Service} = require(script.Parent.Internal.Services)(EnvironmentLocation or game:GetService("ServerScriptService"):WaitForChild("Services"), {})
	local Modules = {}

	for Name, Service in pairs(ServiceList) do
		Modules[Name] = Service.Service
	end

	return Modules
end

-- Function to load directly accessable features
local function LoadDirectAccess()
	-- Built in access
	ManualLoadModules()
	ScryptServer.Services = RBXServices
end

local function SetupFeatures(EnvironmentLocation: Instance?)	
	local GameModules = GetServices(EnvironmentLocation)
	LazyLoad(GameModules, Services)
	
	local SharedModules = LoadSharedModules()
	LazyLoad(SharedModules, Shared)
	
	LoadDirectAccess()
	SetupBuiltInFeatures()
	
	Loaded:Fire()
end

function ScryptServer.GetController(Name: string): any
	return error("CANNOT BE RUN ON SERVER")
end

--[=[
	Loads and returns a Service by name. Services are lazily loaded so they are only run when this function is invoked.

	@within ScryptServer
	@param Name string
	@return any
	@client
]=]
function ScryptServer.GetService(Name: string): any
	return Services[Name]
end

--[=[
	Loads and returns a shared module by name. Shared modules are lazily loaded so they are only run when this function is invoked.

	@within ScryptServer
	@param Name string
	@return any
	@client
]=]
function ScryptServer.GetModule(Name: string): any
	return Shared[Name]
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
	@return Signal
	@server
]=]
function ScryptServer.Init(EnvironmentLocation: Instance?): Signal
	if RBXServices.RunService:IsStudio() then
		task.delay(0, SetupFeatures, EnvironmentLocation)
	else
		task.spawn(SetupFeatures)
	end
	
	return Loaded
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Types
type Service = {
	["Name"]: string,
	["Service"]: any
}

type Result<T> = {
    Success: boolean,
    Value: T?,
    Error: string?
}

type SharedModule = {[string]: any}

type Signal = typeof(setmetatable({}:: {
	Connections: {Signal.SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: Signal.SignalImpl))

type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: Function.FunctionImpl))

type Packet = number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

type ClientNetwork = {
    SendPacket: (Name: string, Packet: ClientPacketData) -> (),
    PingServer: (Name: string, IsReliable: boolean) -> (),
    RequestPacket: (Name: string, Packet: Packet) -> Packet,
    EmptyRequest: (Name: string) -> Packet,
    ListenForPacket: (Name: string, IsReliable: boolean, Callback: (...ClientPacketData) -> ()) -> RBXScriptConnection,
    Init: () -> Folder,
}

return ScryptServer