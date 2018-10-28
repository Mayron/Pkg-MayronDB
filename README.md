# LibMayronDB-2.0
A Lua Database Framework for World of Warcraft

**Homepage:** http://www.wowinterface.com/downloads/info24356-LibMayronDB.html

## Introduction

* A new lightweight database designed for smart use. 
* Originally created for MayronUI, but has been created for general use. 
* Supports a defaults table and database table inheritance.
* The functions in the API are named the same as those found in the AceDB for developers to easily familiarise themselves with it. However, some functions support additional functionality.

## Dependencies

* LibMayronObjects-2.7+

## How it Works

Using a query, such as `db.profile.aModule.aValue`, will use the Observer framework to select the correct profile table (using `db.profile`), or the global table (using `db.global`). Observers represent tables in the database table tree. They store the current path address used to identify their place within the tree, and decide what values should be retrieved during a query (indexing Observers). During a query, other path keys, such as "aModule" or "aValue", will be searched using the Observer's path address to select the correct tables. 

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
local db = LibStub:GetLibrary("LibMayronDB"):CreateDatabase("MY_ADDON_NAME", "MY_ADDON_DB_NAME");

db:OnStart(function(self, addOnName)
	-- your code here! 
	-- self is a reference to the database (db).
	-- you can use it to get access to the global or profiles table
	-- for example: self.profiles.myValue = true;
	-- or use "db" variable: db.profiles.myValue = true;
end);
```

## Adding Default Values

For both methods, you can add database default values `before and after` starting the database:

```
-- Optional: You can add default values before and after starting the database:
db:AddToDefaults(db.profile, "newModule", {
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

`LibMayronDB:CreateDatabase(addonName, svName, manualStartUp)`

Creates the database but does not initialize it until after "ADDON_LOADED" event (unless manualStartUp is set to true).

**@param** (string) addOnName: The name of the addon to listen out for. If supplied it will start the database
    automatically after the ADDON_LOADED event has fired (when the saved variable becomes accessible).
**@param** (string) savedVariableName: The name of the saved variable to hold the database (defined in the toc file).
**@param** (optional | boolean) manualStartUp: Set to true if you do not want the library to automatically start 
    the database when the saved variable becomes accessible. 

**@return** (Database): The database object.

***

`db:OnStartUp(data, callback)`

Hooks a callback function onto the "StartUp" event to be called when the database starts up 
(i.e. when the saved variable becomes accessible). By default, this function is called by the library 
with 2 arguments: the database and the addOn name passed to Lib:CreateDatabase(...).

**@param** (function) callback: The start up callback function

***

`db:OnProfileChanged(data, callback)`

Hooks a callback function onto the "ProfileChanged" event to be called when the database changes profile
(i.e. only changed by the user using db:SetProfile() or db:RemoveProfile(currentProfile)).

**@param** (function) callback: The profile changing callback function

***

`db:AddToDefaults(path, value)`

Adds a value to the database defaults table relative to the path: defaults.<path> = <value>

**@param** (string): a database path string, such as "myTable.mySubTable[2]"
**@param** (any): a value to assign to the database defaults table using the path

Example: `db:AddToDefaults("profile.aModule['red theme'][10].object", value)`

***

`db:Start()`

Starts the database. Should only be used when the saved variable is accessible (after the ADDON_LOADED event has fired).
This is called automatically by the library when the saved variable becomes accessible unless manualStartUp was 
set to true during the call to Lib:CreateDatabase(...).

***

`db:IsLoaded()`

Returns true if the database has been successfully started and loaded.

**@return** (boolean): indicates if the database is loaded.

***

`db:SetPathValue(rootTable, path, value)`

Adds a value to a table relative to a path: rootTable.<path> = <value>

**@param** (table) rootTable: The initial root table to search from. 
**@param** (string) path: a table path string (also called a path address), such as "myTable.mySubTable[2]". 
    This is converted to a sequence of tables which are added to the database if they do not already exist (myTable will be created if not found).
**@param** (any): a value to assign to the table relative to the provided path string.

***

`db:ParsePathValue(rootTable, path)`

Searches a path address (table path string) and returns the located value if found.

**@param** (table) rootTable: The root table to begin searching through using the path address.
**@param** (string) path: The path of the value to search for. Example: "myTable.mySubTable[2]"

**@return** (any): The value found at the location specified by the path address.
Might return nil if the path address is invalid, or no value is located at the address.

Example: value = db:ParsePathValue(db.profile, "mySettings[" .. moduleName .. "][5]");

***

`db:SetProfile(name)`

Sets the addon profile for the currently logged in character. 
Creates a new profile if the named profile does not exist.

**@param** (string) name: The name of the profile to assign to the character.

***

`db:GetCurrentProfile()`

**@return** (string): The current profile associated with the currently logged in character.

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

`db:AppendOnce(rootTable, path, value)`

Adds a new value to the saved variable table only once. Registers the added value with a registration key.

**@param** (Observer) rootTable: The root database table (observer) to append the value to relative to the path address provided.
**@param** (string) path: The path address to specify where the value should be appended to.
**@param** (any) value: The value to be added.
**@return** (boolean): Returns whether the value was successfully added.

***

## Observer API

`Observer:SetParent(parentObserver)`

Used to achieve database inheritance. If an observer cannot find a value, it uses the value found in the 
parent table. Useful if many separate tables in the saved variables table should use the same set of 
changable values when the defaults table is not a suitable solution.

**@param** (optional | Observer) parentObserver: Which observer should be used as the parent. 
    If this is nil, the parent is removed.
    
Example: `db.profile.aFrame:SetParent(db.global.frameTemplate)`

***

`Observer:GetParent()`

**@return** (Observer): Returns the current Observer's parent.***

***

`db:HasParent()`

**@return** (boolean): Returns true if the current Observer has a parent.

***

`Observer:ToTable()`

Creates an immutable table containing all values from the underlining saved variables table, 
parent table, and defaults table. Changing this table will not affect the saved variables table!

**@return** (table): a table containing all merged values

Example: `db.profile.aModule:ToTable()`

***

`Observer:ToSavedVariable()`

Gets the underlining saved variables table. Default or parent values will not be included in this!

**@return** (table): the underlining saved variables table.

***

`Observer:Iterate()`

Usable in a for loop. Uses the merged table to iterate through key and value pairs of the default and 
saved variable table paired together using the Observer path address.

Example:

    for key, value in db.profile.aModule:Iterate() do
        print(string.format("%s : %s", key, value))
    end

***

`Observer:IsEmpty()`

**@return** (boolean): Whether the merged table is empty.

***

`Observer:Print(depth)`

A helper function to print all contents of a table pointed to by the selected Observer.

**@param** (optional | int) depth: The depth of tables to print before only printing table references.

Example: `db.profile.aModule:Print()`

***

`Observer:GetLength()`

**@return** (int): The length of the merged table (Observer:ToTable()).

***

`Observer:GetPathAddress() `

Helper function to return the path address of the observer.
**@return** (string): The path address

Example: `db.profile.aModule:Print()`
