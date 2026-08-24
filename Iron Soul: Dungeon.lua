-- Rayfield Library Updated Load
local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/sirius-menu/rayfield/main/source.lua'))()
end)

if not Success or not Rayfield then
    -- Alternative Backup UI Library Loader
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

-- Main Window Creation
local Window = Rayfield:CreateWindow({
   Name = "Iron Soul: Dungeon Hub",
   LoadingTitle = "Iron Soul Hub",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = false
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

-- Continuous WalkSpeed Loop
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.WalkSpeed ~= CurrentWalkSpeed then
                    player.Character.Humanoid.WalkSpeed = CurrentWalkSpeed
                end
            end
        end)
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
      pcall(function()
          local player = game:GetService("Players").LocalPlayer
          if player and player.Character and player.Character:FindFirstChild("Humanoid") then
             player.Character.Humanoid.WalkSpeed = Value
          end
      end)
   end,
})

------------------------------------------------------------------
-- 2. Auto Cast Skills Toggle (Includes Auto Unlock & Equip)
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
               pcall(function()
                  local VirtualInputManager = game:GetService("VirtualInputManager")
                  local ReplicatedStorage = game:GetService("ReplicatedStorage")
                  
                  -- Auto Unlock & Equip Skill Trigger
                  local unlockRemote = ReplicatedStorage:FindFirstChild("UnlockSkill", true) or ReplicatedStorage:FindFirstChild("UpgradeSkillTree", true)
                  local equipRemote = ReplicatedStorage:FindFirstChild("EquipSkill", true) or ReplicatedStorage:FindFirstChild("SetSkill", true)
                  
                  if unlockRemote and unlockRemote:IsA("RemoteEvent") then unlockRemote:FireServer() end
                  if equipRemote and equipRemote:IsA("RemoteEvent") then equipRemote:FireServer() end

                  -- Cast Skills (1, 2, 3, 4 Keys)
                  for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}) do
                     if not AutoSkillEnabled then break end
                     VirtualInputManager:SendKeyEvent(true, key, false, game)
                     task.wait(0.05)
                     VirtualInputManager:SendKeyEvent(false, key, false, game)
                     task.wait(0.1)
                  end
               end)
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
      pcall(function()
          local ReplicatedStorage = game:GetService("ReplicatedStorage")
          local weaponRemote = ReplicatedStorage:FindFirstChild("EquipBestWeapon", true) or ReplicatedStorage:FindFirstChild("EquipWeapon", true)
          if weaponRemote and weaponRemote:IsA("RemoteEvent") then
             weaponRemote:FireServer()
          end
      end)
   end,
})

------------------------------------------------------------------
-- 4. Equip Best Armor Button
------------------------------------------------------------------
MainTab:CreateButton({
   Name = "Equip Best Armor",
   Callback = function()
      pcall(function()
          local ReplicatedStorage = game:GetService("ReplicatedStorage")
          local armorRemote = ReplicatedStorage:FindFirstChild("EquipBestArmor", true) or ReplicatedStorage:FindFirstChild("EquipArmor", true)
          if armorRemote and armorRemote:IsA("RemoteEvent") then
             armorRemote:FireServer()
          end
      end)
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
               pcall(function()
                  local ReplicatedStorage = game:GetService("ReplicatedStorage")
                  local forgeRemote = ReplicatedStorage:FindFirstChild("ForgeItem", true) or ReplicatedStorage:FindFirstChild("CraftItem", true)
                  if forgeRemote and forgeRemote:IsA("RemoteEvent") then
                     forgeRemote:FireServer()
                  end
               end)
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
               pcall(function()
                  local ReplicatedStorage = game:GetService("ReplicatedStorage")
                  local enhanceRemote = ReplicatedStorage:FindFirstChild("EnhanceGear", true) or ReplicatedStorage:FindFirstChild("UpgradeItem", true)
                  if enhanceRemote and enhanceRemote:IsA("RemoteEvent") then
                     enhanceRemote:FireServer()
                  end
               end)
               task.wait(1.5)
            end
         end)
      end
   end,
})
