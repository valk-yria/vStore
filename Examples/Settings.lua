--[[ Persistent Settings
    This example allows you to get/set persistent settings per user from the datastore anytime the user joins or leaves the game.
]]

-- Get services
local Players = game:GetService("Players")

-- Get modules and libraries
local Session = require("Session")

-- Variables
local c = game.ServerStorage.Cache.Settings
local def = {
	["EnableParticles"] = true,
	["EnableTrails"] = true,
}
local r = 10

-- Set defaults
Session.SetDefaults(def)
Session.SetCache(c)
Session.SetRetries(r)

-- All sessions
local allSessions = {}


Players.PlayerAdded:Connect(function(player: Player)
	local uid = tostring(player.UserId)
	local newSession = Session.new("Settings", uid)
	allSessions[uid] = newSession
	
	local results = newSession:GetFromStoreAsync()
	print(results)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	allSessions[tostring(player.UserId)]:SetToStoreAsync()
end)