# About LibMayronDB

* A new lightweight database designed for smart use. 
* Originally created for MayronUI, but has been created for general use. 
* Supports a defaults table and database table inheritance.
* The functions in the API are named the same as those found in the AceDB for developers to easily 
familiarise themselves with it. However, some functions support additional functionality.

**Note: The zip file contains the LibMayronObjects dependency!**

# How it works

Using a query, such as `db.profile.aModule.aValue`, will use the Observer framework to select the correct profile 
table (using `db.profile`), or the global table (using `db.global`). Observers are tables/nodes in the database 
table tree. They store the current path address used to identify their place within the tree, and decide 
what values should be retrieved during a query (indexing Observers). During a query, other path keys, such 
as "aModule" or "aValue", will be searched using the Observer's path address to select the correct tables. 

* If you try to index a value at a given path address that does not exist in the saved variable table, 
then it will switch to using the defaults table.
* If you attempt to add a value to the database whose value is equal to the value found within the 
defaults table at the given path address, then it will be removed from the saved variable table.
*  You can create a database table to hold template data, and other tables to inherit from the template
by setting the template as a parent: `db.profile.aFrame:SetParent(db.profile.frameTemplate)`.
* Using `db.profile` will point to the character's current profile automatically.

### Path addresses vs Observers using `db.profile.aTable` as an example:

* Both `db.profile` and `db.profile.aTable` are Observers.
* `db.profile` holds the path address `"db.profile"`.
* `db.profile.aTable` holds the path address `"db.profile.aTable"`.

### Three steps occur when indexing an Observer:

*  Check if the key/value pair is located in the saved variable table.
*  If not found, check if the key/value pair is located in the defaults table.
*  If not found, check if the Observer has a parent. If it does, repeat step 1 using the parent Observer.

# Starting the Database

* Make sure you load the library before loading your addon!
* **MY_ADDON_DB** represents the saved variable registered in the `toc` file to store your database (example: MyAddonDB).
* **MY_ADDON_DB_NAME** represents the (string) name of your addon's saved variable used for storing the database (example: "MyAddonDB").
* **MY_ADDON_NAME** represents the (string) name of your addon (example: "MyAddon").
* The saved variable needs to be registered inside your addon's toc file:

```toc
## SavedVariables: MY_ADDON_DB
```

```lua
local db = LibStub:GetLibrary("LibMayronDB"):CreateDatabase("MY_ADDON_DB_NAME", "MY_ADDON_NAME");

db:OnStart(function(self)
	-- your code here! 
	-- self is a reference to the database.
end);
```

# Adding Default Database Values

For both methods, you can add database default values **before and after** starting the database:

```lua
-- Optional: You can add default values before and after starting the database:
db:AddToDefaults("profile.newModule", {
	width = 500,
	height = 300,
	data = {}
});
```

# Using the Database

Then, once the database has been successfully started, you can start adding onto the `db.global` and
`db.profile` tables (Observers) like a standard table.

```lua
db.profile.myModule = {};
db.profile.myModule.width = 500;

print(db.profile.myModule.width); -- prints 500
print(db:GetCurrentProfile()); -- prints "Default"

db:SetProfile("new profile");

print(db.profile.newModule.width); -- fails because newModule table is not stored on "new profile"
```

# Library Functions

## LibMayronDB:CreateDatabase(svName, addonName)

Creates the database but does not initialize it. Can add default values but cannot
directly communicate with the saved variable table or profiles until after "ADDON_LOADED" event.

#### Parameters:
| params       | type       | description |
| ------------ |:----------:| ----------- |
| `svName`     | **string** | The name of the saved variable defined in the toc file.|
| `addonName`  | **string** | The name of the addon to listen out for. If supplied it will start the database automatically after the `ADDON_LOADED` event has fired and the saved variable becomes accessible. |

#### Return values:
| type | description |
| ---- | ----------- |
| **table** | The database object. |

## LibMayronDB:GetDatabase(addonName)

Gets the database registered with the specified AddOn name. Must be registered using `CreateDatabase`, else nil will be returned. Note that the database does not need to have been started for the database to be returned using this function.

