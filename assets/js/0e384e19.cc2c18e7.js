"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[976],{2053:(e,r,n)=>{n.r(r),n.d(r,{assets:()=>l,contentTitle:()=>s,default:()=>h,frontMatter:()=>o,metadata:()=>t,toc:()=>c});const t=JSON.parse('{"id":"intro","title":"Getting Started","description":"Scrypt is in very early stages of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.","source":"@site/docs/intro.md","sourceDirName":".","slug":"/intro","permalink":"/Scrypt/docs/intro","draft":false,"unlisted":false,"editUrl":"https://github.com/zblox164/Scrypt/edit/main/docs/intro.md","tags":[],"version":"current","sidebarPosition":1,"frontMatter":{"sidebar_position":1},"sidebar":"defaultSidebar","next":{"title":"About","permalink":"/Scrypt/docs/About"}}');var i=n(4848),a=n(8453);const o={sidebar_position:1},s="Getting Started",l={},c=[{value:"Installation",id:"installation",level:2},{value:"Method 1",id:"method-1",level:4},{value:"Method 2",id:"method-2",level:4},{value:"Basic Usage",id:"basic-usage",level:2},{value:"Bindables Replacement",id:"bindables-replacement",level:3},{value:"GetService() Replacement",id:"getservice-replacement",level:3},{value:"Remotes Replacement",id:"remotes-replacement",level:3},{value:"require() Replacement",id:"require-replacement",level:3}];function d(e){const r={a:"a",admonition:"admonition",code:"code",em:"em",h1:"h1",h2:"h2",h3:"h3",h4:"h4",header:"header",hr:"hr",li:"li",ol:"ol",p:"p",pre:"pre",strong:"strong",ul:"ul",...(0,a.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(r.header,{children:(0,i.jsx)(r.h1,{id:"getting-started",children:"Getting Started"})}),"\n",(0,i.jsx)(r.admonition,{title:"NOTICE",type:"danger",children:(0,i.jsxs)(r.p,{children:["Scrypt is in very ",(0,i.jsx)(r.strong,{children:"early stages"})," of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details."]})}),"\n",(0,i.jsx)(r.h2,{id:"installation",children:"Installation"}),"\n",(0,i.jsx)(r.p,{children:"Installing Scrypt only requires a few simple steps! To start the installation process, you'll first need to get the Scrypt framework. Currently, there are two methods to do this:"}),"\n",(0,i.jsxs)(r.ol,{children:["\n",(0,i.jsx)(r.li,{children:"Download the .rbxm file as provided in the GitHub repository"}),"\n",(0,i.jsx)(r.li,{children:"Get Scrypt directly from the Creator Store"}),"\n"]}),"\n",(0,i.jsx)(r.h4,{id:"method-1",children:"Method 1"}),"\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsxs)(r.li,{children:["Go to the main branch of the ",(0,i.jsx)(r.a,{href:"https://github.com/zblox164/Scrypt",children:"official Scrypt repository"})," and download the .rbxm file named 'ScryptModel'. Once you have downloaded the model, simply drag it into your studio session."]}),"\n"]}),"\n",(0,i.jsx)(r.h4,{id:"method-2",children:"Method 2"}),"\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsxs)(r.li,{children:["If you opt for the second method, you can find Scrypt on the Creator Store ",(0,i.jsx)(r.a,{href:"https://create.roblox.com/store/asset/140185855944479/Scrypt",children:"here"}),". You should be able to add the framework to your inventory and import it through the toolbox afterwards."]}),"\n"]}),"\n",(0,i.jsx)(r.hr,{}),"\n",(0,i.jsx)(r.p,{children:"Once you've imported Scrypt into your project, you can begin the next step. Scrypt should come with a root folder that contains several items, each needs to be moved:"}),"\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsx)(r.li,{children:"Scrypt module"}),"\n",(0,i.jsx)(r.li,{children:"Services folder"}),"\n",(0,i.jsx)(r.li,{children:"Controllers folder"}),"\n",(0,i.jsx)(r.li,{children:"Shared folder"}),"\n"]}),"\n",(0,i.jsx)(r.p,{children:"After you've moved all the framework components to the proper locations, you can begin using the framework."}),"\n",(0,i.jsx)(r.h2,{id:"basic-usage",children:"Basic Usage"}),"\n",(0,i.jsxs)(r.p,{children:["The basic usage for Scrypt is quite simple. First, require the module just like any other ",(0,i.jsx)(r.code,{children:"ModuleScript"}),". After that, we can run the .Init function and wait for the framework to load:"]}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)\r\nScrypt.Init():Wait()\n'})}),"\n",(0,i.jsx)(r.p,{children:"Now that you've properly initialized Scrypt, we can go through some basic features and their usage. Let's start with features that replace a default workflow."}),"\n",(0,i.jsx)(r.h3,{id:"bindables-replacement",children:"Bindables Replacement"}),"\n",(0,i.jsxs)(r.p,{children:["Scrypt has a built in version of both ",(0,i.jsx)(r.code,{children:"BindableFunctions"})," as well as ",(0,i.jsx)(r.code,{children:"BindableEvents"}),". Creating events and functions is quite simple:"]}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)\r\nScrypt.Init():Wait()\r\n\r\nlocal Event = Scrypt.CreateSignal("Event")\r\nlocal Function = Scrypt.CreateFunction("Function")\n'})}),"\n",(0,i.jsx)(r.p,{children:"Using events should be identical to regular events. Functions are slightly different."}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)\r\nScrypt.Init():Wait()\r\n\r\nlocal Event = Scrypt.CreateSignal("Event")\r\n\r\nlocal Connection\r\nConnection = Event:Connect(function(Data: any)\r\n\tprint(Data) --\x3e This is a test\r\nend)\r\n\r\nEvent:Fire("This is a test")\r\nConnection:Disconnect() -- clean up\r\n--------------------------------------\r\n\r\nlocal Function = Scrypt.CreateFunction("Function")\r\n\r\nFunction:OnInvoke(function(Data: any)\r\n\treturn not Data\r\nend)\r\n\r\nlocal Return = Function:Invoke(true)\r\nprint(Return) --\x3e false\r\nFunction:Destroy() -- clean up\n'})}),"\n",(0,i.jsx)(r.h3,{id:"getservice-replacement",children:"GetService() Replacement"}),"\n",(0,i.jsxs)(r.p,{children:["Scrypt loads most Roblox services after you run ",(0,i.jsx)(r.code,{children:".Init"})," rendering the use of ",(0,i.jsx)(r.code,{children:"game:GetService"})," obsolete when using Scrypt.\r\nTo access a service, simply index the Services dictionary with the service you want to get. For example:"]}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)\r\nScrypt.Init():Wait()\r\n\r\nlocal Players = Scrypt.Services.Players\r\nlocal ReplicatedStorage = Scrypt.Services.ReplicatedStorage\n'})}),"\n",(0,i.jsx)(r.admonition,{type:"info",children:(0,i.jsxs)(r.p,{children:["If you need a service that hasn't been added to the dictionary, you can manually add it in the RBXServices module located in path: ",(0,i.jsx)(r.code,{children:"Scrypt/Internal"}),".\r\nMost services are added, however if Roblox adds a new service and Scrypt hasn't been updated yet, you may need to add it manually if you want to access it through Scrypt."]})}),"\n",(0,i.jsx)(r.h3,{id:"remotes-replacement",children:"Remotes Replacement"}),"\n",(0,i.jsx)(r.p,{children:"Remotes are used whenever you need to communicate with the server from the client or client from the server. Scrypt offers an implementation of remotes. Here is a basic usage example, however for more detailed information, please see the API."}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'--@client\r\nlocal Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)\r\nScrypt.Init():Wait()\r\n\r\n-- To Server\r\nlocal Packet = {\r\n\tData = "Data being sent to server",\r\n\tReliable = true \r\n}\r\nScrypt.ClientNetwork.SendPacket("Send", Packet)\r\n\r\nlocal RequestToServer = Scrypt.ClientNetwork.RequestPacket("Request", "Data being sent to server")\r\nprint(RequestToServer) --\x3e Data received!\r\n\r\n-- From Server\r\nlocal FromServer\r\nFromServer = Scrypt.ClientNetwork.ListenForPacket("Receive", true, function(Data) \r\n\tprint(Data) --\x3e Data being sent from server\r\nend)\n'})}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'--@server\r\nlocal Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))\r\nScrypt.Init():Wait()\r\n\r\n-- Data from client\r\nlocal DataFromClient\r\nDataFromClient = Scrypt.ServerNetwork.ListenForPacket("Send", true, function(Address: Player, Data)  \r\n\tprint("Incoming data from " .. tostring(Address) .. ": " .. tostring(Data))\r\nend)\r\n\r\n-- Request from client\r\nlocal RequestFromClient\r\nRequestFromClient = Scrypt.ServerNetwork.ListenForRequest("Request", function(Address: Player, Data)  \r\n\treturn "Data received!"\r\nend)\r\n\r\n-- Data to client\r\nScrypt.Services.Players.PlayerAdded:Connect(function(Player: Player)\r\n\tlocal Packet = {\r\n\t\tData = "Data being sent from server",\r\n\t\tReliable = true,\r\n\t\tAddress = Player\r\n\t}\r\n\tScrypt.ServerNetwork.SendPacketToClient("Receive", Packet)\t\r\nend)\n'})}),"\n",(0,i.jsx)(r.h3,{id:"require-replacement",children:"require() Replacement"}),"\n",(0,i.jsxs)(r.p,{children:["So far the examples have only shown the built in features of Scrypt. You might be asking yourself, ",(0,i.jsx)(r.em,{children:'"how can I build a game with this?"'}),". The answer is you can use Scrypt to lazily load game modules for you. To utilize this, create a new ",(0,i.jsx)(r.code,{children:"ModuleScript"})," under ",(0,i.jsx)(r.code,{children:"ReplicatedStorage/Shared/Modules"}),". You can make this module contain whatever you want. For now, let's just use this as an example:"]}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:"--!strict\r\n--@shared\r\nlocal BasicMath = {}\r\n\r\nfunction BasicMath.Add(a: number, b: number): number\r\n\treturn a + b\r\nend\r\n\r\nfunction BasicMath.Subtract(a: number, b: number): number\r\n\treturn a - b\r\nend\r\n\r\nfunction BasicMath.Multiply(a: number, b: number): number\r\n\treturn a * b\r\nend\r\n\r\nfunction BasicMath.Divide(a: number, b: number): number\r\n\treturn a / b\r\nend\r\n\r\nreturn BasicMath\n"})}),"\n",(0,i.jsx)(r.p,{children:'To access this module from other scripts, normally you have to reference the module and then require it to use it. With Scrypt, all you have to do, is run the GetModule function with name of the module passed as an argument. In this case, the module is named "BasicMath". In a test script, we can access it with:'}),"\n",(0,i.jsx)(r.pre,{children:(0,i.jsx)(r.code,{className:"language-lua",children:'local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)\r\nScrypt.Init():Wait()\r\n\r\nlocal BasicMath = Scrypt.GetModule("BasicMath")\r\n\r\nprint(BasicMath.Add(64, 100)) --\x3e 164\r\nprint(BasicMath.Subtract(228, 64)) --\x3e 164\r\nprint(BasicMath.Multiply(1, 164)) --\x3e 164\r\nprint(BasicMath.Divide(328, 2)) --\x3e 164\n'})}),"\n",(0,i.jsxs)(r.p,{children:["You don't only have to place your game modules in the ",(0,i.jsx)(r.code,{children:"Shared/Modules"})," folder. Scrypt loads modules from all of the following locations by default, each with their own purpose:"]}),"\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsxs)(r.li,{children:[(0,i.jsx)(r.code,{children:"ReplicatedStorage/Shared/Modules"})," (Server & Client)","\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsx)(r.li,{children:"Modules that are used with both the server and client"}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(r.li,{children:[(0,i.jsx)(r.code,{children:"ReplicatedStorage/Shared/Libraries"})," (Server & Client)","\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsx)(r.li,{children:"Modules that contain specific functions for a specific purpose. For example, a custom quaternion library."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(r.li,{children:[(0,i.jsx)(r.code,{children:"ServerScriptService/Services"})," (Server)","\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsxs)(r.li,{children:["Game service modules (",(0,i.jsx)(r.a,{href:"/Scrypt/docs/Services",children:"Services docs"}),")."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(r.li,{children:[(0,i.jsx)(r.code,{children:"ReplicatedStorage/Controllers"})," (Client)","\n",(0,i.jsxs)(r.ul,{children:["\n",(0,i.jsxs)(r.li,{children:["Game controller modules (",(0,i.jsx)(r.a,{href:"/Scrypt/docs/Controllers",children:"Controller docs"}),")."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(r.admonition,{type:"tip",children:[(0,i.jsx)(r.p,{children:"All modules are lazily loaded! This means modules are only loaded when they are needed instead of all of your scripts being loaded at runtime."}),(0,i.jsx)(r.p,{children:"Services and Controllers have their own 'Get' functions. See the API or specific doc pages for more details."})]}),"\n",(0,i.jsx)(r.hr,{}),"\n",(0,i.jsx)(r.p,{children:"More coming soon!"})]})}function h(e={}){const{wrapper:r}={...(0,a.R)(),...e.components};return r?(0,i.jsx)(r,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},8453:(e,r,n)=>{n.d(r,{R:()=>o,x:()=>s});var t=n(6540);const i={},a=t.createContext(i);function o(e){const r=t.useContext(a);return t.useMemo((function(){return"function"==typeof e?e(r):{...r,...e}}),[r,e])}function s(e){let r;return r=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),t.createElement(a.Provider,{value:r},e.children)}}}]);