---
sidebar_position: 3
---

# Services

:::danger NOTICE
Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.
:::

## What are Services?
Services serve as server-side modules that enable you to manage specific behaviors within your project (can be considered controllers but server-side). Services, such as those responsible for player data management, focus exclusively on managing server operations.

Some examples of services:
* DataService.luau
* GameRoundsService.luau
* CommandService.luau
* PurchaseService.luau

Each service module bundles all related functionality, containing the necessary code and features required for its intended use case. It should NOT have functions relating to other features.

### Services vs Shared Modules
In contrast to services, which are tailored to manage specific server-side features and behaviors, shared modules serve as reusable code that can be leveraged by both client-side and server-side components. A good example of how shared modules can be useful is creating a custom string library with functions not included by default in Luau, or converting a frequently used function into a module containing the snippet for easy reuse.

Some examples of shared modules:
* StringUtils.luau
* CreateInstanceTree.luau
* GameConfig.luau (settings module)
* GameUtils.luau

By categorizing modules into distinct types, such as controllers and shared modules, developers can maintain an organized project structure that promotes clarity and efficiency.

## Usage
Services are extremely easy to setup and use. To get started, ensure you have Scrypt installed into your studio session. Next, add a `ModuleScript` into `ServerScriptService/Services` (use custom path if specified). 

:::tip
Scrypt searches through all non-script instances for servers so you can use folders to separate servers based on feature.
:::

Give it a name, preferably with a suffix of "Service" to follow the standard naming convention. We can start writing our code like any regular `ModuleScript`. Let's give it some placeholder functions:

```lua
--!strict
--@server

local TestService = {}

function TestService.Run()
	print("TEST RUNNING")
end

function TestService.Cancel()
	print("TEST CANCELED")
end

function TestService.Get(Name: string): string
	return tostring(Name)
end

return TestService
```

:::info
If you need to access the Scrypt framework in a service, shared module, or service, you do not need to wait for the framework to load. Doing so will cause issues.
:::

To access the service, in a separate `ServerScript`, simply reference the service through the `Scrypt.Services` property:
```lua
--!strict
--@server

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local TestService = Scrypt.Services.TestService
print(TestService.Get("TEST")) --> TEST
```
:::tip
All services are lazily loaded! This means services are only loaded when they are needed instead of all of your scripts being loaded at runtime.
:::
