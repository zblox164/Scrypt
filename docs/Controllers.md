---
sidebar_position: 3
---

# Controllers

:::danger NOTICE
Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
:::

## What are Controllers?
Controllers serve as client-side modules that enable you to manage specific behaviors within your project (can be considered services but client-side). Often, controllers are associated with the `player`, managing behavior such as the `Camera`, `User Input`, and other components.

Some examples of controllers:
* CameraController.luau
* UserInputController.luau
* CharacterController.luau
* UIController.luau

Each controller module bundles all related functionality, containing the necessary code and features required for its intended use case. It should NOT have functions relating to other features.

### Controllers vs Shared Modules
In contrast to controllers, which are tailored to manage specific client-side features and behaviors, shared modules serve as reusable code that can be leveraged by both client-side and server-side components. A good example of how shared modules can be useful is creating a custom string library with functions not included by default in Luau, or converting a frequently used function into a module containing the snippet for easy reuse.

Some examples of shared modules:
* StringUtils.luau
* CreateInstanceTree.luau
* GameConfig.luau (settings module)
* GameUtils.luau

By categorizing modules into distinct types, such as controllers and shared modules, developers can maintain an organized project structure that promotes clarity and efficiency.

## Usage
Controllers are extremely easy to setup and use. To get started, ensure you have Scrypt installed into your studio session. Next, add a `ModuleScript` into `ReplicatedStorage/Controllers` (use custom path if specified). 

:::tip
Scrypt searches through all non-script instances for controllers so you can use folders to separate controllers based on feature.
:::

Give it a name, preferably with a suffix of "Controller" to follow the standard naming convention. We can start writing our code like any regular `ModuleScript`. Let's give it some placeholder functions:

```lua
--!strict
--@client

local TestController = {}

function TestController.Run()
	print("TEST RUNNING")
end

function TestController.Cancel()
	print("TEST CANCELED")
end

function TestController.Get(Name: string): string
	return tostring(Name)
end

return TestController
```

:::danger
Modules cannot yield while being initially loaded. This means you cannot have global variables with `WaitForChild` or anything that will yield the current thread.

This also means that if you need to access the Scrypt framework in a service, shared module, or controller, you should not need to wait for the framework to load.
:::

To access the controller, in a separate `LocalScript`, simply run the `GetController` function with the name of the controller passed as an argument:
```lua
--!strict
--@client

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local TestController = Scrypt.GetController("TestController")
print(TestController.Get("TEST")) --> TEST
```
:::tip
All controllers are lazily loaded! This means controllers are only loaded when they are needed instead of all of your scripts being loaded at runtime.
:::
