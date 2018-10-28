local Lib = LibStub:GetLibrary("LibMayronDB");
if (not Lib) then return; end

local db = Lib:CreateDatabase("LibMayronDB", "TestDB");

local function OnStartUp_Test1()  
    print("OnStartUp_Test1 Started");

    db:OnStartUp(function(self, addOnName)
        assert(addOnName == "LibMayronDB", "Invalid params!");    
        assert(self:IsLoaded(), "Database not loaded!");

        print("OnStartUp_Test1 Successful!");
    end);  
end

local function ChangeProfile_Test1()  
    print("ChangeProfile_Test1 Started");

    db:OnProfileChanged(function(self, newProfileName, oldProfileName)
        if (newProfileName == "ChangeProfile_Test1") then
            assert(oldProfileName == "Default");
        elseif (newProfileName == "Default") then
            assert(oldProfileName == "ChangeProfile_Test1");
        end
    end);

    db:OnStartUp(function(self, addOnName)
        self:SetProfile("ChangeProfile_Test1");

        self:RemoveProfile("ChangeProfile_Test1");
        local currentProfileName = self:GetCurrentProfile();
        assert(currentProfileName == "Default");

        print("ChangeProfile_Test1 Successful!");
    end); 
end

local function NewProfileIndex_Test1()  
    print("NewProfileIndex_Test1 Started");

    db:OnStartUp(function(self, addOnName)
        -- self.profile.hello[2].pigs = true;
        self:SetPathValue(self.profile, "hello[2].pigs", true);
        assert(self.profile.hello[2].pigs == true, "Failed to Index");

        self.profile.hello = nil;
        print("NewProfileIndex_Test1 Successful!");
    end);    
end

local function UsingParentObserver_Test1()  
    print("UsingParentObserver_Test1 Started");

    db:OnStartUp(function(self, addOnName)
        -- self.profile.hello[2].pigs = true;

        self.profile.myParent = {
            events = {
                Something = {1, 2, 3},
                MyEvent1 = true
            },
            loaded = {
                module1 = true,
                module2 = false
            }
        };

        self.profile.myChild = {};
        self.profile.myChild:SetParent(self.profile.myParent);
        self.profile.myChild.events:Print();

        print("UsingParentObserver_Test1 Successful!");
    end);    
end

local function UsingParentObserver_Test2()  
    print("UsingParentObserver_Test2 Started");

    db:OnStartUp(function(self, addOnName)
        -- self.profile.hello[2].pigs = true;

        self.profile.myParent = {
            events = {
                Something = {1, 2, 3},
                MyEvent1 = true
            },
            loaded = {
                module1 = true,
                module2 = false
            }
        };

        self.profile.myChild = {};
        self.profile.myChild:SetParent(self.profile.myParent);

        -- this should use SetPathValue to build path into child table
        self.profile.myChild.events.MyEvent1 = false;

        self.profile.myChild:Print();
        assert(self.profile.myChild:ToSavedVariable().events.MyEvent1 == false, "Should be set!");

        print("UsingParentObserver_Test2 Successful!");
    end);    
end

local function UsingParentObserver_Test3()  
    print("UsingParentObserver_Test3 Started");

    db:OnStartUp(function(self, addOnName)
        -- self.profile.hello[2].pigs = true;

        self.profile.myParent = {
            events = {
                Something = {1, 2, 3},
                MyEvent1 = true
            },
            loaded = {
                module1 = true,
                module2 = false
            }
        };

        self.profile.myChild = {};
        self.profile.myChild:SetParent(self.profile.myParent);

        self.profile.myChild.events.MyEvent1 = false; --! This uses "usingChild" for the index changed because events did not exist
        self.profile.myParent.events.MyEvent1 = {message = "hello"}; -- correctly assigns value to parent

        assert(self.profile.myChild.events.MyEvent1 == false, "Should still equal false!");
        assert(self.profile.myParent.events.MyEvent1:ToSavedVariable().message == "hello", "Should only change parent");

        print("UsingParentObserver_Test3 Successful!");
    end);    
end

-- Uncomment to delete test database
-- db:OnStartUp(function(self, addOnName)
--     TestDB = {};
-- end);

--OnStartUp_Test1();
--ChangeProfile_Test1();
--NewProfileIndex_Test1();
--UsingParentObserver_Test1()
--UsingParentObserver_Test2();
--UsingParentObserver_Test3();