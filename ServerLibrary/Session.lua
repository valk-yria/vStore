-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Datastore = game:GetService("DataStoreService")

-- Properties
local limit = 10

local defaults = {}
local cache = nil

-- Init
Session = {}
Session.__index = Session

Session.AllSessions = {}

-- Internals
local function InternalGet(session)
	local success, results, info = pcall(function()
		return session.Datastore.UpdateAsync(session.Datastore, session.Id, function(old)
			if Session.Getter ~= nil then Session.Getter(old)
			else 
				return old
			end
		end)
	end)

	if not success then warn(string.format("Datastore load ERROR for %s - %s", session.Id, results))
	else
		if info == nil then warn(string.format("Datastore load WARNING for %s - no data exists!", session.Id)) 
		else 
			print(string.format("Datastore load SUCCESS for %s.", session.Id)) 
			return results, info
		end
	end
end
local function InternalSet(session, dict)
	local success, results, info = pcall(function()
		return session.Datastore.UpdateAsync(session.Datastore, session.Id, function(old)
			if Session.Setter ~= nil then Session.Setter(old)
			else 
				local new = dict
				return new
			end
		end)
	end)

	if not success then warn(string.format("Datastore save ERROR for %s - %s", session.Id, results))
	else print(string.format("Datastore save SUCCESS for %s.", session.Id)) end
end

-- Property functions
do
	Session.Getter = nil
	Session.Setter = nil

	Session.GetDefaults = function()
		return defaults
	end
	Session.SetDefaults = function(dict)
		defaults = dict
		return defaults
	end
	Session.GetCache = function()
		return cache
	end
	Session.SetCache = function(c)
		cache = require(c)
		return cache
	end
	Session.GetSession = function(id)
		return Session.AllSessions[tostring(id)]
	end
end


--[[ <<CONSTRUCTOR>> Session.new(datastoreName, id)
	PARAMETERS: 
	- <string> datastoreName : The name of the target datastore.
	- <number> id : The number for unique identification.

	RETURNS:
	- <table> Session : A table-as-object containing session properties and methods.

	* This constructor should be the default way of spawning a new Session object.
	Instantiates a new Session object. ]] 
function Session.new(datastoreName: string, id: number?)
	if cache == nil then error("Cache is nil!") end
	
	local newSession = {}

	newSession.Id = tostring(id)
	newSession.Datastore = Datastore:GetDataStore(datastoreName, id, Instance.new("DataStoreOptions"):SetExperimentalFeatures({["v2"] = true}))
	newSession.Lock = game.JobId .. "_" .. os.time()

	Session.AllSessions[newSession.Id] = newSession

	return setmetatable(newSession, Session)
end


-- GET methods
do
	function Session:GetFromStoreAsync()
		cache[self.Id] = InternalGet(self)
		return cache[self.Id]
	end

	function Session:GetFromStoreAsyncMore()
		cache[self.Id] = InternalGet(self)
		print(cache[self.Id])
		return cache[self.Id]
	end

	function Session:GetFromStoreAsyncVerbose(format: string, locale: string)
		local data, info = InternalGet(self)

		local f = format or "LLL"
		local l = locale or "en-us"

		cache[self.Id] = data

		print(cache[self.Id])
		print(string.format("Datastore Name - %s", self.Datastore.Name))
		print(string.format("Datastore Version - %s", info.Version))
		print(string.format("Datastore Creation Time - %s", tostring(DateTime.fromUnixTimestampMillis(info.CreatedTime):FormatUniversalTime(f, l))))
		print(string.format("Datastore Updation Time - %s", tostring(DateTime.fromUnixTimestampMillis(info.UpdatedTime):FormatUniversalTime(f, l))))
		--print(info:GetUserIds())
		--print(info:GetMetadata())

		return cache[self.Id]
	end
end

-- SET methods
do
	function Session:SetToStoreAsync()
		InternalSet(self, cache[self.Id])
	end

	function Session:InitializeAsync(dict)
		InternalSet(self, dict)
		return self:GetFromStoreAsync()
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
		local success, results = pcall(function()
			self.Datastore:SetAsync(self.Id, 0)
		end)

		if not success then warn(string.format("Datastore wipe error for %s - %s", self.Id, results))
		else print(string.format("Datastore wipe success for %s.", self.Id)) end
	end

	function Session:ClearCache()
		cache[self.Id] = nil
		warn(string.format("Cache for %s has been cleared", self.Id))
	end

	function Session:Kill()
		Session.AllSessions[self.Id] = nil
	end
end


return Session