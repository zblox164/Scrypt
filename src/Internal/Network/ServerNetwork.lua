--!strict
--[[
	@details
	An module containing functions to communicate with the client.

	@file ClientNetwork.lua
    @server
    @author zblox164
    @version 0.0.2-alpha
    @since 2024-12-17
--]]

--[=[
    @class ServerNetwork
]=]
local ServerNetwork = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[=[
    @type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
    @within ServerNetwork
]=]

--[=[
    @interface ServerPacketData
    .Address Player
    .Reliable boolean
    .Data Packet
    @within ServerNetwork
    :::info
    Currently, changing the .Reliable value does not affect the type of signal that is created. This will be implemented in a later version.
    :::
]=]
export type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
export type ServerPacketData = {
    Address: Player,
    Reliable: boolean,
    Data: Packet
}

-- Creates and returns signal
local function CreateSignal(Name: string, Location: Instance, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    assert(Name, "Expected string as first argument.")
    assert(Name, "Expected Instance as second argument.")

    local NewSignal = if IsReliable then Instance.new("RemoteEvent") else Instance.new("UnreliableRemoteEvent")
    NewSignal.Name = Name
    NewSignal.Parent = Location

    return NewSignal
end

-- Creates and returns function
local function CreateFunction(Name: string, Location: Instance): RemoteFunction
    assert(Name, "Expected string as first argument.")
    assert(Name, "Expected Instance as second argument.")

    local NewFunction = Instance.new("RemoteFunction")
    NewFunction.Name = Name
    NewFunction.Parent = Location

    return NewFunction
end

local function GetUnreliableEvent(Name: string, Signals: Folder): UnreliableRemoteEvent
    local NewSignal: UnreliableRemoteEvent = Signals:FindFirstChild(Name):: UnreliableRemoteEvent
    if not NewSignal then
        NewSignal = CreateSignal(Name, Signals, false):: UnreliableRemoteEvent
    end

    assert(NewSignal, "Error finding signal " .. Name)
    return NewSignal
end

local function GetEvent(Name: string, Signals: Folder): RemoteEvent
    local NewSignal: RemoteEvent = Signals:FindFirstChild(Name):: RemoteEvent
    if not NewSignal then
        NewSignal = CreateSignal(Name, Signals, true):: RemoteEvent
    end

    assert(NewSignal, "Error finding signal " .. Name)
    return NewSignal
end

local function FindSignal(Name: string, Signals: Folder, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local NewSignal = if IsReliable then GetEvent(Name, Signals) else GetUnreliableEvent(Name, Signals)
    assert(NewSignal.ClassName == "RemoteEvent" or NewSignal.ClassName == "UnreliableRemoteEvent", "Error finding signal " .. Name)

    return NewSignal
end

-- Returns a signal based on the name and reliability
local function ReturnSignal(Name: string, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(Remotes, "Attempt to use event before network was loaded!")

    local Signals = Remotes:FindFirstChild("Signals"):: Folder
    assert(Signals, "Attempt to use event before network was loaded!")
    
    local NewSignal = FindSignal(Name, Signals, IsReliable)
    assert((NewSignal.ClassName == "RemoteEvent" and IsReliable) or (NewSignal.ClassName == "UnreliableRemoteEvent" and not IsReliable), 
        "Incorrect remote type! Remotes between the client and server may be out of sync! Signal name: " .. Name)
    return NewSignal
end

-- Returns a function based on the name
local function GetFunction(Name: string): RemoteFunction
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(Remotes, "Attempt to use function before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to use function before network was loaded!")

    local NewFunction: RemoteFunction = Functions:FindFirstChild(Name):: RemoteFunction
    if not NewFunction then
        NewFunction = CreateFunction(Name, Functions)
    end

    assert(NewFunction, "Error finding signal " .. Name)
    return NewFunction
end

-- Creates a remote based on the type
local function CreateClientRemote(Player: Player, IsFunction: boolean, Name: string, Reliable: boolean?): Instance
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Not initialized")

    local Signals = Remotes:FindFirstChild("Signals"):: Folder
    assert(Signals, "Signals not loaded!")

    local RemoteCheck = Signals:FindFirstChild(Name):: RemoteEvent? | UnreliableRemoteEvent?
    if IsFunction and RemoteCheck then
        if Reliable and RemoteCheck.ClassName == "RemoteEvent" then 
            return RemoteCheck
        elseif not Reliable and RemoteCheck.ClassName == "UnreliableRemoteEvent" then
            return RemoteCheck
        end

        error("Remote already exists with different type! Server and client remotes may be out of sync!")
    end

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Functions not loaded")

    local FunctionCheck = Signals:FindFirstChild(Name):: RemoteFunction?
    if IsFunction and FunctionCheck then return FunctionCheck end
    if not IsFunction and FunctionCheck then return FunctionCheck end

    local RemoteType
    if IsFunction then
        RemoteType = if Reliable then "RemoteEvent" else "UnreliableRemoteEvent"
    else
        RemoteType = "RemoteFunction"
    end

    local NewRemote = Instance.new(RemoteType)
    NewRemote.Name = Name
    NewRemote.Parent = if IsFunction then Signals else Functions
    return NewRemote
end

--[=[
    @return Folder
    @yields
    @private
    @within ServerNetwork
]=]
function ServerNetwork.Init(): Folder
    local Location: Folder = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    if not Location then
        Location = Instance.new("Folder"):: Folder
        Location.Name = "ScryptCommunication"
        Location.Parent = ReplicatedStorage
    end

    if not Location:FindFirstChild("Signals") then
        local SignalFolder = Instance.new("Folder")
        SignalFolder.Name = "Signals"
        SignalFolder.Parent = Location
    end

    if not Location:FindFirstChild("Functions") then
        local FunctionFolder = Instance.new("Folder")
        FunctionFolder.Name = "Functions"
        FunctionFolder.Parent = Location

        if not FunctionFolder:FindFirstChild("CreateRemote") then
            local NewRemote = Instance.new("RemoteFunction")
            NewRemote.Name = "CreateRemote"
            NewRemote.Parent = FunctionFolder

            NewRemote.OnServerInvoke = CreateClientRemote
        end
    end

    return Location
end

--[=[
    @param Name string
    @param PacketData ServerPacketData
    @within ServerNetwork
    Sends data to a specific player from the server.
]=]
function ServerNetwork.SendPacketToPlayer(Name: string, PacketData: ServerPacketData)
    assert(Name, "Expected string as first argument.")
    assert(PacketData, "Expected ServerPacketData as second argument.")
    
    local Signal = ReturnSignal(Name, PacketData.Reliable)
    if Signal.ClassName == "RemoteEvent" then
        (Signal:: RemoteEvent):FireClient(PacketData.Address, PacketData.Data)
    else
        (Signal:: UnreliableRemoteEvent):FireClient(PacketData.Address, PacketData.Data)
    end
end

--[=[
    @param Name string
    @param Packet Packet
    @param IsReliable boolean
    @within ServerNetwork
    Sends data to all players in a server.
]=]
function ServerNetwork.SendPacketToAllPlayers(Name: string, Packet: Packet, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected ServerPacketData as second argument.")

    for _, player in ipairs(Players:GetPlayers()) do
        local PlayerPacket = {
            Address = player,
            Data = Packet,
            Reliable = IsReliable
        }:: ServerPacketData

        ServerNetwork.SendPacketToPlayer(Name, PlayerPacket)
    end
end

--[=[
    @param Name string
    @param Address Player
    @param IsReliable boolean
    @within ServerNetwork
    Pings a specific player. This function should be used when you want to communicate with the client but don't want to send any data.
]=]
function ServerNetwork.PingPlayer(Name: string, Address: Player, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(Address, "Expected Player as second argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as third argument.")
    
    local Signal = ReturnSignal(Name, IsReliable)
    if Signal.ClassName == "RemoteEvent" then
        (Signal:: RemoteEvent):FireClient(Address)
    else
        (Signal:: UnreliableRemoteEvent):FireClient(Address)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @within ServerNetwork
    Pings all players. This function should be used when you want to communicate with all clients but don't want to send any data.
]=]
function ServerNetwork.PingAllPlayers(Name: string, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as second argument.")
    
    for _, player in ipairs(Players:GetPlayers()) do
        ServerNetwork.PingPlayer(Name, player, IsReliable)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @param Callback (Address: Player, ...Packet?) -> ()
    @return RBXScriptConnection
    @within ServerNetwork
    Listens for data from the client.
]=]
function ServerNetwork.ListenForPacket(Name: string, IsReliable: boolean, Callback: (Address: Player, ...Packet?) -> ()): RBXScriptConnection
    assert(Name, "Expected string as first argument.")
    assert(Callback, "Expected boolean as second argument.")
    assert(Callback, "Expected function as third argument.")
    
    local Connection
    local Signal = ReturnSignal(Name, IsReliable)
    assert(Signal, "Error finding signal " .. Name)

    if Signal.ClassName == "RemoteEvent" then
        Connection = (Signal:: RemoteEvent).OnServerEvent:Connect(Callback)
    else
        Connection = (Signal:: UnreliableRemoteEvent).OnServerEvent:Connect(Callback)
    end

    assert(Connection, "Error connecting to signal " .. Name)
    return Connection
end

--[=[
    @param Name string
    @param Callback (Address: Player, ...Packet?) -> ...any
    @return ()
    @within ServerNetwork
    Listens for a request from the client. The client expects a return value so make sure your function returns something.
]=]
function ServerNetwork.ListenForRequest(Name: string, Callback: (Address: Player, ...Packet?) -> ...any): ()
    assert(Name, "Expected string as first argument.")
    assert(Callback, "Expected function as second argument.")
    
    local Function = GetFunction(Name)
    Function.OnServerInvoke = Callback
end

return ServerNetwork