#### Parameters:
| params       | type       | description |
| ------------ |:----------:| ----------- |
| `addonName`  | **string** | The name of the addon registered with the library. |

#### Return values:
| type       | description |
|:----------:| ----------- |
| **Database or nil** | The created/registered database object associated with the AddOn specified by `addonName`. |

## LibMayronDB:IterateDatabases()

Returns `addOnName, db (the database object)` for each registered database (using `db:CreateDatabase()`) per iteration.

# Database API

## db:OnStart(func)

#### Parameters:
| params        | type           | description  |
| ------------- |:-------------:| -----|
| `func`     | **function** | Assign a function handler to the database OnStart event. The function will receive a  eference to the database as its first argument.|

## db:OnProfileChange(callback)
Hooks a callback function onto the `"OnProfileChange"` event to be called when the database changes profile (i.e. only changed by the user using `db:SetProfile()` or `db:RemoveProfile(currentProfile)`).

The callback function will be executed with 3 arguments:
* 1st argument = self reference to the database
* 2nd argument = the new profile name 
* 3rd argument = the old profile name

#### Parameters:
| params | type | description |
| ------ |:----:| ----------- |
| `callback`   | **function** | The function to be called after the profile for the database has been changed. |

## db:AddToDefaults(path, value)
Can be used without the database being initialized.

#### Parameters:
| params | type | description |
| ------ |:----:| ----------- |
| `path`   | **string** | The path to locate a new value being added into the database defaults table. |
| `value`  | **any** | The new value to be added into the database defaults table. |

#### Return values:
| type | description |
|:----:| ----------- |
| **boolean** | Whether a key and value pair was added successfully. |

#### Example: 

```lua
db:AddToDefaults("profile.aModule['red theme'][10].object", value);
```

## db:PrintDefaults(depth, path)[/COLOR][/SIZE]
A helper function to print the defaults table.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `depth`   | **(optional) int** | The depth of tables to print before only printing table references. |
| `path`  | **(optional) string** | Used to print a table within the defaults table rather than the whole thing. |

## db:SetProfile(name)
Sets the addon profile for the currently logged in character. 
Creates a new profile if the named profile does not exist.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `name` | **(optional) string** | The name of the profile to assign to the character. |

## db:GetProfiles()
Gets a table of all profile names associated with the database (the AddOn saved variable).

#### Return Values:
| type | description |
| ---- | ----------- |
| **table** | A table containing string profile names for all profiles associated with the addon. |

## db:IterateProfiles()
Similar to `db:GetProfiles()` except usable in a for loop to loop through all profiles associated with the AddOn.

Each loop returns values: `id, profileName, profile`

* (`int`) **id**: current loop iteration
* (`string`) **profileName**: the name of the profile
* (`table`) **profile**: the profile data

## db:GetNumProfiles()

#### Return Values:
| type | description |
| ---- | ----------- |
| **int** | The number of profiles associated with the addon. |

## db:ResetProfile(name)

A helper function to reset a profile.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `name` | **string** | The name of the profile to reset. |

## db:RenameProfile(oldName, newName)

Renames an existing profile to a new profile name. If the new name already exists, it appends a number
to avoid clashing: `'example (1)'`. This will trigger the `OnProfileChange` event which will trigger any callback associated with this event (see the `db:OnProfileChange(callback)` documentation above).

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `oldName` | **string** | The old profile name. |
| `newName` | **string** | The new profile name. |

## db:RemoveProfile(name)
Moves the profile to the bin. The profile cannot be accessed from the bin. 
Use `db:RestoreProfile(name)` to restore the profile.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `name` | **string** | The name of the profile to move to the bin. |

## db:RestoreProfile(name)
Profiles will remain in the bin until a reload of the UI occurs. 
If the bin contains a profile, this function can restore it.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `name` | **string** | The name of the profile located inside the bin. |

## db:GetProfilesInBin()
Gets all profiles that can be restored from the bin.

#### Return Values:
| type | description |
| ---- | ----------- |
| **table** | An index table containing the names of all profiles in the bin. |

## db:GetCurrentProfile()

