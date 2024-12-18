--!strict
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
    Reliable: boolean, --TODO
    Data: Packet
}

local function CreateSignal(Name: string, Location: Instance): RemoteEvent
    assert(Name, "Expected string as first argument.")
    assert(Name, "Expected Instance as second argument.")

    local NewSignal = Instance.new("RemoteEvent")
    NewSignal.Name = Name
    NewSignal.Parent = Location

    return NewSignal
end

local function CreateFunction(Name: string, Location: Instance): RemoteFunction
    assert(Name, "Expected string as first argument.")
    assert(Name, "Expected Instance as second argument.")

    local NewFunction = Instance.new("RemoteFunction")
    NewFunction.Name = Name
    NewFunction.Parent = Location

    return NewFunction
end

local function GetSignal(Name: string, Reliable: boolean): RemoteEvent
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to use event before network was loaded!")

    local Signals = Remotes:FindFirstChild("Signals")
    assert(Signals, "Attempt to use event before network was loaded!")

    local NewSignal: RemoteEvent = Signals:FindFirstChild(Name):: RemoteEvent
    if not NewSignal then
        NewSignal = CreateSignal(Name, Signals)
    end

    assert(NewSignal, "Error finding signal " .. Name)
    return NewSignal
end

local function GetFunction(Name: string): RemoteFunction
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
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

local function CreateClientRemote(Player: Player, Type: boolean, Name: string): Instance
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Not initialized")

    local Signals = Remotes:FindFirstChild("Signals"):: Folder
    assert(Signals, "Signals not loaded!")

    local RemoteCheck = Signals:FindFirstChild(Name):: RemoteEvent?
    if Type and RemoteCheck then return RemoteCheck end

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Functions not loaded")

    local FunctionCheck = Signals:FindFirstChild(Name):: RemoteFunction?
    if Type and FunctionCheck then return FunctionCheck end
    if not Type and FunctionCheck then return FunctionCheck end

    local RemoteType = if Type then "RemoteEvent" else "RemoteFunction"
    local NewRemote = Instance.new(RemoteType)
    NewRemote.Name = Name
    NewRemote.Parent = if Type then Signals else Functions
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
    @param Packet ServerPacketData
    @within ServerNetwork
    Sends data to a specific player from the server.
]=]
function ServerNetwork.SendPacketToPlayer(Name: string, Packet: ServerPacketData)
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected ServerPacketData as second argument.")
    
    local Signal = GetSignal(Name, Packet.Reliable)
    Signal:FireClient(Packet.Address, Packet.Data)
end

--[=[
    @param Name string
    @param Packet ServerPacketData
    @within ServerNetwork
    Sends data to all players in a server.
]=]
function ServerNetwork.SendPacketToAllPlayers(Name: string, Packet: ServerPacketData)
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected ServerPacketData as second argument.")

    for _, player in ipairs(Players:GetPlayers()) do
        local PlayerPacket = {
            Address = player,
            Data = Packet
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
    assert(IsReliable, "Expected boolean as third argument.")
    
    local Signal = GetSignal(Name, IsReliable)
    Signal:FireClient(Address)
end

--[=[
    @param Name string
    @param IsReliable boolean
    @within ServerNetwork
    Pings all players. This function should be used when you want to communicate with all clients but don't want to send any data.
]=]
function ServerNetwork.PingAllPlayers(Name: string, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(IsReliable, "Expected boolean as second argument.")
    
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
    local Signal = GetSignal(Name, IsReliable)
    Connection = Signal.OnServerEvent:Connect(Callback)
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