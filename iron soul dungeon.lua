-- Iron Soul: Dungeon - Working Client Hook Script
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Iron Soul: Dungeon Hub",
   LoadingTitle = "Iron Soul Script",
   LoadingSubtitle = "Updated Remotes Hook",
   ConfigurationSaving = { Enabled = false }
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local autoSkillEnabled = false
local walkSpeedValue = 16

local MainTab = Window:CreateTab("Main Features", 4483362458)

-- 1. WORKING WALKSPEED (Loop Based)
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
       walkSpeedValue = Value
   end,
})

-- Continuous loop for WalkSpeed enforcement (Anti-reset)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                if LocalPlayer.Character.Humanoid.WalkSpeed ~= walkSpeedValue then
                    LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
                end
            end
        end)
    end
end)

-- 2. AUTO SKILL CASTING (Keycode Simulator & Remote Detector)
MainTab:CreateToggle({
   Name = "Auto Cast Skills",
   CurrentValue = false,
   Flag = "AutoSkillToggle",
   Callback = function(Value)
       autoSkillEnabled = Value
       
       task.spawn(function()
           while autoSkillEnabled do
               pcall(function()
                   -- Method A: Fire all Remotes inside ReplicatedStorage.Remotes or Events
                   local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage
                   for _, remote in ipairs(remotesFolder:GetDescendants()) do
                       if remote:IsA("RemoteEvent") and (remote.Name:lower():find("skill") or remote.Name:lower():find("use") or remote.Name:lower():find("ability")) then
                           remote:FireServer(1)
                           remote:FireServer(2)
                           remote:FireServer(3)
                       end
                   end
                   
                   -- Method B: Virtual Input Key Pressing (Z, X, C, V, E)
                   local VirtualInputManager = game:GetService("VirtualInputManager")
                   local keys = {Enum.KeyCode.E, Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
                   for _, key in ipairs(keys) do
                       VirtualInputManager:SendKeyEvent(true, key, false, game)
                       task.wait(0.05)
                       VirtualInputManager:SendKeyEvent(false, key, false, game)
                   end
               end)
               task.wait(0.5)
           end
       end)
   end,
})

-- Helper function to find inventory in player data
local function GetPlayerInventory()
    return LocalPlayer:FindFirstChild("PlayerData") 
        or LocalPlayer:FindFirstChild("Data") 
        or LocalPlayer:FindFirstChild("Inventory") 
        or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Inventory"))
end

-- 3. EQUIP BEST WEAPON
MainTab:CreateButton({
   Name = "Equip Best Weapon",
   Callback = function()
       pcall(function()
           local inv = GetPlayerInventory()
           local equipRemote = nil
           
           -- Search for equip remote dynamically
           for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
               if v:IsA("RemoteEvent") and (v.Name:lower():find("equip") or v.Name:lower():find("weapon")) then
                   equipRemote = v
                   break
               end
           end
           
           if equipRemote then
               -- Trigger auto equip remote/signal if available
               equipRemote:FireServer("BestWeapon")
               equipRemote:FireServer("EquipBest")
               Rayfield:Notify({Title = "Equip", Content = "Equip command sent to server!", Duration = 3})
           else
               Rayfield:Notify({Title = "Error", Content = "Equip Remote not found automatically.", Duration = 3})
           end
       end)
   end,
})

-- 4. EQUIP BEST ARMOR
MainTab:CreateButton({
   Name = "Equip Best Armor",
   Callback = function()
       pcall(function()
           local equipRemote = nil
           
           for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
               if v:IsA("RemoteEvent") and (v.Name:lower():find("equip") or v.Name:lower():find("armor")) then
                   equipRemote = v
                   break
               end
           end
           
           if equipRemote then
               equipRemote:FireServer("BestArmor")
               equipRemote:FireServer("EquipBestArmor")
               Rayfield:Notify({Title = "Equip", Content = "Armor equip command sent!", Duration = 3})
           else
               Rayfield:Notify({Title = "Error", Content = "Armor Remote not found.", Duration = 3})
           end
       end)
   end,
})
