--!strict
--[[
	@details
	An module containing functions to communicate with the server.

	@file ClientNetwork.luau
    @client
    @author zblox164
    @version 0.0.52-alpha
    @since 2024-12-17
--]]

--[=[
    @class ClientNetwork
    :::danger NOTICE
    Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
    :::
]=]
local ClientNetwork = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicate = require(script.Parent.Replicate)

--[=[
    @type Packet number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor | {[string]: Packet}
    @within ClientNetwork
]=]

--[=[
    @interface ClientPacketData
    .Data Packet
    .Reliable boolean
    @within ClientNetwork
]=]
export type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor | {[string]: Packet}
export type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

type Result<T> = {
    Success: boolean,
    Value: T?,
    Error: string?
}

-- Pure function to validate remote creation params
local function ValidateParams(name: string, remotes: Instance?): Result<string>
    if not name then
        return { Success = false, Error = "Expected string as first argument" }:: Result<string>
    end

    if not remotes then
        return { Success = false, Error = "Attempt to create function before network was loaded" }:: Result<string>
    end

    return { Success = true, Value = name }:: Result<string>
end

-- Creates and returns a function
local function CreateFunction(name: string): RemoteFunction
    assert(name, "Expected string as first argument.")

    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(remotes, "Attempt to create function before network was loaded!")

    local functions = remotes:FindFirstChild("Functions")
    assert(functions, "Attempt to create function before network was loaded!")

    local createRemote = functions:WaitForChild("CreateRemote"):: RemoteFunction
    local functionName = createRemote:InvokeServer(false, name):: string

    local Function = functions:WaitForChild(functionName)
    assert(Function, "Error creating function!")

    return Function:: RemoteFunction
end

-- Creates and returns a remote
local function CreateRemote(name: string, isSignal: boolean, isReliable: boolean): Instance
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(remotes, "Attempt to create remote before network was loaded!")

    local category = if isSignal then "Signals" else "Functions"
    local container = remotes:FindFirstChild(category)
    assert(container, "Attempt to create remote before network was loaded!")

    local functions = remotes:FindFirstChild("Functions")
    assert(functions, "Attempt to create remote before network was loaded!")

    local createRemoteFunc = functions:WaitForChild("CreateRemote"):: RemoteFunction
    local remoteName = createRemoteFunc:InvokeServer(isSignal, name, isReliable):: string

    local remote = container:WaitForChild(remoteName)
    assert(remote, "Error creating remote!")

    return remote
end

-- Function to get or create remote
local function GetOrCreateRemote(name: string, container: Folder, isReliable: boolean): Instance
    local existing = container:FindFirstChild(name)
    if existing then
        return existing
    end

    return CreateRemote(name, true, isReliable)
end

-- Finds unreliable signal based on name
local function GetUnreliableEvent(name: string, signals: Folder): UnreliableRemoteEvent
    local validation = ValidateParams(name, signals)
    assert(validation.Success, validation.Error)
    return GetOrCreateRemote(name, signals, false):: UnreliableRemoteEvent
end

-- Finds signal based on name
local function GetEvent(name: string, signals: Folder): RemoteEvent
    local validation = ValidateParams(name, signals)
    assert(validation.Success, validation.Error)
    return GetOrCreateRemote(name, signals, true):: RemoteEvent
end

