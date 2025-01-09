"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[792],{4120:e=>{e.exports=JSON.parse('{"functions":[{"name":"Symbol","desc":"","params":[{"name":"Name","desc":"","lua_type":"string?"}],"returns":[{"desc":"","lua_type":"Symbol"}],"function_type":"static","source":{"line":37,"path":"src/ReplicatedStorage/Scrypt/Internal/Symbol.lua"}},{"name":"CreateSignal","desc":"Creates and returns a Signal. This is an implementation of BindableEvents.\\n:::info What is IsPrivate?\\nIsPrivate is an optional argument that toggles whether you want\\nthe event to be used in other scripts. By default this is set to false.\\n:::\\n\\n\\t","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"IsPrivate","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"static","realm":["Server"],"source":{"line":232,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"CreateFunction","desc":"Creates and returns a Function. This is an implementation of BindableFunctions.\\n:::info What is IsPrivate?\\nIsPrivate is an optional argument that toggles whether you want\\nthe function to be used in other scripts. By default this is set to false.\\n:::\\n\\n\\t","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"IsPrivate","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"Function"}],"function_type":"static","realm":["Server"],"source":{"line":249,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"GetService","desc":"Loads and returns a Service by name. Services are lazily loaded so they are only run when this function is invoked.","params":[{"name":"Name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"static","realm":["Client"],"source":{"line":298,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"GetModule","desc":"Loads and returns a shared module by name. Shared modules are lazily loaded so they are only run when this function is invoked.","params":[{"name":"Name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"static","realm":["Client"],"source":{"line":310,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"Init","desc":"Initializes the framework and loads all shared modules, libraries, and services.\\nThis function returns an event that fires once everything has been loaded. You can optionally specify\\nthe location of environment modules. By default, Scrypt assumes ServerScriptService.\\n\\nUsage example:\\n```lua\\nlocal Scrypt = require(game:GetService(\\"ReplicatedStorage\\"):WaitForChild(\\"Scrypt\\"))\\nScrypt.Init():Wait()\\n\\nprint(Scrypt.ServicesRBX.ReplicatedStorage) -> ReplicatedStorage\\n```\\n:::caution\\nIf you are adding libraries, shared modules, or services, you do not have to wait for the framework to load.\\nDoing so can cause issues.\\n:::","params":[{"name":"EnvironmentLocation","desc":"","lua_type":"Instance?"}],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"static","realm":["Server"],"source":{"line":336,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}}],"properties":[{"name":"RegExp","desc":"Regular expressions module published by Roblox. See more information in RegEx.lua.","lua_type":"RegularExpressionClass","source":{"line":38,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"Promise","desc":"Promise module created by evaera. ","lua_type":"PromiseClass","source":{"line":45,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"Services","desc":"Contains a dictionary of Roblox services.","lua_type":"{[Name]: Instance}","source":{"line":51,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"Utils","desc":"Returns the Utils module. Contains some basic pure functions.","lua_type":"{(...any) -> ...any}","source":{"line":57,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"ServerNetwork","desc":"Returns the ServerNetwork class.","lua_type":"ServerNetwork","source":{"line":64,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}}],"types":[{"name":"Symbol","desc":"","lua_type":"typeof(newproxy(true)) & {[string]: any}","source":{"line":25,"path":"src/ReplicatedStorage/Scrypt/Internal/Symbol.lua"}},{"name":"Service","desc":"","fields":[{"name":"[Name]","lua_type":"string","desc":""},{"name":"[Service]","lua_type":"any","desc":""}],"source":{"line":27,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}},{"name":"Result<T>","desc":"","lua_type":"{Success: boolean, Value: T?, Error: string?}","source":{"line":32,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}}],"name":"ScryptServer","desc":":::danger NOTICE\\nScrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.\\n:::","realm":["Server"],"source":{"line":20,"path":"src/ReplicatedStorage/Scrypt/Server.lua"}}')}}]);