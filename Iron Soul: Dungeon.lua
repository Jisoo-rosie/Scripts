-- Rayfield Library Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window Creation
local Window = Rayfield:CreateWindow({
   Name = "Iron Soul: Dungeon Hub",
   LoadingTitle = "Iron Soul Script",
   LoadingSubtitle = "Auto Features",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "IronSoulConfig",
      FileName = "MainConfig"
   },
   KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main Features", 4483362458)

-- Global Variables / Toggles Status
local AutoSkillEnabled = false
local AutoForgeEnabled = false
local AutoEnhanceEnabled = false

------------------------------------------------------------------
-- 1. WalkSpeed Feature
------------------------------------------------------------------
MainTab:CreateInput({
   Name = "WalkSpeed",
   PlaceholderText = "Default: 16",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local speed = tonumber(Text)
      if speed then
         local localPlayer = game:GetService("Players").LocalPlayer
         if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = speed
         end
      end
   end,
})

------------------------------------------------------------------
-- 2. Skill Tree / Auto Cast Skills
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
               -- VirtualInputManager ya direct key press trigger
               local VirtualInputManager = game:GetService("VirtualInputManager")
               
               -- 1, 2, 3, 4 keys auto-trigger karein (Skills)
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
-- 3. Auto Forging System
------------------------------------------------------------------
MainTab:CreateToggle({
   Name = "Auto Forge Weapons/Armor",
   CurrentValue = false,
   Flag = "AutoForgeFlag",
   Callback = function(Value)
      AutoForgeEnabled = Value
      if Value then
         task.spawn(function()
            while AutoForgeEnabled do
               -- Game ke Forge Remote Event ko Fire karne ka logic
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               
               -- Apne game ke exact RemoteEvent path se replace kar sakte hain:
               local forgeRemote = ReplicatedStorage:FindFirstChild("ForgeItem", true) or ReplicatedStorage:FindFirstChild("CraftItem", true)
               
               if forgeRemote and forgeRemote:IsA("RemoteEvent") then
                  forgeRemote:FireServer()
               else
                  -- Standard fallback notification
                  Rayfield:Notify({
                     Title = "Forge Notice",
                     Content = "Forge RemoteEvent nahi mila. Please path verify karein.",
                     Duration = 3,
                  })
                  AutoForgeEnabled = false
                  break
               end
               
               task.wait(1) -- Crafting speed delay
            end
         end)
      end
   end,
})

------------------------------------------------------------------
-- 4. Auto Enhance System
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
               
               -- Game ke Enhance/Upgrade Remote Event ko Fire karne ka logic
               local enhanceRemote = ReplicatedStorage:FindFirstChild("EnhanceGear", true) or ReplicatedStorage:FindFirstChild("UpgradeItem", true)
               
               if enhanceRemote and enhanceRemote:IsA("RemoteEvent") then
                  enhanceRemote:FireServer()
               else
                  Rayfield:Notify({
                     Title = "Enhance Notice",
                     Content = "Enhance RemoteEvent nahi mila. Path check karein.",
                     Duration = 3,
                  })
                  AutoEnhanceEnabled = false
                  break
               end
               
               task.wait(1.5) -- Enhancement interval
            end
         end)
      end
   end,
})
