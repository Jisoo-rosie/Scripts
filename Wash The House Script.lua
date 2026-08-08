--[[
    ===================================================
    ROBLOX SCRIPT: WASH THE HOUSE (ALL-IN-ONE HUB)
    Created for: Wash The House Game
    UI Library: Rayfield UI
    ===================================================
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Wash The House | Premium Hub 🧼",
   Icon = 0,
   LoadingTitle = "Loading Wash The House Hub...",
   LoadingSubtitle = "by Antigravity AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "WashTheHouseConfig",
      FileName = "MainConfig"
   },
   Discord = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------
-- SERVICES & VARIABLES
----------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

local Flags = {
    AutoWash = false,
    InfiniteWater = false,
    AutoCollectCash = false,
    AutoUpgrade = false,
    DirtESP = false,
    SpeedBoost = 16,
    JumpBoost = 50,
    EnableSpeed = false,
    EnableJump = false,
    Noclip = false,
    AntiAFK = true
}

local function GetDirtObjects()
    local dirts = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local name = string.lower(obj.Name)
            if name:find("dirt") or name:find("stain") or name:find("cleanable") or obj:GetAttribute("Dirt") then
                table.insert(dirts, obj)
            end
        end
    end
    return dirts
end

local function CleanDirt(dirtObj)
    if not dirtObj or not dirtObj.Parent then return end
    pcall(function()
        if dirtObj:FindFirstChild("Transparency") then dirtObj.Transparency = 1 end
        if dirtObj:GetAttribute("Cleanliness") then dirtObj:SetAttribute("Cleanliness", 100) end
    end)
end

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Flags.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

----------------------------------------------------
-- TABS & UI CONTROLS
----------------------------------------------------

-- TAB 1: AUTO CLEANING
local CleaningTab = Window:CreateTab("🧼 Auto Clean", 4483362458)

CleaningTab:CreateToggle({
   Name = "Auto Wash / Auto Clean Dirt",
   CurrentValue = false,
   Flag = "AutoWashToggle",
   Callback = function(Value)
      Flags.AutoWash = Value
      task.spawn(function()
          while Flags.AutoWash do
              local dirts = GetDirtObjects()
              for _, dirt in pairs(dirts) do
                  if not Flags.AutoWash then break end
                  CleanDirt(dirt)
                  task.wait(0.05)
              end
              task.wait(0.5)
          end
      end)
   end,
})

CleaningTab:CreateButton({
   Name = "Instant Clean Whole House ⚡",
   Callback = function()
       Rayfield:Notify({ Title = "Cleaning...", Content = "Cleaning all dirt in the house!", Duration = 3 })
       local dirts = GetDirtObjects()
       for _, dirt in pairs(dirts) do CleanDirt(dirt) end
   end,
})

CleaningTab:CreateToggle({
   Name = "Infinite Water / Tank",
   CurrentValue = false,
   Flag = "InfWaterToggle",
   Callback = function(Value)
      Flags.InfiniteWater = Value
      task.spawn(function()
          while Flags.InfiniteWater do
              pcall(function()
                  local tool = Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                  if tool then
                      if tool:FindFirstChild("Water") then tool.Water.Value = 99999 end
                      if tool:FindFirstChild("Fuel") then tool.Fuel.Value = 99999 end
                  end
              end)
              task.wait(0.5)
          end
      end)
   end,
})

-- TAB 2: AUTOMATION & CASH
local AutoTab = Window:CreateTab("💰 Automation", 4483362458)

AutoTab:CreateToggle({
   Name = "Auto Collect Cash / Coins",
   CurrentValue = false,
   Flag = "AutoCollectToggle",
   Callback = function(Value)
      Flags.AutoCollectCash = Value
      task.spawn(function()
          while Flags.AutoCollectCash do
              pcall(function()
                  for _, item in pairs(Workspace:GetDescendants()) do
                      if item:IsA("TouchTransmitter") then
                          local parent = item.Parent
                          if parent and (string.find(string.lower(parent.Name), "coin") or string.find(string.lower(parent.Name), "cash")) then
                              if Character and Character:FindFirstChild("HumanoidRootPart") then
                                  firetouchinterest(Character.HumanoidRootPart, parent, 0)
                                  firetouchinterest(Character.HumanoidRootPart, parent, 1)
                              end
                          end
                      end
                  end
              end)
              task.wait(0.3)
          end
      end)
   end,
})

-- TAB 3: PLAYER MODS
local PlayerTab = Window:CreateTab("⚡ Player Mods", 4483362458)

PlayerTab:CreateToggle({
   Name = "Enable WalkSpeed Boost",
   CurrentValue = false,
   Flag = "EnableSpeedToggle",
   Callback = function(Value)
      Flags.EnableSpeed = Value
      if Character and Character:FindFirstChild("Humanoid") then
          Character.Humanoid.WalkSpeed = Value and Flags.SpeedBoost or 16
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {16, 200},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 50,
   Callback = function(Value)
      Flags.SpeedBoost = Value
      if Flags.EnableSpeed and Character and Character:FindFirstChild("Humanoid") then
          Character.Humanoid.WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateToggle({
   Name = "Noclip (Walk Through Walls)",
   CurrentValue = false,
   Callback = function(Value) Flags.Noclip = Value end,
})

-- TAB 4: VISUALS / DIRT ESP
local VisualsTab = Window:CreateTab("👁️ Visuals / ESP", 4483362458)

VisualsTab:CreateToggle({
   Name = "Dirt ESP (Highlight Dirt Spots)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.DirtESP = Value
      if Value then
          task.spawn(function()
              while Flags.DirtESP do
                  for _, dirt in pairs(GetDirtObjects()) do
                      if not dirt:FindFirstChild("ESP_Highlight") then
                          local hl = Instance.new("Highlight")
                          hl.Name = "ESP_Highlight"
                          hl.FillColor = Color3.fromRGB(255, 50, 50)
                          hl.Parent = dirt
                      end
                  end
                  task.wait(2)
              end
          end)
      end
   end,
})

-- TAB 5: MISC
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = true,
   Callback = function(Value) Flags.AntiAFK = Value end,
})

MiscTab:CreateButton({
   Name = "Rejoin Server 🔄",
   Callback = function()
       game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
   end,
})

Rayfield:Notify({ Title = "Script Loaded!", Content = "Enjoy Wash The House Hub! 🧼✨", Duration = 5 })
