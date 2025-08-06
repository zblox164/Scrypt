--!strict
--[[
	@details
	Contains all functions and properties that are shared to the server

	@file Server.lua (Scrypt)
    @server
    @author zblox164
    @version 0.0.52-alpha
    @since 2024-12-17
--]]

--[=[
	@class ScryptServer
	@server
	:::danger NOTICE
	Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
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
	@prop Monad MonadClass
	@within ScryptServer
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
local Symbol = require(script.Parent.Internal.Symbol)
local Monad = require(script.Parent.Internal.Monad)
local Loaded = Signal.New("Loaded", true)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Validates a module
local function ValidateModule(module: ModuleScript): Result<ModuleScript>
    if not module:IsA("ModuleScript") then
        return { Success = false, Error = "Invalid module type" }:: Result<ModuleScript>
    end

    return { Success = true, Value = module }:: Result<ModuleScript>
end

-- Validates if a module is unique
local function ValidateUnique(name: string, modules: {[string]: ModuleScript}): Result<string>
    if modules[name] then
        return { Success = false, Error = `{name} has already been loaded!` }:: Result<string>
    end

    return { Success = true, Value = name }:: Result<string>
end

-- Loads a module if it meets the criteria
local function LoadModule(module: ModuleScript, modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    local moduleValidation = ValidateModule(module)
    if not moduleValidation.Success then
        return { Success = false, Error = moduleValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local moduleName = tostring(module)
    local uniqueValidation = ValidateUnique(moduleName, modules)
    if not uniqueValidation.Success then
        return { Success = false, Error = uniqueValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local newModules = table.clone(modules)
    newModules[moduleName] = module
    return { Success = true, Value = newModules }:: Result<{[string]: ModuleScript}>
end

local function IsLoadableModule(node: Instance): boolean
    return node:IsA("ModuleScript") and not node:GetAttribute("ManualLoad")
end

-- Pure function to accumulate a table
local function Reduce<T, U>(Table: {T}, func: (accumulator: U, value: T) -> U, Initial: U): U
	assert(Table, "Table is not valid")
	assert(typeof(func) == "function", "Function expected as second argument")

	local result = Initial
	for _, v in ipairs(Table) do
		result = func(result, v)
	end

	return result
end

local function FindModules(root: Instance, modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    return Reduce(root:GetChildren(), function(accumulator: any, node: Instance)
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
    end, { Success = true, Value = table.clone(modules) })
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For better Intellisense (add modules here if you want them to be loaded manually)
local function ManualLoadModules()
	local replicatedStorage = game:GetService("ReplicatedStorage")

	-- Internals
	ScryptServer.Utils = require(replicatedStorage:WaitForChild("Scrypt"):WaitForChild("Internal"):WaitForChild("Utils"))

	-- Custom Modules
end

-- Function to lazily load modules (only loads when needed)
local function LazyLoad(moduleTable: {[string]: ModuleScript}, lazyLoadTable: {[string]: any}): {[string]: any}
	local function LoadHelper(ModuleName: string): (boolean, any)
		return pcall(function()
			local require = require
			return require(moduleTable[ModuleName])
		end)
	end

	-- Setup lazy loading
	setmetatable(lazyLoadTable, {
		__index = function(T, moduleName: string): any
			local success, loadedModule = LoadHelper(moduleName)

			if not success then
				warn(`Failed to load module '{moduleName}'. Error message: {tostring(loadedModule)}`)
			else
				T[moduleName] = loadedModule
			end

			return loadedModule
		end
	})

	return lazyLoadTable
end

-- Loads all shared modules
local function LoadSharedModules(): {[string]: ModuleScript}
	local sharedFolder = RBXServices.ReplicatedStorage:WaitForChild("Shared")
	local libraries = FindModules(sharedFolder:WaitForChild("Libraries"), {})

	assert(libraries.Success, libraries.Error)
	local sharedAndLibraries = FindModules(RBXServices.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"), libraries.Value:: {[string]: ModuleScript})

	assert(sharedAndLibraries.Success, sharedAndLibraries.Error)
	return sharedAndLibraries.Value:: {[string]: ModuleScript}
end

-- Loads all built in features
local function SetupBuiltInFeatures()
	ScryptServer.Symbol = Symbol
	ScryptServer.Monad = Monad

	local network = require(script.Parent.Internal.Network)
	ScryptServer.ServerNetwork = network
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
local function GetServices(environmentLocation: Instance?): {[string]: ModuleScript}
	local serviceList: {[string]: Service} = require(script.Parent.Internal.Services)(environmentLocation or game:GetService("ServerScriptService"):WaitForChild("Services"), {})
	local modules = {}

	for Name, Service in pairs(serviceList) do
		modules[Name] = Service.Service
	end

	return modules
end

-- Function to load directly accessable features
local function LoadDirectAccess()
	-- Built in access
	ManualLoadModules()
	ScryptServer.Services = RBXServices
	ScryptServer.GUI = {}:: GUI
end

local function SetupFeatures(EnvironmentLocation: Instance?)
	local gameModules = GetServices(EnvironmentLocation)
	LazyLoad(gameModules, Services)

	local sharedModules = LoadSharedModules()
	LazyLoad(sharedModules, Shared)

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
		task.defer(SetupFeatures)
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

type GUI = {[string]: {[string]: GuiObject}}
type SharedModule = {[string]: any}

type Maybe<T> = {
    bind: (fn: (T) -> Maybe<T>) -> Maybe<T>,
    map: (fn: (T) -> T) -> Maybe<T>,
    fromMaybe: (default: T) -> T,
    isJust: () -> boolean,
    isNothing: () -> boolean,
    value: T | nil,
}

type Signal = typeof(setmetatable({}:: {
	Connections: {Signal.SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: Signal.SignalImpl))

type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: Function.FunctionImpl))

type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor | {[string]: Packet}
type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

type ClientNetwork = {
    SendPacket: (Name: string, Packet: ClientPacketData) -> (),
    PingServer: (Name: string, IsReliable: boolean) -> (),
    RequestPacket: (Name: string, Packet: ClientPacketData) -> Packet,
    Request: (Name: string) -> Packet,
    ListenForPacket: (Name: string, IsReliable: boolean, Callback: (...ClientPacketData) -> ()) -> RBXScriptConnection,
    Listen: (Name: string, IsReliable: boolean, Callback: () -> ()) -> RBXScriptConnection,
    Init: () -> Folder,
}

return ScryptServer