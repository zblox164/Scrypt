## v0.0.63-alpha
* Fixed network argument validation check bug
* Minor warning typo fix

## v0.0.62-alpha
#### 01/02/2026
* Fixed network argument validation error logs not showing up
* Edited argument order for `SendPacketToAllClients`
* Added unadded Roblox services to RBXServices.luau
* Improvements to documentation
    * Added readonly tags
    * Added version tags to functions
    * Added information in API about :Replicate() feature

## v0.0.61-alpha
#### 11/06/2025
* Added version property
* Minor improvements
* Fixed bug with client network requests

## v0.0.6-alpha
#### 08/05/2025
* Added new function to ServerNetwork: 'Listen'
* Added new function to ServerNetwork: 'ListenForRequest'
* Added new function to ClientNetwork: 'Listen'
* Added extra type support for network packets
* Removed Promise and RegExp modules
* Renamed 'ListenForRequest' to 'ListenForRequestPacket'
* Renamed 'EmptyRequest' to 'Request'
* Added unadded Roblox services to RBXServices.luau
* Minor bug fixes
* Minor improvements
* Improvements to documentation
    * Minor improvements

## v0.0.51-alpha
#### 04/12/2025
* Fixed network bug where non instances would cause errors (as a result of the replicate feature)
* Fixed minor issues
* Minor improvements
* Improvements to documentation
    * Added information for GUI module on the 'Getting Started' page
    * Added information for replicate feature

## v0.0.5-alpha
#### 02/13/2025
* Added the Maybe monad
* Added functionality the network system when sending instances from server to client
* Added StarterPack and StarterPlayer to the RBXServices script. Both can now be used like any other Roblox Service
* Minor code improvements
* Minor docs improvements

## v0.0.43-alpha
#### 01/23/2025
* Fixed major framework load bug
* Improved GUI module
* Changed files to .luau

## v0.0.42-alpha
#### 01/18/2025
* Fixed bug with ServerNetwork where when the client creates a remote, it would not get parented to the comms folder
* Added GUI internal module
* Minor improvements
* Improvements to documentation
    * Updated changelog (it didn't update last version)

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