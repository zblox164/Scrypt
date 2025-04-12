"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[721],{2427:(e,n,l)=>{l.r(n),l.d(n,{assets:()=>a,contentTitle:()=>s,default:()=>h,frontMatter:()=>t,metadata:()=>i,toc:()=>o});const i=JSON.parse('{"type":"mdx","permalink":"/Scrypt/changelog","source":"@site/pages/changelog.md","description":"v0.0.51-alpha","frontMatter":{},"unlisted":false}');var d=l(4848),r=l(8453);const t={},s=void 0,a={},o=[{value:"v0.0.51-alpha",id:"v0051-alpha",level:2},{value:"04/12/2025",id:"04122025",level:4},{value:"v0.0.5-alpha",id:"v005-alpha",level:2},{value:"02/13/2025",id:"02132025",level:4},{value:"v0.0.43-alpha",id:"v0043-alpha",level:2},{value:"01/23/2025",id:"01232025",level:4},{value:"v0.0.42-alpha",id:"v0042-alpha",level:2},{value:"01/18/2025",id:"01182025",level:4},{value:"v0.0.41-alpha",id:"v0041-alpha",level:2},{value:"01/13/2025",id:"01132025",level:4},{value:"v0.0.4-alpha",id:"v004-alpha",level:2},{value:"01/08/2025",id:"01082025",level:4},{value:"v0.0.3-alpha",id:"v003-alpha",level:2},{value:"12/30/2024",id:"12302024",level:4},{value:"v0.0.2-alpha",id:"v002-alpha",level:2},{value:"12/29/2024",id:"12292024",level:4},{value:"v0.0.1-alpha",id:"v001-alpha",level:2},{value:"12/17/2024",id:"12172024",level:4}];function c(e){const n={code:"code",h2:"h2",h4:"h4",li:"li",ul:"ul",...(0,r.R)(),...e.components};return(0,d.jsxs)(d.Fragment,{children:[(0,d.jsx)(n.h2,{id:"v0051-alpha",children:"v0.0.51-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"04122025",children:"04/12/2025"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Fixed network bug where non instances would cause errors (as a result of the replicate feature)"}),"\n",(0,d.jsx)(n.li,{children:"Fixed minor issues"}),"\n",(0,d.jsx)(n.li,{children:"Minor improvements"}),"\n",(0,d.jsxs)(n.li,{children:["Improvements to documentation","\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Added information for GUI module on the 'Getting Started' page"}),"\n",(0,d.jsx)(n.li,{children:"Added information for replicate feature"}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v005-alpha",children:"v0.0.5-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"02132025",children:"02/13/2025"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Added the Maybe monad"}),"\n",(0,d.jsx)(n.li,{children:"Added functionality the network system when sending instances from server to client"}),"\n",(0,d.jsx)(n.li,{children:"Added StarterPack and StarterPlayer to the RBXServices script. Both can now be used like any other Roblox Service"}),"\n",(0,d.jsx)(n.li,{children:"Minor code improvements"}),"\n",(0,d.jsx)(n.li,{children:"Minor docs improvements"}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v0043-alpha",children:"v0.0.43-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"01232025",children:"01/23/2025"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Fixed major framework load bug"}),"\n",(0,d.jsx)(n.li,{children:"Improved GUI module"}),"\n",(0,d.jsx)(n.li,{children:"Changed files to .luau"}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v0042-alpha",children:"v0.0.42-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"01182025",children:"01/18/2025"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Fixed bug with ServerNetwork where when the client creates a remote, it would not get parented to the comms folder"}),"\n",(0,d.jsx)(n.li,{children:"Added GUI internal module"}),"\n",(0,d.jsx)(n.li,{children:"Minor improvements"}),"\n",(0,d.jsxs)(n.li,{children:["Improvements to documentation","\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Updated changelog (it didn't update last version)"}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v0041-alpha",children:"v0.0.41-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"01132025",children:"01/13/2025"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Fixed bug with network system where creating a client remote would cause an error"}),"\n",(0,d.jsx)(n.li,{children:"Fixed issue where some of the functions renamed last update were not updated"}),"\n",(0,d.jsx)(n.li,{children:"Added public ServerPacketData to Scrypt"}),"\n",(0,d.jsx)(n.li,{children:"Fixed Packet type (in ClientNetwork and Scrypt)"}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v004-alpha",children:"v0.0.4-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"01082025",children:"01/08/2025"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Revamp of internal modules to more closely fit the functional paradigm: Services, Controllers, Server, Client, ServerNetwork, ClientNetwork, and both Scrypt and Network loaders"}),"\n",(0,d.jsx)(n.li,{children:"Minor code improvements"}),"\n",(0,d.jsx)(n.li,{children:"Fixed typechecking issue with ClientNetwork and RequestPacket"}),"\n",(0,d.jsx)(n.li,{children:"Renamed functions 'PingPlayer', 'PingAllPlayers', 'SendPacketToPlayer', and 'SendPacketToAllPlayers' to 'PingClient', 'PingAllClients', 'SendPacketToClient', and 'SendPacketToAllClients' respectively"}),"\n",(0,d.jsx)(n.li,{children:"Changed the index name for the Roblox services table. 'ServicesRBX' -> 'Services'"}),"\n",(0,d.jsx)(n.li,{children:"Removed index based module loading and added functions to load modules instead"}),"\n",(0,d.jsx)(n.li,{children:"Removed optional DEBUG argument in the .Init function of Scrypt"}),"\n",(0,d.jsx)(n.li,{children:"Improved module require safety"}),"\n",(0,d.jsx)(n.li,{children:"Added .Utils property to access some basic pure functions often used in functional programming"}),"\n",(0,d.jsxs)(n.li,{children:["Improvements to documentation","\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Typo fixes (x1)"}),"\n",(0,d.jsx)(n.li,{children:"Added pages for Services and Controllers"}),"\n",(0,d.jsx)(n.li,{children:"Fixed inaccurate API for the 'RequestPacket' function"}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v003-alpha",children:"v0.0.3-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"12302024",children:"12/30/2024"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsxs)(n.li,{children:["Fixed issue with network where even when specifying event type, an ",(0,d.jsx)(n.code,{children:"UnreliableRemoteEvent"})," would be created causing errors"]}),"\n",(0,d.jsx)(n.li,{children:"Fixed issue with built in intellisense where Scrypt.LocalPlayer was not visible"}),"\n",(0,d.jsx)(n.li,{children:"Removed Preloader script dependancy"}),"\n",(0,d.jsxs)(n.li,{children:["Improvements to documentation","\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Added pages for Services and Controllers"}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v002-alpha",children:"v0.0.2-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"12292024",children:"12/29/2024"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsxs)(n.li,{children:["Added support for ",(0,d.jsx)(n.code,{children:"UnreliableRemoteEvents"})]}),"\n",(0,d.jsx)(n.li,{children:'Removed "DO NOT USE WITHOUT PERMISSION" comment at the top (initially Scrypt was planned to be closed source)'}),"\n",(0,d.jsx)(n.li,{children:"Minor improvements to usage with the network functions"}),"\n"]}),"\n",(0,d.jsx)(n.h2,{id:"v001-alpha",children:"v0.0.1-alpha"}),"\n",(0,d.jsx)(n.h4,{id:"12172024",children:"12/17/2024"}),"\n",(0,d.jsxs)(n.ul,{children:["\n",(0,d.jsx)(n.li,{children:"Initial release build"}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,r.R)(),...e.components};return n?(0,d.jsx)(n,{...e,children:(0,d.jsx)(c,{...e})}):c(e)}},8453:(e,n,l)=>{l.d(n,{R:()=>t,x:()=>s});var i=l(6540);const d={},r=i.createContext(d);function t(e){const n=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function s(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(d):e.components||d:t(e.components),i.createElement(r.Provider,{value:n},e.children)}}}]);