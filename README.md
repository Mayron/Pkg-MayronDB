# LibMayronDB
A Lua Database Framework for World of Warcraft

## Introduction

* A new lightweight database designed for smart use. 
* Originally created for MayronUI, but has been created for general use. 
* Supports a defaults table and database table inheritance.
* The functions in the API are named the same as those found in the AceDB for developers to easily familiarise themselves with it. However, some functions support additional functionality.

## How it Works

Using a query, such as `db.profile.aModule.aValue`, will use the Observer framework to select the correct profile table (using `db.profile`), or the global table (using `db.global`). Observers are tables/nodes in the database table tree. They store the current path address used to identify their place within the tree, and decide what values should be retrieved during a query (indexing Observers). During a query, other path keys, such 
as "aModule" or "aValue", will be searched using the Observer's path address to select the correct tables. 

* If you try to index a value at a given path address that does not exist in the saved variable table, then it will switch to using the defaults table.
* If you attempt to add a value to the database whose value is equal to the value found within the defaults table at the given path address, then it will be removed from the saved variable table.
*  You can create a database table to hold template data, and other tables to inherit from the template by setting the template as a parent: `db.profile.aFrame:SetParent(db.profile.frameTemplate)`.
* Using `db.profile` will point to the character's current profile automatically.

Path addresses vs Observers using `db.profile.aTable` as an example:

* Both `db.profile` and `db.profile.aTable` are Observers.
* `db.profile` holds the path address `"db.profile"`.
* `db.profile.aTable` holds the path address `"db.profile.aTable"`.

Three steps occur when indexing an Observer:

*  Check if the key/value pair is located in the saved variable table.
*  If not found, check if the key/value pair is located in the defaults table.
*  If not found, check if the Observer has a parent. If it does, repeat step 1 using the parent Observer.

## Starting the Database

* Make sure you load the library before loading your addon!
* `MY_ADDON_DB` represents the saved variable registered in the toc file to store your database (example: MyAddonDB).
* `MY_ADDON_DB_NAME` represents the (string) name of your addon's saved variable used for storing the database (example: "MyAddonDB").
* `MY_ADDON_NAME` represents the (string) name of your addon (example: "MyAddon").
* The saved variable needs to be registered inside your addon's toc file:

```
## SavedVariables: MY_ADDON_DB
```

```
local db = LibStub:GetLibrary("LibMayronDB"):CreateDatabase("MY_ADDON_DB_NAME", "MY_ADDON_NAME");

db:OnStart(function(self)
	-- your code here! 
	-- self is a reference to the database.
end);
```

## Adding Default Values

For both methods, you can add database default values `before and after` starting the database:

```
-- Optional: You can add default values before and after starting the database:
db:AddToDefaults("profile.newModule", {
	width = 500,
	height = 300,
	data = {}
});
```
## Using the Database

Then, once the database has been successfully started, you can start adding onto the `db.global` and
`db.profile` tables (Observers) like a standard table.

```
db.profile.myModule = {};
db.profile.myModule.aSetting = true;
print(db.profile.newModule.width); -- prints 500
print(db:GetCurrentProfile()); -- prints "Default"
db:SetProfile("new profile");
print(db.profile.newModule.width); -- fails because newModule table is not stored on "new profile"
```

## Database API

`LibMayronDB:CreateDatabase(svName, addonName)`

Creates the database but does not initialize it. Can add default values but cannot
directly communicate with the saved variable table or profiles until after "ADDON_LOADED" event.

**@param** (string) svName: The name of the saved variable defined in the toc file.
**@param** (string) addonName: The name of the addon to listen out for. If supplied it will start the database automatically after the ADDON_LOADED event has fired and the saved variable becomes accessible.
**return** (table): The database object.

***

`db:OnStart(func)`

**@param** (function) func: Assign a function handler to the database OnStart event. The function 
will receive a reference to the database as its first argument.

***

`db:AddToDefaults(path, value)`

Can be used without the database being initialized.

**@param** (string) path: The path to locate a new value being added into the database defaults table.
**@param** (any) value: The new value to be added into the database defaults table.
**@return** (boolean): Whether a key and value pair was added successfully.

Example: `db:AddToDefaults("profile.aModule['red theme'][10].object", value)`

***

`db:PrintDefaults(depth, path)`

A helper function to print the defaults table.

**@param** (optional | int) depth: The depth of tables to print before only printing table references.
**@param** (optional | string) path: Used to print a table within the defaults table rather than the whole thing.

***

`db:SetProfile(name)`

Sets the addon profile for the currently logged in character and creates a new profile if the named profile does not exist.