#### Return Values:
| type | description |
| ---- | ----------- |
| **string** | The current profile associated with the currently logged in character. |

## db:ParsePathValue(path, root, returnObserver)
Turns a path address into the located database value.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `path` | **string** | The path of the database value. Example: `"db.profile.table.myValue"` |
| `root` | **(optional) table** | The root table to locate the value the path address is pointing to. Default is db. |
| `returnObserver` | **(optional) boolean** | If the located value is a table, should the raw table be returned, or an observer pointing to the table? |

#### Return Values:
| type | description |
| ---- | ----------- |
| **any** | The value found at the location specified by the path address. Might return nil if the path address is invalid, or no value is located at the address. |

#### Example: 
```lua
local value = db:ParsePathValue("global.core.settings[".. moduleName .. "[5]");
```

## db:SetPathValue(path, value, root)
Adds a value to the database at the specified path address. 

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `path` | **string** | The path of the database value. Example: `"db.profile.table.myValue"` |
| `value` | **any** | The value to assign to the database. |
| `root` | **(optional) table** | The root table. Default is db. |

#### Return Values:
| type | description |
| ---- | ----------- |
| **boolean** | Returns if the value was successfully added. If the path address was invalid, then false will be returned. |

#### Example: 

```lua
db:SetPathValue("profile.aModule.aSubTable[".. attributeName .."][5]", value)
```

## db:AppendOnce(path, value, registryKey)
Adds a new value to the saved variable table only once. Registers the added value with a registration key.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `path` | **string** | The path address to specify where the value should be appended to. |
| `value` | **any** | The value to be added. |
| `registryKey` | **(optional) string** | Instead of using the path address as a key, use a different key to register the appended action to the saved variable table. This can be helpful for updating the addon using version control by changing the key to something else and re-appending. |

#### Return Values:
| type | description |
| ---- | ----------- |
| **boolean** | Returns whether the value was successfully added. |

## db:RemoveAppended(path, rootTable, path)
Removes the appended history (i.e. the key registryKey and appended data).

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `rootTable` | **string** | The root database table (observer) to append the value to relative to the path address provided. |
| `path` | **any** | The path address to specify where the value should be removed from. |

#### Return Values:
| type | description |
| ---- | ----------- |
| **boolean** | Returns whether the value was successfully removed. |

## db:GetDatabaseName()
Returns the name of the database which will be the addon name and the saved variable name joined together: `MyAddOn:MY_ADDON_SV`

#### Return Values:
| type | description |
| ---- | ----------- |
| **string** | The name of the database. |

# Observer API

## Observer:SetParent(parentObserver)
Used to achieve database inheritance. If an observer cannot find a value, it uses the value found in the 
parent table. Useful if many separate tables in the saved variables table should use the same set of 
default values. Non-static method used on an Observer object.

It is recommended to always use the notation: `__template` at the start of an abstract database table if using inheritance (i.e. a child Observer representing settings to describe how a certain frame will be rendered inherits from the parent `__templateFrame` table). This is because the database parser will treat tables with a `__template` key differently for memory performance reasons.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `parentObserver` | **Observer** | Which observer should be used as the parent. |

#### Example: 

```lua 
db.profile.aFrame:SetParent(db.profile.__templateFrame);
```

## Observer:GetParent()

#### Return Values:
| type | description |
| ---- | ----------- |
| **Observer** | Returns the current Observer's parent. |

## Observer:HasParent()
Similar to `Observer:GetParent()` except it returns a boolean result.

#### Return Values:
| type | description |
| ---- | ----------- |
| **boolean** | Returns true if the current Observer has a parent. |

## Observer:GetDatabase()
A helper method to get database reference in case it is hard to access.

#### Return Values:
| type | description |
| ---- | ----------- |
| **Database** | The database object associated with the observer |

## Observer:GetSavedVariable()
Gets the underlining saved variables table associated with the observer. Default and parent values will not be included in this!

#### Return Values:
| type | description |
| ---- | ----------- |
| **table or nil** | The underlining saved variables table. If not in the saved variable as the observer only contains default values, or parent values (for example) then `nil` will be returned. |

