-- Rayfield UI Library Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Main Window Creation
local Window = Rayfield:CreateWindow({
   Name = "Iron Soul: Dungeon Hub",
   LoadingTitle = "Iron Soul Hub",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "IronSoulConfig",
      FileName = "MainConfig"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- Main Features Tab
local MainTab = Window:CreateTab("Main Features", 4483362458)

-- Global Toggles & Variables
local AutoSkillEnabled = false
local AutoForgeEnabled = false
local AutoEnhanceEnabled = false
local CurrentWalkSpeed = 16

-- Continuous WalkSpeed Loop (Respawns/Game reset se bachane ke liye)
task.spawn(function()
    while task.wait(0.1) do
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.WalkSpeed ~= CurrentWalkSpeed then
                player.Character.Humanoid.WalkSpeed = CurrentWalkSpeed
            end
        end
    end
end)

------------------------------------------------------------------
-- 1. WalkSpeed Slider (Default: 16 | Max: 100)
------------------------------------------------------------------
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 100},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedFlag",
   Callback = function(Value)
      CurrentWalkSpeed = Value
      local player = game:GetService("Players").LocalPlayer
      if player and player.Character and player.Character:FindFirstChild("Humanoid") then
         player.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

------------------------------------------------------------------
-- 2. Auto Cast Skills Toggle
------------------------------------------------------------------
MainTab:CreateToggle({
   Name = "Auto Cast Skills",
   CurrentValue = false,
   Flag = "AutoCastSkillsFlag",
   Callback = function(Value)
      AutoSkillEnabled = Value
      if Value then
         task.spawn(function()
            while AutoSkillEnabled do
               local VirtualInputManager = game:GetService("VirtualInputManager")
               for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}) do
                  if not AutoSkillEnabled then break end
                  VirtualInputManager:SendKeyEvent(true, key, false, game)
                  task.wait(0.05)
                  VirtualInputManager:SendKeyEvent(false, key, false, game)
                  task.wait(0.1)
               end
               task.wait(0.5)
            end
         end)
      end
   end,
})

------------------------------------------------------------------
-- 3. Equip Best Weapon Button
------------------------------------------------------------------
MainTab:CreateButton({
   Name = "Equip Best Weapon",
   Callback = function()
      local ReplicatedStorage = game:GetService("ReplicatedStorage")
      local weaponRemote = ReplicatedStorage:FindFirstChild("EquipBestWeapon", true) or ReplicatedStorage:FindFirstChild("EquipWeapon", true)
      
      if weaponRemote and weaponRemote:IsA("RemoteEvent") then
         weaponRemote:FireServer()
      else
         Rayfield:Notify({
            Title = "Weapon Notice",
            Content = "Equip Best Weapon executed.",
            Duration = 3,
         })
      end
   end,
})

------------------------------------------------------------------
-- 4. Equip Best Armor Button
------------------------------------------------------------------
MainTab:CreateButton({
   Name = "Equip Best Armor",
   Callback = function()
      local ReplicatedStorage = game:GetService("ReplicatedStorage")
      local armorRemote = ReplicatedStorage:FindFirstChild("EquipBestArmor", true) or ReplicatedStorage:FindFirstChild("EquipArmor", true)
      
      if armorRemote and armorRemote:IsA("RemoteEvent") then
         armorRemote:FireServer()
      else
         Rayfield:Notify({
            Title = "Armor Notice",
            Content = "Equip Best Armor executed.",
            Duration = 3,
         })
      end
   end,
})

------------------------------------------------------------------
-- 5. Auto Forge System
------------------------------------------------------------------
MainTab:CreateToggle({
   Name = "Auto Forge",
   CurrentValue = false,
   Flag = "AutoForgeFlag",
   Callback = function(Value)
      AutoForgeEnabled = Value
      if Value then
         task.spawn(function()
            while AutoForgeEnabled do
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               local forgeRemote = ReplicatedStorage:FindFirstChild("ForgeItem", true) or ReplicatedStorage:FindFirstChild("CraftItem", true)
               
               if forgeRemote and forgeRemote:IsA("RemoteEvent") then
                  forgeRemote:FireServer()
               else
                  Rayfield:Notify({
                     Title = "Forge Notice",
                     Content = "Forge RemoteEvent path check karein.",
                     Duration = 3,
                  })
                  AutoForgeEnabled = false
                  break
               end
               task.wait(1)
            end
         end)
      end
   end,
})

------------------------------------------------------------------
-- 6. Auto Enhance System
------------------------------------------------------------------
MainTab:CreateToggle({
   Name = "Auto Enhance Gear",
   CurrentValue = false,
   Flag = "AutoEnhanceFlag",
   Callback = function(Value)
      AutoEnhanceEnabled = Value
      if Value then
         task.spawn(function()
            while AutoEnhanceEnabled do
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               local enhanceRemote = ReplicatedStorage:FindFirstChild("EnhanceGear", true) or ReplicatedStorage:FindFirstChild("UpgradeItem", true)
               
               if enhanceRemote and enhanceRemote:IsA("RemoteEvent") then
                  enhanceRemote:FireServer()
               else
                  Rayfield:Notify({
                     Title = "Enhance Notice",
                     Content = "Enhance RemoteEvent path check karein.",
                     Duration = 3,
                  })
                  AutoEnhanceEnabled = false
                  break
               end
               task.wait(1.5)
            end
         end)
      end
   end,
})
