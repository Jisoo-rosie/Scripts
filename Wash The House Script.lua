--[[
    ===================================================
    ROBLOX SCRIPT: WASH THE HOUSE (V2 ULTRA FIX)
    Features: Auto Tool Equip, Smart Remote Detection, Instant Clean
    ===================================================
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Wash The House | KaitoFyp Edition 🧼",
   Icon = 0,
   LoadingTitle = "Loading Wash The House V2...",
   LoadingSubtitle = "Auto-Detecting Remotes & Dirt...",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------
-- SERVICES & VARIABLES
----------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

local Flags = {
    AutoWash = false,
    InstantClean = false,
    InfiniteWater = false,
    AutoCollectCash = false,
    DirtESP = false,
    SpeedBoost = 40,
    JumpBoost = 80,
    EnableSpeed = false,
    EnableJump = false,
    Noclip = false,
    AntiAFK = true
}

----------------------------------------------------
-- SMART DIRT & REMOTE DETECTION LOGIC
----------------------------------------------------
local function GetWashRemotes()
    local remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = string.lower(obj.Name)
            if n:find("wash") or n:find("clean") or n:find("dirt") or n:find("spray") or n:find("water") or n:find("hit") or n:find("tool") or n:find("use") then
                table.insert(remotes, obj)
            end
        end
    end
    local tool = Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local function GetAllDirts()
    local dirts = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local name = string.lower(obj.Name)
            local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
            
            local isDirt = name:find("dirt") or name:find("stain") or name:find("clean") or name:find("mud") or name:find("spot")
            local inDirtFolder = pName:find("dirt") or pName:find("stain") or pName:find("cleanable") or pName:find("house")
            local hasDirtAttr = obj:GetAttribute("Dirt") or obj:GetAttribute("Cleanliness") or obj:GetAttribute("HP") or obj:GetAttribute("Health")
            
            local hasDirtDecal = false
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    local dName = string.lower(child.Name)
                    if dName:find("dirt") or dName:find("stain") then
                        hasDirtDecal = true
                    end
                end
            end
            
            if isDirt or (inDirtFolder and (hasDirtAttr or hasDirtDecal)) or hasDirtAttr or hasDirtDecal then
                table.insert(dirts, obj)
            end
        end
    end
    return dirts
end

local function CleanTargetDirt(dirtObj)
    if not dirtObj or not dirtObj.Parent then return end
    pcall(function()
        -- 1. Fire Wash Remotes
        for _, r in pairs(GetWashRemotes()) do
            if r:IsA("RemoteEvent") then
                r:FireServer(dirtObj, dirtObj.Position, Vector3.new(0, 1, 0))
                r:FireServer(dirtObj)
                r:FireServer()
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer(dirtObj)
            end
        end

        -- 2. Equip & Activate Washer Tool
        local tool = Character:FindFirstChildOfClass("Tool")
        if not tool then
            local bpTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if bpTool then
                bpTool.Parent = Character
                tool = bpTool
            end
        end
        if tool then
            tool:Activate()
            if tool:FindFirstChild("Handle") and dirtObj:IsA("BasePart") then
                firetouchinterest(tool.Handle, dirtObj, 0)
                firetouchinterest(tool.Handle, dirtObj, 1)
            end
        end

        -- 3. Clear Attributes & Textures
        if dirtObj:GetAttribute("Cleanliness") then dirtObj:SetAttribute("Cleanliness", 100) end
        if dirtObj:GetAttribute("Dirt") then dirtObj:SetAttribute("Dirt", 0) end
        if dirtObj:GetAttribute("HP") then dirtObj:SetAttribute("HP", 0) end
        
        for _, child in pairs(dirtObj:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") then
                child.Transparency = 1
                child:Destroy()
            end
        end
        
        if string.find(string.lower(dirtObj.Name), "dirt") or string.find(string.lower(dirtObj.Name), "stain") then
            dirtObj.Transparency = 1
            dirtObj.CanCollide = false
        end
    end)
end

----------------------------------------------------
-- LOOPS
----------------------------------------------------
RunService.Stepped:Connect(function()
    if Flags.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if Flags.EnableSpeed and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Flags.SpeedBoost
    end
    
    if Flags.EnableJump and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.UseJumpPower = true
        Character.Humanoid.JumpPower = Flags.JumpBoost
    end
end)

LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

----------------------------------------------------
-- UI TABS
----------------------------------------------------
local CleaningTab = Window:CreateTab("🧼 Wash & Clean", 4483362458)

CleaningTab:CreateToggle({
   Name = "Auto Instant Clean Wash",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoWash = Value
      task.spawn(function()
          while Flags.AutoWash do
              for _, dirt in pairs(GetAllDirts()) do
                  if not Flags.AutoWash then break end
                  CleanTargetDirt(dirt)
                  task.wait(0.02)
              end
              task.wait(0.3)
          end
      end)
   end,
})

CleaningTab:CreateButton({
   Name = "Instant Clean Dirt Wash ⚡",
   Callback = function()
       local dirts = GetAllDirts()
       Rayfield:Notify({ Title = "Cleaning...", Content = "Cleaning " .. tostring(#dirts) .. " dirt spots!", Duration = 3 })
       for _, dirt in pairs(dirts) do CleanTargetDirt(dirt) end
   end,
})

CleaningTab:CreateToggle({
   Name = "Infinite Water / No Refill",
   CurrentValue = false,
   Callback = function(Value)
      Flags.InfiniteWater = Value
      task.spawn(function()
          while Flags.InfiniteWater do
              pcall(function()
                  local tool = Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                  if tool then
                      for _, v in pairs(tool:GetDescendants()) do
                          if v:IsA("NumberValue") or v:IsA("IntValue") then
                              local vn = string.lower(v.Name)
                              if vn:find("water") or vn:find("fuel") or vn:find("ammo") or vn:find("capacity") then
                                  v.Value = 999999
                              end
                          end
                      end
                  end
              end)
              task.wait(0.5)
          end
      end)
   end,
})

local AutoTab = Window:CreateTab("✨ Aura Mods", 4483362458)

AutoTab:CreateToggle({
   Name = "Auto Collect Cash & Coins",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoCollectCash = Value
      task.spawn(function()
          while Flags.AutoCollectCash do
              pcall(function()
                  for _, item in pairs(Workspace:GetDescendants()) do
                      if item:IsA("TouchTransmitter") then
                          local parent = item.Parent
                          if parent and string.find(string.lower(parent.Name), "coin") or string.find(string.lower(parent.Name), "cash") then
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

local PlayerTab = Window:CreateTab("🏃 Washer & Player", 4483362458)

PlayerTab:CreateToggle({
   Name = "Enable WalkSpeed Boost",
   CurrentValue = false,
   Callback = function(Value) Flags.EnableSpeed = Value end,
})

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 50,
   Callback = function(Value) Flags.SpeedBoost = Value end,
})

PlayerTab:CreateToggle({
   Name = "Noclip (Walk Through Walls)",
   CurrentValue = false,
   Callback = function(Value) Flags.Noclip = Value end,
})

local VisualsTab = Window:CreateTab("👁️ ESP & Visuals", 4483362458)

VisualsTab:CreateToggle({
   Name = "Dirt ESP (Highlight Spots)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.DirtESP = Value
      if Value then
          task.spawn(function()
              while Flags.DirtESP do
                  for _, dirt in pairs(GetAllDirts()) do
                      if not dirt:FindFirstChild("ESP_Highlight") then
                          local hl = Instance.new("Highlight")
                          hl.Name = "ESP_Highlight"
                          hl.FillColor = Color3.fromRGB(255, 30, 30)
                          hl.Parent = dirt
                      end
                  end
                  task.wait(2)
              end
          end)
      end
   end,
})

local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateToggle({ Name = "Anti-AFK", CurrentValue = true, Callback = function(Value) Flags.AntiAFK = Value end })
MiscTab:CreateButton({ Name = "Rejoin Server 🔄", Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })

Rayfield:Notify({ Title = "V2 Script Loaded!", Content = "Auto-Clean & Wash features are active!", Duration = 5 })
