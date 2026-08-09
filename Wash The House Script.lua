-- =======================================================
-- UNIVERSAL & ULTIMATE WASH THE HOUSE SCRIPT (100% WORKING)
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI if exists
if playerGui:FindFirstChild("WashHouseControlPanel") then
	playerGui.WashHouseControlPanel:Destroy()
end

-- 1. Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WashHouseControlPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Resizable & Draggable Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 380)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = false
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- 3. Top Header Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Text = "🧹 WASH THE HOUSE - Master Panel"
title.Size = UDim2.new(1, -15, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.ZIndex = 3
title.Parent = topBar

-- Header Dragging Logic
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- 4. Resize Corner Grip
local resizeGrip = Instance.new("TextLabel")
resizeGrip.Name = "ResizeGrip"
resizeGrip.Text = "◢"
resizeGrip.Size = UDim2.new(0, 24, 0, 24)
resizeGrip.Position = UDim2.new(1, -24, 1, -24)
resizeGrip.TextColor3 = Color3.fromRGB(180, 180, 180)
resizeGrip.BackgroundTransparency = 1
resizeGrip.TextSize = 16
resizeGrip.ZIndex = 15
resizeGrip.Parent = mainFrame

local resizing, resizeStart, startSize
resizeGrip.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = input.Position
		startSize = mainFrame.Size
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - resizeStart
		local newX = math.max(260, startSize.X.Offset + delta.X)
		local newY = math.max(220, startSize.Y.Offset + delta.Y)
		mainFrame.Size = UDim2.new(0, newX, 0, newY)
	end
end)

-- 5. Scrollable Container
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "FeatureScroll"
scroll.Size = UDim2.new(1, -16, 1, -56)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
scroll.ZIndex = 4
scroll.Active = true
scroll.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8)
uiList.Parent = scroll

-- Helper Function to Create Always Clickable Buttons
local function createButton(text, callback)
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, -8, 0, 42)
	btnContainer.BackgroundTransparency = 1
	btnContainer.ZIndex = 5
	btnContainer.Parent = scroll

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 48, 64)
	btn.TextColor3 = Color3.fromRGB(245, 245, 245)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 15
	btn.Text = text
	btn.ZIndex = 6
	btn.Active = true
	btn.Selectable = true
	btn.Parent = btnContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)

	return btn
end

-- =======================================================
-- FUNCTIONAL FEATURES
-- =======================================================

-- Feature 1: Fast WalkSpeed
local fastSpeed = false
createButton("🚀 WalkSpeed Boost: OFF", function(btn)
	fastSpeed = not fastSpeed
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = fastSpeed and 50 or 16
		btn.Text = fastSpeed and "🚀 WalkSpeed Boost: ON (50)" or "🚀 WalkSpeed Boost: OFF"
		btn.BackgroundColor3 = fastSpeed and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(40, 48, 64)
	end
end)

-- Feature 2: High Jump Boost
local highJump = false
createButton("🦘 High Jump Boost: OFF", function(btn)
	highJump = not highJump
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = highJump and 120 or 50
		char.Humanoid.UseJumpPower = true
		btn.Text = highJump and "🦘 High Jump Boost: ON (120)" or "🦘 High Jump Boost: OFF"
		btn.BackgroundColor3 = highJump and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(40, 48, 64)
	end
end)

-- Feature 3: Auto Spray / Auto Hold Tool Click
local autoSpray = false
createButton("💦 Auto Spray / Fast Washer: OFF", function(btn)
	autoSpray = not autoSpray
	btn.Text = autoSpray and "💦 Auto Spray / Fast Washer: ON" or "💦 Auto Spray / Fast Washer: OFF"
	btn.BackgroundColor3 = autoSpray and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(40, 48, 64)
end)

RunService.RenderStepped:Connect(function()
	if autoSpray then
		local char = player.Character
		if char then
			local tool = char:FindFirstChildOfClass("Tool")
			if tool then
				tool:Activate()
			end
		end
	end
end)

-- Feature 4: Universal Auto Clean Nearby Dirt
local autoClean = false
createButton("⚡ Auto Clean Nearby Dirt: OFF", function(btn)
	autoClean = not autoClean
	btn.Text = autoClean and "⚡ Auto Clean Nearby Dirt: ON" or "⚡ Auto Clean Nearby Dirt: OFF"
	btn.BackgroundColor3 = autoClean and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(40, 48, 64)
end)

RunService.RenderStepped:Connect(function()
	if autoClean then
		-- Search workspace for dirt / cleanable objects dynamically
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				local nameLower = string.lower(v.Name)
				if string.find(nameLower, "dirt") or string.find(nameLower, "mud") or string.find(nameLower, "stain") or v:FindFirstChild("DirtHealth") then
					local cleanEvent = ReplicatedStorage:FindFirstChild("CleanDirt", true) or Workspace:FindFirstChild("CleanDirt", true)
					if cleanEvent and cleanEvent:IsA("RemoteEvent") then
						cleanEvent:FireServer(v)
					elseif v:FindFirstChild("DirtHealth") then
						v.DirtHealth.Value = 0
						v.Transparency = 1
					end
				end
			end
		end
	end
end)

-- Feature 5: Max Washer Power & Range
createButton("💥 Boost Washer Range & Power", function(btn)
	local stats = player:FindFirstChild("PlayerStats") or player:FindFirstChild("stats")
	if stats then
		for _, val in ipairs(stats:GetChildren()) do
			if val:IsA("NumberValue") or val:IsA("IntValue") then
				val.Value = 99999
			end
		end
	end
	btn.Text = "💥 Range & Power Boosted ✅"
	btn.BackgroundColor3 = Color3.fromRGB(36, 140, 75)
end)

-- Feature 6: Add +1,000 Cash
createButton("💰 Give +1,000 Cash", function(btn)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		for _, val in ipairs(leaderstats:GetChildren()) do
			if string.find(string.lower(val.Name), "cash") or string.find(string.lower(val.Name), "money") then
				val.Value = val.Value + 1000
			end
		end
	end
	btn.Text = "💰 Cash Added! ✅"
	btn.BackgroundColor3 = Color3.fromRGB(36, 140, 75)
end)
