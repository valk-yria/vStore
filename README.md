# vStore
**NOTE:** This is a work-in-progress, some features may not work currently. Use at your own discretion.

--------

The result of what happens when I don't trust third-party modules and choose to write one myself, vStore is an object-oriented datastore wrapper designed to interface well with Roblox's datastores. This is loosely based on loleris' [ProfileService](https://github.com/MadStudioRoblox/ProfileService) module.

This is also equipped with the `datastore` library for easier method calls from Roblox's `DataStoreService`.





### **Object-Oriented**
> Spawn new sessions and mutate data using vStore for each player/object like as if you are changing the properties of a part. 
> 
> Manage and view data in a way that's clean, efficient and readable, using the syntax you're most familiar with.

```lua
local Session = require("Session")

local key = 1
local newSession = Session.new("DatastoreName", key)

local results = newSession:GetFromStoreAsync()
results.TestKey1 = "test"
results.TestKey2 = "reeeee"
results.TestKey3 = "this module is cool!"
print(results)

newSession:SetToStoreAsync()
newSession:KillAsync()
```

### **Feature-Ready**
> Equipped with features such as:
> - caching
> - datastore 2.0
> - automatic retrying
> - session locking
> 
> vStore ensures your games remain most performant, up-to-date, and reliable.

### **Easy to learn**
> vStore is well encapsulated and does the heavy lifting behind the scenes for you, so you only need to worry about the important things - getting datastore work done quickly and cleanly.

### **Made and used by me!**
> Because I use this module heavily myself, whatever patches I release will also be published for all to use. 
> 
> Any bug you find will eventually affect me too, so I try my best to fix them asap.
