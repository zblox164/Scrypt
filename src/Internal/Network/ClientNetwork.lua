--!strict
--[=[
    @class ClientNetwork

]=]
local ClientNetwork = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[=[
    @type Packet number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
    @within ClientNetwork
]=]

--[=[
    @interface ClientPacketData 
    .Data Packet
    .Reliable boolean
    @within ClientNetwork
    :::info
    Currently, changing the Reliable value does not affect the type of signal that is created. In the future this will determine the type of signal created.
    :::
]=]
export type Packet = number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
export type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

local function CreateSignal(Name: string): RemoteEvent
    assert(Name, "Expected string as first argument.")

    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to create signal before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to create signal before network was loaded!")

    local CreateRemote = Functions:WaitForChild("CreateRemote"):: RemoteFunction
    local NewSignal = CreateRemote:InvokeServer(true, Name):: RemoteEvent?
    assert(NewSignal, "Error creating signal!")

    return NewSignal
end

local function CreateFunction(Name: string): RemoteFunction
    assert(Name, "Expected string as first argument.")

    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to create function before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to create function before network was loaded!")

    local CreateRemote = Functions:WaitForChild("CreateRemote"):: RemoteFunction
    local NewSignal = CreateRemote:InvokeServer(false, Name):: RemoteFunction?
    assert(NewSignal, "Error creating signal!")

    return NewSignal
end

local function GetFunction(Name: string): RemoteFunction
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to use function before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to use function before network was loaded!")

    local NewFunction: RemoteFunction = Functions:FindFirstChild(Name):: RemoteFunction

    if not NewFunction then
        NewFunction = CreateFunction(Name)
    end

    assert(NewFunction, "Error finding signal " .. Name)
    return NewFunction
end

local function GetSignal(Name: string, IsReliable: boolean): RemoteEvent
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to use signal before network was loaded!")

    local Signals = Remotes:FindFirstChild("Signals")
    assert(Signals, "Attempt to use signal before network was loaded!")

    local NewSignal: RemoteEvent = Signals:FindFirstChild(Name):: RemoteEvent

    if not NewSignal then
        NewSignal = CreateSignal(Name)
    end

    assert(NewSignal, "Error finding signal " .. Name)
    return NewSignal
end

--[=[
    @return Folder
    @yields
    @private
    @within ClientNetwork
]=]
function ClientNetwork.Init(): Folder
    local Location: Folder = ReplicatedStorage:WaitForChild("ScryptCommunication"):: Folder
    Location:WaitForChild("Signals")
    Location:FindFirstChild("Functions")

    return Location
end

--[=[
    @param Name string
    @param Packet ClientPacketData
    @within ClientNetwork
    Sends data to the server.
]=]
function ClientNetwork.SendPacket(Name: string, Packet: ClientPacketData)
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected ClientPacketData as second argument.")

    local Signal = GetSignal(Name, Packet.Reliable)
    Signal:FireServer(Packet.Data)
end

--[=[
    @param Name string
    @param IsReliable boolean
    @within ClientNetwork
    Pings the server. This function should be used when you want to communicate with the server but don't want to send any data.
]=]
function ClientNetwork.PingServer(Name: string, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")

    local Signal = GetSignal(Name, IsReliable)
    Signal:FireServer()
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
    assert(Callback, "Expected boolean as second argument.")
    assert(Callback, "Expected function as third argument.")
    
    local Connection
    local Signal = GetSignal(Name, IsReliable)
    Connection = Signal.OnClientEvent:Connect(Callback)
    return Connection
end

--[=[
    @param Name string
    @return Packet
    @yields
    @within ClientNetwork
    Sends and requests data from the server.
]=]
function ClientNetwork.RequestPacket(Name: string, Packet: Packet): Packet
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected Packet as second argument.")

    local Function = GetFunction(Name)
    local Request = Function:InvokeServer(Packet)
    return Request
end

--[=[
    @param Name string
    @yields
    @within ClientNetwork
    Requests a packet from the server without sending data. This function should be used when you want to request a response from the server but don't want to send any data.
]=]
function ClientNetwork.EmptyRequest(Name: string): Packet
    assert(Name, "Expected string as first argument.")

    local Function = GetFunction(Name)
    local Request = Function:InvokeServer()
    return Request
end

type ClientNetwork = {
    SendPacket: (Name: string, Packet: ClientPacketData) -> (),
    PingServer: (Name: string, IsReliable: boolean) -> (),
    RequestPacket: (Name: string, Packet: ClientPacketData) -> Packet,
    EmptyRequest: (Name: string) -> Packet,
    ListenForPacket: (Name: string, IsReliable: boolean, Callback: (...ClientPacketData) -> ()) -> RBXScriptConnection,
    Init: () -> Folder,
}

return ClientNetwork