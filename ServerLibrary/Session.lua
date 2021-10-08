-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Datastore = game:GetService("DataStoreService")

-- Variables
local limit = 10

Session = {}
Session.__index = Session

Session.Defaults = {}
Session.Cache = nil
Session.AllSessions = {}

	
--[[ <<CONSTRUCTOR>> Session.new(datastoreName, id)
	PARAMETERS: 
	- <string> datastoreName : The name of the target datastore.
	- <number> id : The number for unique identification.

	RETURNS:
	- <table> Session : A table-as-object containing session properties and methods.

	* This constructor should be the default way of spawning a new Session object.
	Instantiates a new Session object. ]] 
function Session.new(datastoreName:string, id:string)
	if Session.Cache == nil then error("Cache is nil!") end

	local newSession = {}
		
	newSession.Id = tostring(id)
	newSession.Datastore = Datastore:GetDataStore(datastoreName, id, Instance.new("DataStoreOptions"):SetExperimentalFeatures({["v2"] = true}))
	newSession.Lock = game.JobId .. "_" .. os.time()
	
	Session.AllSessions[newSession.Lock] = newSession
	
	return setmetatable(newSession, Session)
end


-- Raw functions
-- Do not use this in production.
do
	--[[ Session:InternalGet(verify)
	PARAMETERS: 
	- <string> verify : The verify string.

	RETURNS:
	- <table> results : A table of values from the datastore.

	* This method must not be used in production code.
	* To use it anyway, pass "CNJ9124ZXF" as the confirmation string.
	Returns a table of values from the datastore. FOR INTERNAL USE ONLY. ]] 
	function Session:InternalGet(verify:string)
		if verify ~= "CNJ9124ZXF" then error('You are not intended to use InternalGet() directly - use Session:Get() instead. \nTo use it anyway, pass "CNJ9124ZXF" in the brackets.')
		else
			local success, results, info = pcall(function()
				return self.Datastore.UpdateAsync(self.Datastore, self.Id, function(old)
					-- Wish to write your own getter function? Write it here!
					return old
				end)
			end)
			
			if not success then warn(string.format("Datastore load ERROR for %s - %s", self.Id, results))
			else print(string.format("Datastore load SUCCESS for %s.", self.Id)) end
			
			return results, info
		end
	end
	
	--[[ Session:InternalSet(verify, dict)
	PARAMETERS: 
	- <string> verify : The verify string.
	- <table> dict : The dictionary to upload to the datastore.
	
	RETURNS:
	- nil.

	* This method must not be used in production code.
	* To use it anyway, pass "GWTQH983TK" as the confirmation string.
	Sets a table of values to the datastore. FOR INTERNAL USE ONLY. ]] 
	function Session:InternalSet(verify:string, dict)
		if verify ~= "GWTQH983TK" then error('You are not intended to use InternalSet() directly - use Session:Set() instead. \nTo use it anyway, pass "GWTQH983TK" in the brackets.')
		else
			local success, results, info = pcall(function()
				return self.Datastore.UpdateAsync(self.Datastore, self.Id, function(old)
					-- Wish to write your own setter function? Write it here!
					local new = dict
					return new
				end)
			end)
			
			if not success then warn(string.format("Datastore save ERROR for %s - %s", self.Id, results))
			else print(string.format("Datastore save SUCCESS for %s.", self.Id)) end
		end
	end
end

-- Game functions
-- Use this in production.
do
	-- GET methods
	do
		function Session:GetFromStoreAsync()
			Session.Cache[self.Id] = self:InternalGet("CNJ9124ZXF")
			return Session.Cache[self.Id]
		end

		function Session:GetFromStoreAsyncMore()
			Session.Cache[self.Id] = self:InternalGet("CNJ9124ZXF")
			print(Session.Cache[self.Id])
			return Session.Cache[self.Id]
		end

		function Session:GetFromStoreAsyncVerbose(format, locale)
			local data, info = self:InternalGet("CNJ9124ZXF")

			local f = format or "LLL"
			local l = locale or "en-us"

			Session.Cache[self.Id] = data

			print(Session.Cache[self.Id])
			print(string.format("Datastore Version - %s", info.Version))
			print(string.format("Datastore Creation Time - %s", tostring(DateTime.fromUnixTimestampMillis(info.CreatedTime):FormatUniversalTime(f, l))))
			print(string.format("Datastore Updation Time - %s", tostring(DateTime.fromUnixTimestampMillis(info.UpdatedTime):FormatUniversalTime(f, l))))
			--print(info:GetUserIds())
			--print(info:GetMetadata())

			return Session.Cache[self.Id]
		end
	end
	
	-- SET methods
	do
		function Session:SetToStoreAsync()
			self:InternalSet("GWTQH983TK", Session.Cache[self.Id])
		end
		
		function Session:InitializeAsync(dict)
			self:InternalSet("GWTQH983TK", dict)
			return self:GetFromStoreAsync()
		end
	end
	
	-- DEBUG methods
	do
		function Session:ListAllKeys()
			local results = {}
			for a, b in pairs(Session.Cache[self.Id]) do table.insert(results, a) end

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
			Session.Cache[self.Id] = nil
			warn(string.format("Cache for %s has been cleared", self.Id))
		end

		function Session:Kill()
			Session.AllSessions[self.Id] = nil
		end
	end
end


return Session