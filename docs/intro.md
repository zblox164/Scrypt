---
sidebar_position: 1
---

# Getting Started

:::danger NOTICE
Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
:::

## Installation
Installing Scrypt only requires a few simple steps! To start the installation process, you'll first need to get the Scrypt framework. Currently, there are two methods to do this:
1. Download the .rbxm file as provided in the GitHub repository
2. Get Scrypt directly from the Creator Store

#### Method 1
* Go to the main branch of the [official Scrypt repository](https://github.com/zblox164/Scrypt) and download the .rbxm file named 'ScryptModel'. Once you have downloaded the model, simply drag it into your studio session.

#### Method 2
* If you opt for the second method, you can find Scrypt on the Creator Store [here](https://create.roblox.com/store/asset/140185855944479/Scrypt). You should be able to add the framework to your inventory and import it through the toolbox afterwards.

---

Once you've imported Scrypt into your project, you can begin the next step. Scrypt should come with a root folder that contains several items, each needs to be moved:
* Scrypt module
* Services folder
* Controllers folder
* Shared folder

After you've moved all the framework components to the proper locations, you can begin using the framework.

## Basic Usage
The basic usage for Scrypt is quite simple. First, require the module just like any other `ModuleScript`. After that, we can run the .Init function and wait for the framework to load:

```lua
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()
```

Now that you've properly initialized Scrypt, we can go through some basic features and their usage. Let's start with features that replace a default workflow.

### Bindables Replacement
Scrypt has a built in version of both `BindableFunctions` as well as `BindableEvents`. Creating events and functions is quite simple:

```lua
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local Event = Scrypt.CreateSignal("Event")
local Function = Scrypt.CreateFunction("Function")
```

Using events should be identical to regular events. Functions are slightly different.

```lua
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local Event = Scrypt.CreateSignal("Event")

local Connection
Connection = Event:Connect(function(Data: any)
	print(Data) --> This is a test
end)

Event:Fire("This is a test")
Connection:Disconnect() -- clean up
--------------------------------------

local Function = Scrypt.CreateFunction("Function")

Function:OnInvoke(function(Data: any)
	return not Data
end)

local Return = Function:Invoke(true)
print(Return) --> false
Function:Destroy() -- clean up
```

### GetService() Replacement
Scrypt loads most Roblox services after you run `.Init` rendering the use of `game:GetService` obsolete when using Scrypt.
To access a service, simply index the Services dictionary with the service you want to get. For example:

```lua
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local Players = Scrypt.Services.Players
local ReplicatedStorage = Scrypt.Services.ReplicatedStorage
```

:::info
If you need a service that hasn't been added to the dictionary, you can manually add it in the RBXServices module located in path: `Scrypt/Internal`.
Most services are added, however if Roblox adds a new service and Scrypt hasn't been updated yet, you may need to add it manually if you want to access it through Scrypt.
:::

### Remotes Replacement
Remotes are used whenever you need to communicate with the server from the client or client from the server. Scrypt offers an implementation of remotes. Here is a basic usage example, however for more detailed information, please see the API.

```lua
--@client
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

-- To Server
local Packet = {
	Data = "Data being sent to server",
	Reliable = true 
}
Scrypt.ClientNetwork.SendPacket("Send", Packet)

local RequestToServer = Scrypt.ClientNetwork.RequestPacket("Request", "Data being sent to server")
print(RequestToServer) --> Data received!

-- From Server
local FromServer
FromServer = Scrypt.ClientNetwork.ListenForPacket("Receive", true, function(Data) 
	print(Data) --> Data being sent from server
end)
```

```lua
--@server
local Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))
Scrypt.Init():Wait()

-- Data from client
local DataFromClient
DataFromClient = Scrypt.ServerNetwork.ListenForPacket("Send", true, function(Address: Player, Data)  
	print("Incoming data from " .. tostring(Address) .. ": " .. tostring(Data))
end)

-- Request from client
local RequestFromClient
RequestFromClient = Scrypt.ServerNetwork.ListenForRequest("Request", function(Address: Player, Data)  
	return "Data received!"
end)

-- Data to client
Scrypt.Services.Players.PlayerAdded:Connect(function(Player: Player)
	local Packet = {
		Data = "Data being sent from server",
		Reliable = true,
		Address = Player
	}
	Scrypt.ServerNetwork.SendPacketToClient("Receive", Packet)	
end)
```

:::info
When sending instances from the server to the client, if the instance hasn't replicated yet, Scrypt allows you to run the method :Replicate() to wait until the instance has replicated to the client. This function returns the instance object when it replicates. This only happens when the instance is nil on the client so it is advised to check if the instance exists before running this method.
:::


### require() Replacement
So far the examples have only shown the built in features of Scrypt. You might be asking yourself, *"how can I build a game with this?"*. The answer is you can use Scrypt to lazily load game modules for you. To utilize this, create a new `ModuleScript` under `ReplicatedStorage/Shared/Modules`. You can make this module contain whatever you want. For now, let's just use this as an example:

```lua
--!strict
--@shared
local BasicMath = {}

function BasicMath.Add(a: number, b: number): number
	return a + b
end

function BasicMath.Subtract(a: number, b: number): number
	return a - b
end

function BasicMath.Multiply(a: number, b: number): number
	return a * b
end

function BasicMath.Divide(a: number, b: number): number
	return a / b
end

return BasicMath
```
To access this module from other scripts, normally you have to reference the module and then require it to use it. With Scrypt, all you have to do, is run the GetModule function with name of the module passed as an argument. In this case, the module is named "BasicMath". In a test script, we can access it with:

```lua
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local BasicMath = Scrypt.GetModule("BasicMath")

print(BasicMath.Add(64, 100)) --> 164
print(BasicMath.Subtract(228, 64)) --> 164
print(BasicMath.Multiply(1, 164)) --> 164
print(BasicMath.Divide(328, 2)) --> 164
```

You don't only have to place your game modules in the `Shared/Modules` folder. Scrypt loads modules from all of the following locations by default, each with their own purpose:

* `ReplicatedStorage/Shared/Modules` (Server & Client)
    * Modules that are used with both the server and client
* `ReplicatedStorage/Shared/Libraries` (Server & Client)
    * Modules that contain specific functions for a specific purpose. For example, a custom quaternion library.
* `ServerScriptService/Services` (Server)
    * Game service modules ([Services docs](/Services.md)).
* `ReplicatedStorage/Controllers` (Client)
    * Game controller modules ([Controller docs](/Controllers.md)).

:::tip
All modules are lazily loaded! This means modules are only loaded when they are needed instead of all of your scripts being loaded at runtime.

Services and Controllers have their own 'Get' functions. See the API or specific doc pages for more details.
:::

---

Features not shown on this page:
* Maybe Monad (separate page wip)
* Utils
* GUI (coming soon)