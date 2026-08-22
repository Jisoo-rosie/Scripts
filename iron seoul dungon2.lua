-- Rayfield Library Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Iron Soul: Dungeon Hub",
   LoadingTitle = "Iron Soul Script",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = false,
   }
})

-- Services & Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local autoSkillEnabled = false
local walkSpeedValue = 16

-- Main Tab
local MainTab = Window:CreateTab("Main Features", 4483362458)

-- 1. WALK SPEED TOGGLE & SLIDER
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
       walkSpeedValue = Value
       local char = LocalPlayer.Character
       if char and char:FindFirstChildOfClass("Humanoid") then
           char:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeedValue
       end
   end,
})

-- Respawn par Speed apply rakhne ke liye
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = walkSpeedValue
end)

-- 2. AUTO SKILL TOGGLE
MainTab:CreateToggle({
   Name = "Auto Cast Skills",
   CurrentValue = false,
   Flag = "AutoSkillToggle",
   Callback = function(Value)
       autoSkillEnabled = Value
       
       task.spawn(function()
           while autoSkillEnabled do
               local skillRemote = ReplicatedStorage:FindFirstChild("SkillRemote", true) or ReplicatedStorage:FindFirstChild("UseSkill", true)
               if skillRemote then
                   -- Skill 1, 2, 3 cast karega
                   skillRemote:FireServer("Skill1")
                   task.wait(0.5)
                   skillRemote:FireServer("Skill2")
                   task.wait(0.5)
               end
               task.wait(1)
           end
       end)
   end,
})

-- 3. EQUIP BEST WEAPON BUTTON
MainTab:CreateButton({
   Name = "Equip Best Weapon",
   Callback = function()
       local inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("DataFolder")
       if not inventory then 
           Rayfield:Notify({Title = "Error", Content = "Inventory nahi mili!", Duration = 3})
           return 
       end

       local bestWeapon = nil
       local highestDamage = -1

       for _, item in ipairs(inventory:GetChildren()) do
           local itemType = item:GetAttribute("Type") or (item:FindFirstChild("Type") and item.Type.Value)
           local damage = item:GetAttribute("Damage") or (item:FindFirstChild("Damage") and item.Damage.Value) or 0

           if itemType == "Weapon" or item:FindFirstChild("IsWeapon") then
               if damage > highestDamage then
                   highestDamage = damage
                   bestWeapon = item
               end
           end
       end

       if bestWeapon then
           local equipRemote = ReplicatedStorage:FindFirstChild("EquipItem", true) or ReplicatedStorage:FindFirstChild("EquipRemote", true)
           if equipRemote then
               equipRemote:FireServer(bestWeapon)
               Rayfield:Notify({Title = "Success", Content = "Equipped: " .. bestWeapon.Name, Duration = 3})
           end
       else
           Rayfield:Notify({Title = "Info", Content = "Koi weapon nahi mila", Duration = 3})
       end
   end,
})

-- 4. EQUIP BEST ARMOR BUTTON
MainTab:CreateButton({
   Name = "Equip Best Armor",
   Callback = function()
       local inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("DataFolder")
       if not inventory then 
           Rayfield:Notify({Title = "Error", Content = "Inventory nahi mili!", Duration = 3})
           return 
       end

       local bestArmor = nil
       local highestDefense = -1

       for _, item in ipairs(inventory:GetChildren()) do
           local itemType = item:GetAttribute("Type") or (item:FindFirstChild("Type") and item.Type.Value)
           local defense = item:GetAttribute("Defense") or (item:FindFirstChild("Defense") and item.Defense.Value) or 0

           if itemType == "Armor" or item:FindFirstChild("IsArmor") then
               if defense > highestDefense then
                   highestDefense = defense
                   bestArmor = item
               end
           end
       end

       if bestArmor then
           local equipRemote = ReplicatedStorage:FindFirstChild("EquipItem", true) or ReplicatedStorage:FindFirstChild("EquipRemote", true)
           if equipRemote then
               equipRemote:FireServer(bestArmor)
               Rayfield:Notify({Title = "Success", Content = "Equipped: " .. bestArmor.Name, Duration = 3})
           end
       else
           Rayfield:Notify({Title = "Info", Content = "Koi armor nahi mila", Duration = 3})
       end
   end,
})
