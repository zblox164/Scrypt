In the latest update, there were some changes to existing network functions as well as the removal of some third party modules. The reason for the naming changes is I wanted to keep naming consistent across the framework. 

The function changes were:

#### ServerNetwork
* `Scrypt.ServerNetwork.Listen` -- NEW
* `Scrypt.ServerNetwork.ListenForRequest` -- NEW
* `Scrypt.ServerNetwork.ListenForRequestPacket` -- RENAMED FROM 'ListenForRequest'

#### ClientNetwork
* `Scrypt.ClientNetwork.Listen` -- NEW
* `Scrypt.ClientNetwork.Request` -- RENAMED FROM 'EmptyRequest'

Since I added the new 'Listen' functions, I felt the naming of 'EmptyRequest' needed to be changed as well (I didn't want to name 'Listen', 'EmptyListen'). This hopefully will be a one time thing that will not need to be changed again. Since Scrypt is early in development, I want to get the naming consistent now so that in the future, especially if there are more users, it won't be an issue.

As for the removal of the RegEx and Promise, I wanted to keep Scrypt lightweight and not require any third party modules that are required for the framework to work.