-- Finds signal based on name and reliability
local function FindSignal(name: string, signals: Folder, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local newSignal = if isReliable then GetEvent(name, signals) else GetUnreliableEvent(name, signals)
    assert(newSignal.ClassName == "RemoteEvent" or newSignal.ClassName == "UnreliableRemoteEvent", "Error finding signal " .. name)

    return newSignal
end

-- Returns a function based on the name and creates one if it does not exist
local function ReturnFunction(name: string): RemoteFunction
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(remotes, "Attempt to use function before network was loaded!")

    local functions = remotes:FindFirstChild("Functions")
    assert(functions, "Attempt to use function before network was loaded!")

    local newFunction: RemoteFunction = functions:FindFirstChild(name):: RemoteFunction

    if not newFunction then
        newFunction = CreateFunction(name)
    end

    assert(newFunction, "Error finding signal " .. name)
    return newFunction
end

-- Returns a signal based on the name and reliability
local function ReturnSignal(name: string, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(remotes, "Attempt to use signal before network was loaded!")

    local signals = remotes:FindFirstChild("Signals"):: Folder
    assert(signals, "Attempt to use signal before network was loaded!")

    local newSignal = FindSignal(name, signals, isReliable)
    assert(newSignal, "Error finding signal " .. name)

    return newSignal
end

--[=[
    @return Folder
    @yields
    @private
    @within ClientNetwork
]=]
function ClientNetwork.Init(): Folder
    local location: Folder = ReplicatedStorage:WaitForChild("ScryptCommunication"):: Folder
    location:WaitForChild("Signals")
    location:FindFirstChild("Functions")

    return location
end

--[=[
    @param Name string
    @param PacketData ClientPacketData
    @within ClientNetwork
    Sends data to the server.
]=]
function ClientNetwork.SendPacket(Name: string, PacketData: ClientPacketData)
    assert(Name, "Expected string as first argument.")
    assert(PacketData, "Expected ClientPacketData as second argument.")

    local signal = ReturnSignal(Name, PacketData.Reliable)
    if signal:IsA("RemoteEvent") then
        (signal:: RemoteEvent):FireServer(PacketData.Data)
    else
        (signal:: UnreliableRemoteEvent):FireServer(PacketData.Data)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @within ClientNetwork
    Pings the server. This function should be used when you want to communicate with the server but don't want to send any data.
]=]
function ClientNetwork.PingServer(Name: string, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as second argument.")

    local signal = ReturnSignal(Name, IsReliable)
    if signal:IsA("RemoteEvent") then
        (signal:: RemoteEvent):FireServer()
    else
        (signal:: UnreliableRemoteEvent):FireServer()
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @param Callback (...Packet) -> ()
    @return RBXScriptConnection
    @within ClientNetwork
    Listens for data from the server.
]=]
function ClientNetwork.ListenForPacket(Name: string, IsReliable: boolean, Callback: (...Packet) -> ()): RBXScriptConnection
    assert(Name, "Expected string as first argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as second argument.")
    assert(Callback, "Expected function as third argument.")

    local connection
    local signal = ReturnSignal(Name, IsReliable)
    connection = (signal.OnClientEvent:: RBXScriptSignal):Connect(function(IsInstance: boolean, Packet: Packet)
        if IsInstance then
            Callback(typeof(Packet) ~= "string" or Replicate.new(nil, Packet))
        else
            Callback(Packet)
        end
    end)

    return connection
end

--[=[
    @param Name string
    @param IsReliable boolean
    @param Callback () -> ()
    @return RBXScriptConnection
    @within ClientNetwork
    Listens for signals from the server without sending data.
]=]
function ClientNetwork.Listen(Name: string, IsReliable: boolean, Callback: () -> ()): RBXScriptConnection
    assert(Name, "Expected string as first argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as second argument.")
    assert(Callback, "Expected function as third argument.")

    local connection
    local signal = ReturnSignal(Name, IsReliable)
    connection = (signal.OnClientEvent:: RBXScriptSignal):Connect(function(IsInstance: boolean)
        Callback()
    end)

    return connection
end

--[=[
    @param Name string
    @param Packet Packet
    @return Packet
    @yields
    @within ClientNetwork
    Sends and requests data from the server.
]=]
function ClientNetwork.RequestPacket(Name: string, Packet: Packet): Packet
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected Packet as second argument.")

    local Function = ReturnFunction(Name)
    local request = Function:InvokeServer(Packet)
    return request
end

--[=[
    @param Name string
    @yields
    @within ClientNetwork
    Requests a packet from the server without sending data. This function should be used when you want to request a response from the server but don't want to send any data.
]=]
function ClientNetwork.Request(Name: string): Packet
    assert(Name, "Expected string as first argument.")

    local Function = ReturnFunction(Name)
    local request = Function:InvokeServer()
    return request
end

type ClientNetwork = {
    SendPacket: (Name: string, Packet: ClientPacketData) -> (),
    PingServer: (Name: string, IsReliable: boolean) -> (),
    RequestPacket: (Name: string, Packet: ClientPacketData) -> Packet,
    Request: (Name: string) -> Packet,
    ListenForPacket: (Name: string, IsReliable: boolean, Callback: (...ClientPacketData) -> ()) -> RBXScriptConnection,
    Listen: (Name: string, IsReliable: boolean, Callback: () -> ()) -> RBXScriptConnection,
    Init: () -> Folder,
}

return ClientNetwork