## Observer:GetDefaults()
Gets the default database table associated with the observer. Real saved variable and parent values will not be included in this!

#### Return Values:
| type | description |
| ---- | ----------- |
| **table or nil** | The default table attached to the database observer if one exists, else `nil` will be returned. |

## Observer:GetUntrackedTable()
Returns an immutable table containing all values from the underlining saved variables table, parent table, and defaults table. Changing this table will not affect the saved variables table! This should be for read-only use and can improve performance if the table is accessed very frequently.

#### Return Values:
| type | description |
| ---- | ----------- |
| **table** | A table containing cloned values from the associated saved variables table, parent table, and defaults table. |

#### Example: 

```lua 
-- settings is now disconnected from the database. It is no longer an Observer!
local settings = db.profile.aModule:GetUntrackedTable();
```

The non-observer, untracked table returned comes with a few additional helper methods:.
* `tbl:GetTrackedTable()` - Converts the untracked table to a tracked, savable, table that track changes to be saved at a later date (see documentation on `Observer:GetTrackedTable()`).
* `tbl:GetObserver()` - Gets the observer originally used to create the untracked table.
* `tbl:Refresh()` - Updates all data in the table to reflect the current data found in the database to keep it in sync.

## Observer:GetTrackedTable()
Returns a table containing all values from the underlining saved variables table, parent table, and defaults table and tracks all changes but does not apply them until `tbl:SaveChanges()` is called.

#### Return Values:
| type | description |
| ---- | ----------- |
| **table** | A tracking table containing all merged values and some helper methods. |

The non-observer, tracked table returned also comes with additional methods:
* `tbl:ResetChanges()` - Resets any pending changes so that calling `tbl:SaveChanges()` will not apply anything.
* `tbl:GetUntrackedTable()` - Converts the tracked table to a standard, read-only, table that does not track changes.
* `tbl:GetObserver()` - Gets the observer originally used to create the tracked table.
* `tbl:GetTotalPendingChanges()` - Returns the total nubmer of changes pending to be saved to the database.
* `tbl:SaveChanges()` - Saves all pending changes to the database, after which the call to `GetTotalPendingChanges` will be 0.
* `tbl:Iterate()` - Iterates through all values in the table (using the underlining untracked table, so any changes made to an iterated value will not be saved/added to the change history).
* `tbl:Refresh()` - Updates all data in the table to reflect the current data found in the database to keep it in sync.

#### Example: 

```lua 
-- settings is now disconnected from the database. It is no longer an Observer!
-- However, you can save changes made which will be written to the database.
local settings = db.profile.aModule:GetTrackedTable();

settings.newValue = 5;
print(settings:GetTotalPendingChanges()) -- prints 1
settings:SaveChanges(); -- save to database
print(settings:GetTotalPendingChanges()) -- prints 0

settings.newValue = 10;
print(settings:GetTotalPendingChanges()) -- prints 1
settings:ResetChanges(); -- remove tracked history to avoid saving to the database
print(settings:GetTotalPendingChanges()) -- prints 0
```

## Observer:Iterate()
Usable in a for loop. Uses the merged table to iterate through key and value pairs of the default and saved variable table paired together using the Observer path address.

```lua
for key, value in db.profile.aModule:Iterate() do
	print(string.format("%s : %s", key, value))
end
```

## Observer:GetLength()

#### Return Values:
| type | description |
| ---- | ----------- |
| **int** | The length of the merged table (Observer:GetTable()). |

## Observer:Remove()

Used to remove a table in the saved variable database **and clean the database**. 
Cannot be used to remove any other value type!

#### Example: 

```lua
db.global.deleteMe:Remove()
```

## Observer:Print(depth)
A helper function to print all contents of a table pointed to by the selected Observer.

#### Parameters:
| params | type | description |
| ------ | ---- | ----------- |
| `depth` | **(optional) int** | The depth of tables to print before only printing table references. |

#### Example: 
```lua
-- prints all values found in aModule, and also prints the contents of tables inside aModule but no further as we are specified recursion using a depth of 2:
db.profile.aModule:Print(2)
```