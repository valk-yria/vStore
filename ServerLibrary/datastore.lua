-- Services
local Players = game:GetService("Players")
local DatastoreService = game:GetService("DataStoreService")

-- Variables
local pass = "ew python sucks"


local datastore = {}


--[[ datastore.GetDatastoresInfo(prefix, pages, format, locale)
PARAMETERS: 
- <string> prefix : The phrase to find your datastore with based on name.
- <number> pages : The amount of datastores to return per page.
- <string> format : The format string. Defaults to "LLL".
- <string> locale : The locale string. Defaults to "en-us".

RETURNS:
- <table> datastores : A table of datastores information.

* This function also allows you to specify the format and locale for your timestamps.
* For more info, read here: https://developer.roblox.com/en-us/articles/datetime-format-strings
Returns a table of info of datastores opened in your game. Also exposes the parameters to ListDataStoresAsync(). ]] 
function datastore.GetDatastoresInfo(prefix: string, pages: number, format: string, locale: string)
	local datastores = {}
	
	local success, result = pcall(function()
		return DatastoreService:ListDataStoresAsync(prefix, pages)
	end)
	
	if not success then error(string.format("Datastore library call error - %s", result))
	else
		local f = format or "LLL"
		local l = locale or "en-us"
		
		while true do
			local items = result:GetCurrentPage()
			
			for a, b in ipairs(items) do
				local info = {}
				info["DatastoreName"] = b.DataStoreName
				info["CreatedTime"] = DateTime.fromUnixTimestampMillis(b.CreatedTime):FormatUniversalTime(f, l)
				info["UpdatedTime"] = DateTime.fromUnixTimestampMillis(b.UpdatedTime):FormatUniversalTime(f, l)
				
				table.insert(datastores, info)
			end
			
			if result.IsFinished then break end
			result:AdvanceToNextPageAsync()
		end
		
		return datastores 
	end
end


--[[ datastore.GetDatastoreLimits()
PARAMETERS: 
- nil.

RETURNS:
- <table> limits : A table of datastore limit amount.

Returns a table of info of datastore limits amount. ]] 
function datastore.GetDatastoreLimits()
	local limits = 
		{
			["Get"] = DatastoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),
			["GetSorted"] = DatastoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync),
			["Set"] = DatastoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync),
			["SetSorted"] = DatastoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementSortedAsync),
			["Update"] = DatastoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync),
			["UpdateOut"] = DatastoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.OnUpdate),
		}
	
	return limits
end


return datastore