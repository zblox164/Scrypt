--!strict
local Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))
Scrypt.Init()

local SessionLogger = {}

local HttpService: HttpService = Scrypt.ServicesRBX.HttpService
local Sessions: {[Player]: string} = {}

-- Logs a players unique session
function SessionLogger.LogUniqueSession(Player: Player)
	local SessionGUID = HttpService:GenerateGUID()
	local SessionID = SessionGUID
	
	Sessions[Player] = SessionID
end

-- Returns the players unique session ID
function SessionLogger.GetUniqueSession(Player: Player): string
	local Session = Sessions[Player]
	if not Session then
		SessionLogger.LogUniqueSession(Player)
		Session = Sessions[Player]
	end
	
	return Session
end

-- Erases a session
function SessionLogger.EraseSession(Player: Player)
	Sessions[Player] = nil
end

return SessionLogger