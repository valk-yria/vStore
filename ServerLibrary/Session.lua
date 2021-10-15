-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Datastore = game:GetService("DataStoreService")

-- Init
Session = {}
Session.__index = Session

-- Properties
local retries = 10
local waitDuration = 5
local defaults = {}
local cache = nil

-- Internals
local function InternalGet(session)
	local cap = 0
	local success, results, info

	print(string.format("Attempt to load for %s...", session.Id))

	while not success and cap < retries do 
		cap += 1
		success, results, info = pcall(function()
			return session.Datastore.UpdateAsync(session.Datastore, session.Id, function(old)
				return old
			end)
		end)
		
		if success == true then break end
	end
	
	if cap >= retries or session.Lock ~= game.JobId then
		local s = "Datastore load ERROR for %s - "
		if cap >= retries then s ..= "game has hit the maximum amount of retries!"
		elseif session.Lock ~= game.JobId then s ..= "a lock is already present!"
		end
		
		warn(string.format(s, session.Id))
		warn(string.format("A new default data is generated for %s. This will not save!", session.Id)) 
		
		session.Enabled = false
		
		return defaults, info
	end
	
	if results == nil then
		warn(string.format("Datastore load WARNING for %s - no data exists.", session.Id))
		warn(string.format("A default data set will be provided for %s.", session.Id))
		return defaults, info
	else 
		print(string.format("Datastore load SUCCESS for %s.", session.Id)) 
		return results, info
	end
end
local function InternalSet(session, dict)
	local success, results, info
	
	print(string.format("Attempt to save for %s...", session.Id))
	
	while not success do 
		success, results, info = pcall(function()
			if session.Enabled == true then
				return session.Datastore.UpdateAsync(session.Datastore, session.Id, function(old)
					return dict
				end)
			else warn(string.format("Datastore save WARNING for %s - save is disabled.", session.Id)) 
			end
		end)

		if success == true then
			print(string.format("Datastore save SUCCESS for %s.", session.Id))
			break 
		else 
			warn(string.format("Datastore save WARNING for %s - failed to save, retrying!", session.Id)) 
			wait(waitDuration)
		end
	end
end

-- Properties
do
	Session.GetDefaults = function()
		return defaults
	end
	Session.SetDefaults = function(dict)
		defaults = dict
	end
	Session.GetCache = function()
		return cache
	end
	Session.SetCache = function(c)
		cache = require(c)
	end
	Session.GetRetries = function()
		return retries
	end
	Session.SetRetries = function(l)
		retries = l
	end
	Session.GetWait = function()
		return waitDuration
	end
	Session.SetWait = function(w)
		waitDuration = w
	end
end


function Session.new(datastoreName: string, id: number?)
	if cache == nil then error("Cache is nil!") end
	if defaults == nil then error("Defaults is nil!") end
	if retries == nil or retries <= 0 then error("Retries is nil or is/under the value of 0!") end
	if waitDuration == nil or waitDuration <= 0 then error("Wait duration is nil or is/under the value of 0!") end

	local newSession = {}

	newSession.Id = tostring(id)
	newSession.Datastore = Datastore:GetDataStore(datastoreName, id, Instance.new("DataStoreOptions"):SetExperimentalFeatures({["v2"] = true}))
	newSession.Lock = game.JobId
	newSession.Enabled = true

	return setmetatable(newSession, Session)
end


-- GET methods
do
	function Session:GetFromStoreAsync()
		local res = InternalGet(self)

		cache[self.Id] = res
		return cache[self.Id]
	end
end

-- SET methods
do
	function Session:SetToStoreAsync()
		InternalSet(self, cache[self.Id])
	end

	function Session:KillAsync()
		cache[self.Lock] = 0
		InternalSet(self, cache[self.Id])
	end
end

-- DEBUG methods
do
	function Session:ListAllKeys()
		local results = {}
		for a, b in pairs(cache[self.Id]) do table.insert(results, a) end

		return results
	end
end

-- ADMIN methods
do
	function Session:WipeStoreAsync()
		local success, results = pcall(self.Datastore.RemoveAsync(self.Datastore, self.Id))

		if not success then warn(string.format("Datastore wipe error for %s - %s", self.Id, results))
		else print(string.format("Datastore wipe success for %s.", self.Id)) 
		end
	end

	function Session:ClearCache()
		cache[self.Id] = nil
		warn(string.format("Cache for %s has been cleared", self.Id))
	end
end


return Session