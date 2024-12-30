local Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))
Scrypt.Init():Wait()

Scrypt.ClientNetwork.ListenForPacket("TEST", true, function(...)  
    print("Received packet", ...)
end) 