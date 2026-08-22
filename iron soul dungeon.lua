-- Iron Soul: Dungeon - Speed Fix & Auto Attack
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Iron Soul: Dungeon Hub",
   LoadingTitle = "Iron Soul Script",
   LoadingSubtitle = "Speed Fix & Auto Attack",
   ConfigurationSaving = { Enabled = false }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local autoAttackEnabled = false
local customSpeed = 16
local speedMultiplier = 1

local MainTab = Window:CreateTab("Main Features", 4483362458)

-- 1. WALK SPEED (CFrame Movement Boost Fix)
MainTab:CreateSlider({
   Name = "Speed Multiplier / WalkSpeed",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "x Multiplier",
   CurrentValue = 1,
   Flag = "SpeedSlider",
   Callback = function(Value)
       speedMultiplier = Value
   end,
})

-- Movement Anti-Reset Loop (Bypasses basic WalkSpeed locks)
RunService.RenderStepped:Connect(function(delta)
    pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
            local humanoid = character.Humanoid
            local hrp = character.HumanoidRootPart

            -- Standard WalkSpeed Force
            humanoid.WalkSpeed = 16 * speedMultiplier
            
            -- CFrame Velocity Push (If game overrides WalkSpeed)
            if speedMultiplier > 1 and humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (speedMultiplier * 0.4))
            end
        end
    end)
end)

-- 2. AUTO ATTACK (Left Click Clicker + Weapon Tool Swing)
MainTab:CreateToggle({
   Name = "Auto Attack",
   CurrentValue = false,
   Flag = "AutoAttackToggle",
   Callback = function(Value)
       autoAttackEnabled = Value
       
       task.spawn(function()
           while autoAttackEnabled do
               pcall(function()
                   -- 1. Virtual Mouse Click (Triggers UI & Screen Combat)
                   VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                   task.wait(0.05)
                   VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)

                   -- 2. Equipped Tool Activate (Triggers Sword Swing)
                   local character = LocalPlayer.Character
                   if character then
                       local tool = character:FindFirstChildOfClass("Tool")
                       if tool then
                           tool:Activate()
                       end
                   end
               end)
               task.wait(0.1) -- Attack Rate Delay
           end
       end)
   end,
})