**@param** (string) name: The name of the profile to assign to the character.

***

`db:GetProfiles()`

**@return** (table): A table containing string profile names for all profiles associated with the addon.

***

`db:IterateProfiles()`

Usable in a for loop to loop through all profiles associated with the AddOn.
Each loop returns values: id, profileName, profile

* (int) id: current loop iteration
* (string) profileName: the name of the profile
* (table) profile: the profile data

***

`db:GetNumProfiles()`

**@return** (int): The number of profiles associated with the addon.

***

`db:ResetProfile(name)`

Helper function to reset a profile.

**@param** (string) name: The name of the profile to reset.

***

`db:RenameProfile(oldName, newName)`

Renames an existing profile to a new profile name. If the new name already exists, it appends a number
to avoid clashing: 'example (1)'.

**@param** (string) oldName: The old profile name.
**@param** (string) newName: The new profile name.

***

`db:RemoveProfile(name)`

Moves the profile to the bin. The profile cannot be accessed from the bin. 
Use db:RestoreProfile(name) to restore the profile.

**@param** (string) name: The name of the profile to move to the bin.

***

`db:RestoreProfile(name)`

Profiles will remain in the bin until a reload of the UI occurs. 
If the bin contains a profile, this function can restore it.

**@param** (string) name: The name of the profile located inside the bin.

***

`db:GetCurrentProfile()`

**@return** (string): The current profile associated with the currently logged in character.

***

`db:ParsePathValue(path, root, returnObserver)`

Turns a path address into the located database value.

**@param** (string) path: The path of the database value. Example: "db.profile.table.myValue"
**@param** (optional | table) root: The root table to locate the value the path address is pointing to. Default is db.
**@param** (optional | boolean) returnObserver: If the located value is a table, should the raw table be returned, or an observer pointing to the table?
**@return** (any): The value found at the location specified by the path address.
    Might return nil if the path address is invalid, or no value is located at the address.

Example: `value = db:ParsePathValue("global.core.settings[" .. moduleName .. "][5]")`

***

`db:SetPathValue(path, value, root)`

Adds a value to the database at the specified path address. 

**@param** (string) path: The path address (i.e. "db.profile.aModule.aValue") of the database value.
**@param** (any) value: The value to assign to the database.
**@param** (optional | table) root: The root table. Default is db.
**@return** (boolean): Returns if the value was successfully added. If the path address was
    invalid, then false will be returned.

Example: `db:SetPathValue("profile.aModule.aSubTable[" .. attributeName .. "][5]", value)`

***

`db:AppendOnce(path, value, registryKey)`

Adds a new value to the saved variable table only once. Registers the added value with a registration key.

**@param** (string) path: The path address to specify where the value should be appended to.
**@param** (any) value: The value to be added.
**@param** (optional | string) registryKey: Instead of using the path address as a key, use a different
    key to register the appended action to the saved variable table. This can be helpful for updating
    the addon using version control by changing the key to something else and re-appending.
**@return** (boolean): Returns whether the value was successfully added.

***

## Observer API

`Observer:SetParent(parentObserver)`

Used to achieve database inheritance. If an observer cannot find a value, it uses the value found in the parent table. Useful if many separate tables in the saved variables table should use the same set of default values. Non-static method used on an Observer object.

**@param** (Observer) parentObserver: Which observer should be used as the parent.

Example: `db.profile.aFrame:SetParent(db.global.frameTemplate)`

***

`Observer:GetParent()`

**@return** (Observer): Returns the current Observer's parent.***

***

`Observer:GetTable()`

Returns a table containing all values cloned from the default and saved variable table. Changing values in the returned table will not affect the original values. For read-only use. Clones values starting at the Observers path address. 

**@return** (table): A table containing cloned values, from the default and saved  variable table, using the observers location.

Example: `db.profile.aModule:GetTable()`

***

`Observer:Iterate()`

Usable in a for loop. Uses the merged table to iterate through key and value pairs of the default and 
saved variable table paired together using the Observer path address.

```
for key, value in db.profile.aModule:Iterate() do
	print(string.format("%s : %s", key, value))
end
```

***

`Observer:GetLength()`

**@return** (int): The length of the merged table (Observer:GetTable()).***

`Observer:Remove()`

Used to remove a table in the saved variable database **and clean the database**. Cannot be used to remove any other value type!

Example: `db.global.deleteMe:Remove()`

***

`Observer:Print(depth)`

A helper function to print all contents of a table pointed to by the selected Observer.

**param** (optional | int) depth: The depth of tables to print before only printing table references.

Example: `db.profile.aModule:Print()`
