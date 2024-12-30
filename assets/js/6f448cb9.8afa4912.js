"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[675],{4151:e=>{e.exports=JSON.parse('{"functions":[{"name":"Init","desc":"","params":[],"returns":[{"desc":"","lua_type":"Folder"}],"function_type":"static","private":true,"yields":true,"source":{"line":142,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}},{"name":"SendPacket","desc":"Sends data to the server.","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"Packet","desc":"","lua_type":"ClientPacketData"}],"returns":[],"function_type":"static","source":{"line":156,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}},{"name":"PingServer","desc":"Pings the server. This function should be used when you want to communicate with the server but don\'t want to send any data.","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"IsReliable","desc":"","lua_type":"boolean"}],"returns":[],"function_type":"static","source":{"line":174,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}},{"name":"ListenForPacket","desc":"Listens for data from the server.","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"IsReliable","desc":"","lua_type":"boolean"},{"name":"Callback","desc":"","lua_type":"(...Packet) -> ()"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection"}],"function_type":"static","source":{"line":193,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}},{"name":"RequestPacket","desc":"Sends and requests data from the server.","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"Packet","desc":"","lua_type":"Packet"}],"returns":[{"desc":"","lua_type":"Packet"}],"function_type":"static","yields":true,"source":{"line":211,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}},{"name":"EmptyRequest","desc":"Requests a packet from the server without sending data. This function should be used when you want to request a response from the server but don\'t want to send any data.","params":[{"name":"Name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Packet\\r\\n"}],"function_type":"static","yields":true,"source":{"line":226,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}}],"properties":[],"types":[{"name":"Packet","desc":"","lua_type":"number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor","source":{"line":23,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}},{"name":"ClientPacketData","desc":":::info\\nCurrently, changing the Reliable value does not affect the type of signal that is created. In the future this will determine the type of signal created.\\n:::","fields":[{"name":"Data","lua_type":"Packet","desc":""},{"name":"Reliable","lua_type":"boolean","desc":""}],"source":{"line":33,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}}],"name":"ClientNetwork","desc":"","source":{"line":16,"path":"src/ReplicatedStorage/Scrypt/Internal/Network/ClientNetwork.lua"}}')}}]);