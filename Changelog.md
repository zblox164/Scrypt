## v0.0.41-alpha
#### 01/13/2025
* Fixed bug with network system where creating a client remote would cause an error
* Fixed issue where some of the functions renamed last update were not updated
* Added public ServerPacketData to Scrypt
* Fixed Packet type (in ClientNetwork and Scrypt)

## v0.0.4-alpha
#### 01/08/2025
* Revamp of internal modules to more closely fit the functional paradigm: Services, Controllers, Server, Client, ServerNetwork, ClientNetwork, and both Scrypt and Network loaders
* Minor code improvements
* Fixed typechecking issue with ClientNetwork and RequestPacket
* Renamed functions 'PingPlayer', 'PingAllPlayers', 'SendPacketToPlayer', and 'SendPacketToAllPlayers' to 'PingClient', 'PingAllClients', 'SendPacketToClient', and 'SendPacketToAllClients' respectively
* Changed the index name for the Roblox services table. 'ServicesRBX' -> 'Services'
* Removed index based module loading and added functions to load modules instead
* Removed optional DEBUG argument in the .Init function of Scrypt
* Improved module require safety
* Added .Utils property to access some basic pure functions often used in functional programming
* Improvements to documentation
    * Typo fixes (x1)
    * Added pages for Services and Controllers
    * Fixed inaccurate API for the 'RequestPacket' function

## v0.0.3-alpha
#### 12/30/2024
* Fixed issue with network where even when specifying event type, an `UnreliableRemoteEvent` would be created causing errors
* Fixed issue with built in intellisense where Scrypt.LocalPlayer was not visible
* Removed Preloader script dependancy
* Improvements to documentation
    * Added pages for Services and Controllers

## v0.0.2-alpha
#### 12/29/2024
* Added support for `UnreliableRemoteEvents`
* Removed "DO NOT USE WITHOUT PERMISSION" comment at the top (initially Scrypt was planned to be closed source)
* Minor improvements to usage with the network functions

## v0.0.1-alpha
#### 12/17/2024
* Initial release build